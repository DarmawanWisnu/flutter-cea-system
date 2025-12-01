from fastapi import APIRouter, HTTPException
from fastapi import BackgroundTasks
from pydantic import BaseModel, Field
from services.api.database import get_connection, release_connection
import time
import httpx

router = APIRouter()
AUTO_MODE_SOURCE = "rule"

# MIGRATION
def run_actuator_migration():
    """
    Optional: run this if you prefer to migrate from actuator module.
    database.run_migrations() already creates/ensures the table.
    """
    conn = get_connection()
    cur = conn.cursor()
    try:
        cur.execute("""
            CREATE TABLE IF NOT EXISTS actuator_event (
                id SERIAL PRIMARY KEY,
                "deviceId" TEXT NOT NULL,
                "ingestTime" BIGINT NOT NULL,
                "phUp" INT DEFAULT 0,
                "phDown" INT DEFAULT 0,
                "nutrientAdd" INT DEFAULT 0,
                "valueS" FLOAT DEFAULT 0,
                "manual" INT DEFAULT 0,
                "auto" INT DEFAULT 0,
                "refill" INT DEFAULT 0
            );
        """)
        conn.commit()
        print("[DB] actuator_event migration executed (from actuator.py).")
    except Exception as e:
        conn.rollback()
        print("[DB] actuator_event migration error (from actuator.py):", e)
    finally:
        cur.close()
        release_connection(conn)


# HELPERS
def is_valid_device(device_id: str):
    conn = get_connection()
    cur = conn.cursor()
    try:
        cur.execute("SELECT 1 FROM kits WHERE id = %s;", (device_id,))
        found = cur.fetchone()
        return found is not None
    finally:
        cur.close()
        release_connection(conn)


# PAYLOAD MODEL
class ActuatorEvent(BaseModel):
    phUp: int = 0
    phDown: int = 0
    nutrientAdd: int = 0
    valueS: float = 0.0
    manual: int = 0
    auto: int = 0
    refill: int = 0

    class Config:
        schema_extra = {
            "example": {
                "phUp": 1,
                "phDown": 0,
                "nutrientAdd": 0,
                "valueS": 5.0
            }
        }

# INSERT ACTUATOR EVENT
@router.post("/event")
async def insert_event(deviceId: str, data: ActuatorEvent):
    global AUTO_MODE_SOURCE
    deviceId = deviceId.strip()

    if not is_valid_device(deviceId):
        raise HTTPException(400, "Invalid deviceId. Register device using /kits.")

    conn = get_connection()
    cur = conn.cursor()

    ingestTime = int(time.time() * 1000)

    try:
        # BLOCK AUTO IF SOURCE IS ML (prevent duplicate auto events)
        if data.auto == 1 and AUTO_MODE_SOURCE != "rule":
            cur.execute("""
                INSERT INTO actuator_event
                    ("deviceId", "ingestTime",
                     "phUp", "phDown", "nutrientAdd", "valueS",
                     "manual", "auto", "refill")
                VALUES (%s, %s, 0, 0, 0, 0, %s, %s, 0)
                RETURNING id;
            """, (
                deviceId, ingestTime,
                int(data.manual), int(data.auto)
            ))
            new_id = cur.fetchone()[0]
            conn.commit()
            return {"status": "ok", "id": new_id}

        # AUTO MODE
        if data.auto == 1:

            # Ambil telemetry terbaru
            cur.execute("""
                SELECT ppm, ph, "tempC", humidity, "waterLevel"
                FROM telemetry
                WHERE "deviceId" = %s
                ORDER BY "ingestTime" DESC
                LIMIT 1;
            """, (deviceId,))
            t = cur.fetchone()

            if t:
                ppm, ph, tempC, humidity, wl = t
            else:
                ppm, ph, tempC, humidity, wl = (0, 0, 0, 0, 0)

            # ==== TRY MACHINE LEARNING FIRST ====
            ml_success = False
            try:
                ml_payload = {
                    "ppm": ppm,
                    "ph": ph,
                    "tempC": tempC,
                    "humidity": humidity,
                    "waterTemp": 0.0,
                    "waterLevel": wl
                }

                async with httpx.AsyncClient(timeout=0.3) as client:
                    r = await client.post("http://127.0.0.1:8000/ml/predict", json=ml_payload)

                if r.status_code == 200:
                    ml = r.json()
                    data.phUp = ml.get("phUp", 0)
                    data.phDown = ml.get("phDown", 0)
                    data.nutrientAdd = ml.get("nutrientAdd", 0)
                    data.refill = ml.get("refill", 0)
                    data.valueS = float(max(
                        data.phUp, data.phDown, data.nutrientAdd, data.refill
                    ))

                    AUTO_MODE_SOURCE = "ml"
                ml_success = True

            except (httpx.TimeoutException, httpx.ConnectError) as e:
                print(f"[ML] Timeout/Connection error: {e}")
            except Exception as e:
                print(f"[ML] Unexpected error: {e}")

            # ==== FALLBACK KE RULE-BASED ====
            if not ml_success:
                AUTO_MODE_SOURCE = "rule"

                # PH UP
                phUpSec = 0
                if ph < 5.5:
                    phUpSec = max(0, min(12, (5.5 - ph) * 8))

                # PH DOWN
                phDownSec = 0
                if ph > 6.5:
                    phDownSec = max(0, min(12, (ph - 6.5) * 8))

                # NUTRIENT
                nutrientSec = 0
                if ppm < 560:
                    nutrientSec = max(0, min(20, (560 - ppm) / 20))

                # REFILL
                refillSec = 0
                if wl < 40:
                    refillSec = max(0, min(25, (40 - wl) * 0.8))

                # Set hasil rule
                data.phUp = int(phUpSec)
                data.phDown = int(phDownSec)
                data.nutrientAdd = int(nutrientSec)
                data.refill = int(refillSec)
                data.valueS = float(max(
                    phUpSec, phDownSec, nutrientSec, refillSec
                )
                )
                # MICRO ADJUSTMENT

                # Micro pH
                if 5.5 <= ph <= 6.5:
                    if ph < 5.7:
                        data.phUp = max(data.phUp, 1)
                    elif ph > 6.3:
                        data.phDown = max(data.phDown, 1)

                # Micro nutrient
                if 560 <= ppm <= 840:
                    if ppm < 650:
                        data.nutrientAdd = max(data.nutrientAdd, 1)

                # Micro refill
                if 40 <= wl <= 85:
                    if wl < 50:
                        data.refill = max(data.refill, 1)

                # Recalculate valueS
                data.valueS = float(max(
                    data.phUp, data.phDown, data.nutrientAdd, data.refill
                ))

        # INSERT FINAL ACTUATOR EVENT
        cur.execute("""
            INSERT INTO actuator_event
                ("deviceId", "ingestTime",
                 "phUp", "phDown", "nutrientAdd", "valueS",
                 "manual", "auto", "refill")
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING id;
        """, (
            deviceId, ingestTime,
            int(data.phUp), int(data.phDown), int(data.nutrientAdd), float(data.valueS),
            int(data.manual), int(data.auto), int(data.refill)
        ))

        new_id = cur.fetchone()[0]
        conn.commit()

        return {"status": "ok", "id": new_id}

    except Exception as e:
        conn.rollback()
        raise HTTPException(500, str(e))

    finally:
        cur.close()
        release_connection(conn)

# GET LATEST ACTUATOR EVENT
@router.get("/latest")
def get_latest_event(deviceId: str):
    deviceId = deviceId.strip()

    if not is_valid_device(deviceId):
        raise HTTPException(400, "Invalid deviceId.")

    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            SELECT id, "deviceId", "ingestTime",
            "phUp", "phDown", "nutrientAdd", "valueS",
            "manual", "auto", "refill"
            FROM actuator_event
            WHERE "deviceId" = %s
            ORDER BY "ingestTime" DESC
            LIMIT 1;
        """, (deviceId,))

        row = cur.fetchone()
        if not row:
            return {"message": "no event"}

        return {
            "id": row[0],
            "deviceId": row[1],
            "ingestTime": row[2],
            "phUp": row[3],
            "phDown": row[4],
            "nutrientAdd": row[5],
            "valueS": row[6],
            "manual": row[7],
            "auto": row[8],
            "refill": row[9]
        }

    except Exception as e:
        raise HTTPException(500, str(e))

    finally:
        cur.close()
        release_connection(conn)


# GET HISTORY
@router.get("/history")
def get_event_history(deviceId: str, limit: int = 50):
    deviceId = deviceId.strip()

    if not is_valid_device(deviceId):
        raise HTTPException(400, "Invalid deviceId.")

    limit = max(1, min(limit, 500))

    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            SELECT id, "deviceId", "ingestTime",
            "phUp", "phDown", "nutrientAdd", "valueS",
            "manual", "auto", "refill"
            FROM actuator_event
            WHERE "deviceId" = %s
            ORDER BY "ingestTime" DESC
            LIMIT %s;
        """, (deviceId, limit))

        rows = cur.fetchall()
        return [
            {
                "id": r[0], "deviceId": r[1], "ingestTime": r[2],
                "phUp": r[3], "phDown": r[4], "nutrientAdd": r[5],
                "valueS": r[6], "manual": r[7], "auto": r[8], "refill": r[9]
            }
            for r in rows
        ]

    except Exception as e:
        raise HTTPException(500, str(e))

    finally:
        cur.close()
        release_connection(conn)


# GET ALL
@router.get("/all")
def get_all_events(deviceId: str):
    deviceId = deviceId.strip()

    if not is_valid_device(deviceId):
        raise HTTPException(400, "Invalid deviceId.")

    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            SELECT id, "deviceId", "ingestTime",
            "phUp", "phDown", "nutrientAdd", "valueS",
            "manual", "auto", "refill"
            FROM actuator_event
            WHERE "deviceId" = %s
            ORDER BY "ingestTime" DESC;
        """, (deviceId,))

        rows = cur.fetchall()
        return [
            {
                "id": r[0], "deviceId": r[1], "ingestTime": r[2],
                "phUp": r[3], "phDown": r[4], "nutrientAdd": r[5],
                "valueS": r[6], "manual": r[7], "auto": r[8], "refill": r[9]
            }
            for r in rows
        ]

    except Exception as e:
        raise HTTPException(500, str(e))

    finally:
        cur.close()
        release_connection(conn)
