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
async def insert_event(deviceId: str, data: ActuatorEvent, background_tasks: BackgroundTasks):
    global AUTO_MODE_SOURCE
    deviceId = deviceId.strip()

    if not is_valid_device(deviceId):
        raise HTTPException(400, "Invalid deviceId. Register device using /kits.")

    conn = get_connection()
    cur = conn.cursor()

    ingestTime = int(time.time() * 1000)

    try:
        # AUTO MODE
        if data.auto == 1:
            print(f"\n[AUTO MODE] Triggered for device: {deviceId}")

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
                print(f"[AUTO MODE] Telemetry - pH:{ph}, PPM:{ppm}, Temp:{tempC}°C, Humidity:{humidity}%, WaterLevel:{wl} (0-3 scale)")
            else:
                ppm, ph, tempC, humidity, wl = (0, 0, 0, 0, 0)
                print("[AUTO MODE] WARNING: No telemetry found, using zeros")

            # ==== TRY MACHINE LEARNING FIRST (SYNCHRONOUS WITH TIMEOUT) ====
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
                
                print("[AUTO MODE] Attempting ML prediction...")
                async with httpx.AsyncClient(timeout=2.0) as client:
                    r = await client.post("http://127.0.0.1:8000/ml/predict", json=ml_payload)
                
                if r.status_code == 200:
                    ml = r.json()
                    data.phUp = int(ml.get("phUp", 0))
                    data.phDown = int(ml.get("phDown", 0))
                    data.nutrientAdd = int(ml.get("nutrientAdd", 0))
                    data.refill = int(ml.get("refill", 0))
                    data.valueS = float(max(data.phUp, data.phDown, data.nutrientAdd, data.refill))
                    
                    AUTO_MODE_SOURCE = "ml"
                    ml_success = True
                    print(f"[AUTO MODE] ✓ ML SUCCESS → phUp:{data.phUp}, phDown:{data.phDown}, nutrient:{data.nutrientAdd}, refill:{data.refill}, model:{ml.get('model_version', 'unknown')}")
                else:
                    print(f"[AUTO MODE] ML service returned status {r.status_code}")
                    
            except (httpx.TimeoutException, httpx.ConnectError) as e:
                print(f"[AUTO MODE] ML timeout/connection error: {e}")
            except Exception as e:
                print(f"[AUTO MODE] ML prediction failed: {e}")

            # ==== FALLBACK TO RULE-BASED IF ML FAILS ====
            if not ml_success:
            print("[AUTO MODE] Using rule-based logic with priority system...")
            AUTO_MODE_SOURCE = "rule"

            # Initialize all actions to 0
            phUpSec = 0
            phDownSec = 0
            nutrientSec = 0
            refillSec = 0

            # ========================================
            # PRIORITY SYSTEM (prevents conflicts)
            # ========================================
            
            # PRIORITY 1: Critical Water Level (Safety First)
            # If water is critically low, ONLY refill (skip other actions)
            if wl < 1.2:
                refillSec = max(0, min(25, (1.2 - wl) * 20))
                print(f"[AUTO MODE] Priority 1: Critical water level → Refill only")
            
            # PRIORITY 2: High PPM Dilution
            # If PPM is high AND water level allows, dilute (skip pH/nutrient)
            elif ppm > 840 and wl < 2.5:
                refillSec = max(0, min(15, (ppm - 840) / 20))
                print(f"[AUTO MODE] Priority 2: High PPM → Dilute (skip pH/nutrient)")
            
            # PRIORITY 3: pH Adjustment
            # Only adjust pH if water is stable and PPM is not critical
            elif ph < 5.5 or ph > 6.5:
                if ph < 5.5:
                    phUpSec = max(0, min(12, (5.5 - ph) * 8))
                    print(f"[AUTO MODE] Priority 3: Low pH → pH Up")
                elif ph > 6.5:
                    phDownSec = max(0, min(12, (ph - 6.5) * 8))
                    print(f"[AUTO MODE] Priority 3: High pH → pH Down")
            
            # PRIORITY 4: Nutrient Addition
            # Only add nutrients if pH is stable (5.5-6.5) and PPM is low
            elif ppm < 560:
                nutrientSec = max(0, min(20, (560 - ppm) / 20))
                print(f"[AUTO MODE] Priority 4: Low PPM → Add Nutrient")
            
            # PRIORITY 5: Micro-adjustments (fine-tuning)
            # Only apply if no major action was taken
            else:
                # Micro pH adjustments (when pH is slightly off but within range)
                if 5.5 <= ph < 5.7:
                    phUpSec = 1
                    print(f"[AUTO MODE] Priority 5: Micro pH Up")
                elif 6.3 < ph <= 6.5:
                    phDownSec = 1
                    print(f"[AUTO MODE] Priority 5: Micro pH Down")
                
                # Micro nutrient (when PPM is slightly low but within range)
                elif 560 <= ppm < 650:
                    nutrientSec = 1
                    print(f"[AUTO MODE] Priority 5: Micro Nutrient")
                
                # Micro refill (when water is slightly low but not critical)
                elif 1.2 <= wl < 1.5:
                    refillSec = 1
                    print(f"[AUTO MODE] Priority 5: Micro Refill")
                
                else:
                    print(f"[AUTO MODE] All parameters stable → No action")

            # Set final values
            data.phUp = int(phUpSec)
            data.phDown = int(phDownSec)
            data.nutrientAdd = int(nutrientSec)
            data.refill = int(refillSec)
            data.valueS = float(max(phUpSec, phDownSec, nutrientSec, refillSec))
            
            print(f"[AUTO MODE] Final → phUp:{data.phUp}, phDown:{data.phDown}, nutrient:{data.nutrientAdd}, refill:{data.refill}, valueS:{data.valueS}")


        # INSERT FINAL ACTUATOR EVENT
        print(f"[ACTUATOR] Inserting to DB - auto:{data.auto}, manual:{data.manual}")
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
        print(f"[ACTUATOR] ✓ Inserted successfully with ID: {new_id}")

        return {
            "status": "ok", 
            "id": new_id,
            "data": {
                "phUp": int(data.phUp),
                "phDown": int(data.phDown),
                "nutrientAdd": int(data.nutrientAdd),
                "refill": int(data.refill),
                "valueS": float(data.valueS),
                "auto": int(data.auto),
                "manual": int(data.manual)
            }
        }

    except Exception as e:
        conn.rollback()
        raise HTTPException(500, str(e))

    finally:
        cur.close()
        release_connection(conn)


# BACKGROUND TASK: Try ML prediction and update event if successful
async def try_ml_prediction_and_update(deviceId: str, ppm: float, ph: float, 
                                       tempC: float, humidity: float, wl: float, 
                                       ingestTime: int):
    """
    This runs in the background and won't block the main response.
    If ML succeeds, it updates the actuator event that was just created.
    """
    global AUTO_MODE_SOURCE
    
    try:
        ml_payload = {
            "ppm": ppm,
            "ph": ph,
            "tempC": tempC,
            "humidity": humidity,
            "waterTemp": 0.0,
            "waterLevel": wl
        }

        # Increased timeout since this is non-blocking now
        async with httpx.AsyncClient(timeout=5.0) as client:
            r = await client.post("http://127.0.0.1:8000/ml/predict", json=ml_payload)

        if r.status_code == 200:
            ml = r.json()
            ml_phUp = ml.get("phUp", 0)
            ml_phDown = ml.get("phDown", 0)
            ml_nutrientAdd = ml.get("nutrientAdd", 0)
            ml_refill = ml.get("refill", 0)
            ml_valueS = float(max(ml_phUp, ml_phDown, ml_nutrientAdd, ml_refill))

            # Update the most recent actuator event with ML results
            conn = get_connection()
            cur = conn.cursor()
            
            try:
                cur.execute("""
                    UPDATE actuator_event
                    SET "phUp" = %s, "phDown" = %s, "nutrientAdd" = %s, 
                        "refill" = %s, "valueS" = %s
                    WHERE "deviceId" = %s AND "ingestTime" = %s;
                """, (
                    int(ml_phUp), int(ml_phDown), int(ml_nutrientAdd),
                    int(ml_refill), float(ml_valueS),
                    deviceId, ingestTime
                ))
                conn.commit()
                
                AUTO_MODE_SOURCE = "ml"
                print(f"[ML] Successfully updated actuator event for {deviceId} with ML predictions")
                
            except Exception as e:
                conn.rollback()
                print(f"[ML] Failed to update actuator event: {e}")
            finally:
                cur.close()
                release_connection(conn)

    except (httpx.TimeoutException, httpx.ConnectError) as e:
        print(f"[ML Background] Timeout/Connection error: {e}")
    except Exception as e:
        print(f"[ML Background] Unexpected error: {e}")

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
