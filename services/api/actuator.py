from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from database import get_connection, release_connection
import time

router = APIRouter()

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
                "valueS" FLOAT DEFAULT 0
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
    phUp: int = Field(0, ge=0)          # 0 or 1
    phDown: int = Field(0, ge=0)
    nutrientAdd: int = Field(0, ge=0)
    valueS: float = Field(0.0, ge=0.0)  # seconds / ml

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
def insert_event(deviceId: str, data: ActuatorEvent):
    """
    Expect payload with camelCase fields:
    POST /actuator/event?deviceId=devkit-01
    body:
    {
      "phUp": 1,
      "phDown": 0,
      "nutrientAdd": 0,
      "valueS": 5
    }
    """
    deviceId = deviceId.strip()

    if not is_valid_device(deviceId):
        raise HTTPException(400, "Invalid deviceId. Register device using /kits.")

    conn = get_connection()
    cur = conn.cursor()

    ingestTime = int(time.time() * 1000)

    try:
        cur.execute("""
            INSERT INTO actuator_event
                ("deviceId", "ingestTime", "phUp", "phDown", "nutrientAdd", "valueS")
            VALUES (%s, %s, %s, %s, %s, %s)
            RETURNING id;
        """, (
            deviceId, ingestTime,
            int(data.phUp), int(data.phDown), int(data.nutrientAdd), float(data.valueS)
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
            SELECT id, "deviceId", "ingestTime", "phUp", "phDown", "nutrientAdd", "valueS"
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
            "valueS": row[6]
        }

    except Exception as e:
        raise HTTPException(500, str(e))

    finally:
        cur.close()
        release_connection(conn)

# GET HISTORY-
@router.get("/history")
def get_event_history(deviceId: str, limit: int = 50):
    deviceId = deviceId.strip()

    if not is_valid_device(deviceId):
        raise HTTPException(400, "Invalid deviceId.")

    limit = max(1, min(limit, 500))

    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute(f"""
            SELECT id, "deviceId", "ingestTime", "phUp", "phDown", "nutrientAdd", "valueS"
            FROM actuator_event
            WHERE "deviceId" = %s
            ORDER BY "ingestTime" DESC
            LIMIT %s;
        """, (deviceId, limit))

        rows = cur.fetchall()
        return [
            {
                "id": r[0],
                "deviceId": r[1],
                "ingestTime": r[2],
                "phUp": r[3],
                "phDown": r[4],
                "nutrientAdd": r[5],
                "valueS": r[6]
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
            SELECT id, "deviceId", "ingestTime", "phUp", "phDown", "nutrientAdd", "valueS"
            FROM actuator_event
            WHERE "deviceId" = %s
            ORDER BY "ingestTime" DESC;
        """, (deviceId,))

        rows = cur.fetchall()
        return [
            {
                "id": r[0],
                "deviceId": r[1],
                "ingestTime": r[2],
                "phUp": r[3],
                "phDown": r[4],
                "nutrientAdd": r[5],
                "valueS": r[6]
            }
            for r in rows
        ]

    except Exception as e:
        raise HTTPException(500, str(e))

    finally:
        cur.close()
        release_connection(conn)
