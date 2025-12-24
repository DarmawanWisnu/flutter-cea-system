from fastapi import APIRouter, HTTPException
from fastapi import BackgroundTasks
from pydantic import BaseModel, Field
from services.api.database import get_connection, release_connection
import time
import httpx
import logging

# Custom formatter to show level only for ERROR
class CustomFormatter(logging.Formatter):
    def format(self, record):
        if record.levelno == logging.ERROR:
            # Show ERROR level
            return f"{self.formatTime(record, self.datefmt)} | ERROR | {record.getMessage()}"
        else:
            # Hide level for INFO/WARNING
            return f"{self.formatTime(record, self.datefmt)} | {record.getMessage()}"

# Configure logging with custom formatter
handler = logging.StreamHandler()
formatter = CustomFormatter(datefmt='%Y-%m-%d %H:%M:%S')
handler.setFormatter(formatter)

logging.basicConfig(
    level=logging.INFO,
    handlers=[handler]
)
logger = logging.getLogger(__name__)

router = APIRouter()
AUTO_MODE_SOURCE = "rule"

# COOLDOWN SETTINGS
COOLDOWN_SECONDS = 180

CRITICAL_THRESHOLDS = {
    "ph": {"min": 5.0, "max": 7.0},
    "ppm": {"min": 400, "max": 1200},
    "waterLevel": {"min": 1.0}
}

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
        conn.commit()
        logger.info("[DB] actuator_event migration executed (from actuator.py).")
    except Exception as e:
        conn.rollback()
        logger.error(f"[DB] actuator_event migration error (from actuator.py): {e}")
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


def is_critical(ph, ppm, water_level):
    """Check if telemetry values are in critical range (bypass cooldown)."""
    critical = False
    
    reasons = []
    
    if ph < CRITICAL_THRESHOLDS["ph"]["min"] or ph > CRITICAL_THRESHOLDS["ph"]["max"]:
        critical = True
        reasons.append(f"pH={ph:.2f}")
    
    if ppm < CRITICAL_THRESHOLDS["ppm"]["min"] or ppm > CRITICAL_THRESHOLDS["ppm"]["max"]:
        critical = True
        reasons.append(f"PPM={ppm:.1f}")
    
    if water_level < CRITICAL_THRESHOLDS["waterLevel"]["min"]:
        critical = True
        reasons.append(f"WL={water_level:.1f}")
    
    if critical:
        logger.warning(f"CRITICAL_BYPASS | {', '.join(reasons)}")
    
    return critical


def check_cooldown(device_id, predictions):
    """
    Check if any actions are blocked by cooldown.
    Returns dict with blocked actions set to 0.
    """
    conn = get_connection()
    cur = conn.cursor()
    
    current_time = int(time.time() * 1000)
    result = predictions.copy()
    blocked_actions = []
    
    try:
        for action_type in ["phUp", "phDown", "nutrientAdd", "refill"]:
            # Only check if action was going to be executed
            if predictions.get(action_type, 0) > 0:
                cur.execute("""
                    SELECT "lastTime" FROM actuator_cooldown
                    WHERE "deviceId" = %s AND "actionType" = %s;
                """, (device_id, action_type))
                
                row = cur.fetchone()
                if row:
                    last_time = row[0]
                    time_diff_sec = (current_time - last_time) / 1000.0
                    
                    if time_diff_sec < COOLDOWN_SECONDS:
                        # Cooldown still active - block this action
                        result[action_type] = 0
                        remaining = int(COOLDOWN_SECONDS - time_diff_sec)
                        blocked_actions.append(f"{action_type}:{remaining}s")
    
    except Exception as e:
        logger.error(f"COOLDOWN_ERROR | error={str(e)}")
    finally:
        cur.close()
        release_connection(conn)
    
    # Log all blocked actions in one line
    if blocked_actions:
        logger.info(f"COOLDOWN_BLOCK | {' '.join(blocked_actions)}")
        
        # Recalculate valueS based on remaining actions
        result["valueS"] = float(max(
            result.get("phUp", 0),
            result.get("phDown", 0),
            result.get("nutrientAdd", 0),
            result.get("refill", 0)
        ))
    
    return result


def update_cooldown(device_id, predictions):
    """Update cooldown timestamps for executed actions."""
    conn = get_connection()
    cur = conn.cursor()
    
    current_time = int(time.time() * 1000)
    
    try:
        for action_type in ["phUp", "phDown", "nutrientAdd", "refill"]:
            action_value = predictions.get(action_type, 0)
            
            # Only update if action was executed (non-zero)
            if action_value > 0:
                cur.execute("""
                    INSERT INTO actuator_cooldown ("deviceId", "actionType", "lastTime", "lastValue")
                    VALUES (%s, %s, %s, %s)
                    ON CONFLICT ("deviceId", "actionType")
                    DO UPDATE SET "lastTime" = EXCLUDED."lastTime", "lastValue" = EXCLUDED."lastValue";
                """, (device_id, action_type, current_time, float(action_value)))
        
        conn.commit()
    
    except Exception as e:
        conn.rollback()
        logger.error(f"COOLDOWN_UPDATE_ERROR | error={str(e)}")
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
async def insert_event(deviceId: str, data: ActuatorEvent, background_tasks: BackgroundTasks, userId: str = None):
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
            # Ambil telemetry terbaru
            cur.execute("""
                SELECT ppm, ph, "tempC", humidity, "waterTemp", "waterLevel"
                FROM telemetry
                WHERE "deviceId" = %s
                ORDER BY "ingestTime" DESC
                LIMIT 1;
            """, (deviceId,))
            t = cur.fetchone()

            if t:
                ppm, ph, tempC, humidity, waterTemp, wl = t
                logger.info(f"AUTO_MODE | pH={ph:.2f} PPM={ppm:.1f} temp={tempC:.1f}C water_level={wl:.1f}")
            else:
                ppm, ph, tempC, humidity, waterTemp, wl = (0, 0, 0, 0, 0, 0)
                logger.warning(f"AUTO_MODE | status=no_telemetry_data")

            # TRY MACHINE LEARNING FIRST (SYNCHRONOUS WITH TIMEOUT)
            ml_success = False
            try:
                ml_payload = {
                    "ppm": ppm,
                    "ph": ph,
                    "tempC": tempC,
                    "humidity": humidity,
                    "waterTemp": waterTemp,
                    "waterLevel": wl
                }
                
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
                    logger.info(f"ML_PREDICT | phUp={data.phUp}s phDown={data.phDown}s nutrient={data.nutrientAdd}s refill={data.refill}s")
                else:
                    logger.warning(f"ML_ERROR | http_status={r.status_code}")
                    
            except (httpx.TimeoutException, httpx.ConnectError):
                logger.warning(f"ML_TIMEOUT | fallback=rule_based")
            except Exception as e:
                logger.error(f"ML_ERROR | error={str(e)}")

            # FALLBACK TO RULE-BASED IF ML FAILS
            if not ml_success:
                AUTO_MODE_SOURCE = "rule"

                # Constants
                PH_MIN, PH_MAX = 5.5, 6.5
                PPM_MIN, PPM_MAX = 560, 840
                WL_MIN, WL_MAX = 1.2, 2.5
                TANK_VOLUME_ML = 10000  # 10 Liters
                PUMP_FLOW_MLS = 1.58  # ml per second

                # Initialize all actions to 0
                phUpSec = 0
                phDownSec = 0
                nutrientSec = 0
                refillSec = 0
                actions_taken = []

                # pH Control (P-control with Kp=1)
                # 1 pH change = 50 seconds (~80ml @ 1.58ml/s)
                if ph < PH_MIN:
                    error = PH_MIN - ph
                    phUpSec = min(50, error * 50)
                    actions_taken.append(f"UP:{phUpSec:.0f}s")
                elif ph > PH_MAX:
                    error = ph - PH_MAX
                    phDownSec = min(50, error * 50)
                    actions_taken.append(f"DN:{phDownSec:.0f}s")
                
                # Nutrient Addition (100 ppm = 63 seconds)
                if ppm < PPM_MIN:
                    error = PPM_MIN - ppm
                    nutrientSec = min(63, (error / 100) * 63)
                    actions_taken.append(f"NUT:{nutrientSec:.0f}s")
                
                # Refill / Dilution Control
                if wl < WL_MIN:
                    # Critical water level - fixed 60 seconds
                    refillSec = 60
                    actions_taken.append(f"REF:{refillSec}s")
                elif ppm > PPM_MAX and wl < WL_MAX:
                    # PPM too high - use dilution formula: V_air = V × (C_i/C_f - 1)
                    v_air_ml = TANK_VOLUME_ML * ((ppm / PPM_MAX) - 1)
                    refillSec = min(120, v_air_ml / PUMP_FLOW_MLS)
                    actions_taken.append(f"REF:{refillSec:.0f}s")
                
                if actions_taken:
                    logger.info(f"RULE_BASED | {' '.join(actions_taken)}")
                else:
                    logger.info(f"RULE_BASED | status=stable no_action_needed")

                # Set final values
                data.phUp = int(phUpSec)
                data.phDown = int(phDownSec)
                data.nutrientAdd = int(nutrientSec)
                data.refill = int(refillSec)
                data.valueS = float(max(phUpSec, phDownSec, nutrientSec, refillSec))

            # APPLY COOLDOWN
            bypass_cooldown = is_critical(ph, ppm, wl)
            
            if not bypass_cooldown:
                # Package predictions for cooldown check
                predictions = {
                    "phUp": data.phUp,
                    "phDown": data.phDown,
                    "nutrientAdd": data.nutrientAdd,
                    "refill": data.refill,
                    "valueS": data.valueS
                }
                
                # Check cooldown and get filtered predictions
                filtered = check_cooldown(deviceId, predictions)
                
                # Update data with filtered values
                data.phUp = int(filtered["phUp"])
                data.phDown = int(filtered["phDown"])
                data.nutrientAdd = int(filtered["nutrientAdd"])
                data.refill = int(filtered["refill"])
                data.valueS = float(filtered["valueS"])
            # No need to log bypass here, already logged in is_critical()

            # Update cooldown timestamps for executed actions
            cooldown_updates = {
                "phUp": data.phUp,
                "phDown": data.phDown,
                "nutrientAdd": data.nutrientAdd,
                "refill": data.refill
            }
            update_cooldown(deviceId, cooldown_updates)


        # INSERT FINAL ACTUATOR EVENT
        # Retry logic for sequence issues
        max_retries = 2
        for attempt in range(max_retries):
            try:
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
                
                # Log final result with source  
                if data.auto == 1:
                    source = "ml" if AUTO_MODE_SOURCE == "ml" else "rule_based"
                    user_info = f"user={userId}" if userId else "user=unknown"
                    logger.info(f"EXECUTED | device={deviceId} {user_info} source={source} event_id={new_id}")
                    logger.info(f"{'='*60}")
                
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
                
            except Exception as insert_error:
                # Check if it's a unique violation (sequence issue)
                if "UniqueViolation" in str(type(insert_error).__name__) or "duplicate key" in str(insert_error):
                    if attempt < max_retries - 1:
                        logger.debug(f"[DB] Sequence issue - retrying (attempt {attempt + 1}/{max_retries})")
                        conn.rollback()
                        
                        # Fix the sequence
                        try:
                            cur.execute("""
                                SELECT setval(
                                    pg_get_serial_sequence('actuator_event', 'id'),
                                    COALESCE((SELECT MAX(id) FROM actuator_event), 0) + 1,
                                    false
                                );
                            """)
                            conn.commit()
                        except Exception as seq_error:
                            logger.error(f"[DB] Sequence reset failed: {seq_error}")
                            conn.rollback()
                        
                        # Retry the insert
                        continue
                    else:
                        # Max retries reached
                        raise insert_error
                else:
                    # Not a sequence issue, raise immediately
                    raise insert_error

    except Exception as e:
        conn.rollback()
        logger.error(f"[DB] Insert failed for {deviceId}: {type(e).__name__}: {str(e)}")
        raise HTTPException(500, f"Database error: {str(e)}")

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
                logger.debug(f"[ML] Background update completed for {deviceId}")
                
            except Exception as e:
                conn.rollback()
                logger.error(f"[ML] Background update failed for {deviceId}: {e}")
            finally:
                cur.close()
                release_connection(conn)

    except (httpx.TimeoutException, httpx.ConnectError):
        logger.debug(f"[ML] Background connection timeout for {deviceId}")
    except Exception as e:
        logger.error(f"[ML] Background error for {deviceId}: {e}")

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
