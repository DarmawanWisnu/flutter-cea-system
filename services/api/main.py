from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from typing import Optional
from pydantic import BaseModel
from services.api.database import get_connection, release_connection, init_pool, run_migrations
from services.api.ml_service import ml_router
import uuid
import hashlib
import time
import json
import threading
import logging
import os
from datetime import datetime
from services.api import actuator

# Environment configuration
API_BASE_URL = os.getenv("API_BASE_URL", "http://localhost:8000")

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
handler_console = logging.StreamHandler()

# Use absolute path for log file (relative to project root)
import pathlib
_PROJECT_ROOT = pathlib.Path(__file__).parent.parent.parent
_LOG_PATH = _PROJECT_ROOT / "logs" / "api.log"
_LOG_PATH.parent.mkdir(parents=True, exist_ok=True)
handler_file = logging.FileHandler(_LOG_PATH)

formatter = CustomFormatter(datefmt='%Y-%m-%d %H:%M:%S')
handler_console.setFormatter(formatter)
handler_file.setFormatter(formatter)

logging.basicConfig(
    level=logging.INFO,
    handlers=[handler_console, handler_file]
)
logger = logging.getLogger(__name__)

# Suppress noisy loggers for clean output
logging.getLogger("uvicorn.access").setLevel(logging.WARNING)  # Hide 200 OK logs
logging.getLogger("httpx").setLevel(logging.WARNING)  # Hide HTTP request logs
logging.getLogger("httpcore").setLevel(logging.WARNING)  # Hide httpcore logs

app = FastAPI()

# CORS middleware for ngrok and mobile app compatibility
# Configurable origins via environment variable (comma-separated)
_cors_origins = os.getenv("CORS_ORIGINS", "*")
CORS_ORIGINS = ["*"] if _cors_origins == "*" else [o.strip() for o in _cors_origins.split(",")]

app.add_middleware(
    CORSMiddleware,
    allow_origins=CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(actuator.router, prefix="/actuator")
app.include_router(ml_router, prefix="/ml")


# Health check endpoint for connection testing
@app.get("/health")
def health_check():
    """Health check endpoint for testing connectivity."""
    return {"status": "ok", "message": "Server is running"}

# Auto mode scheduler config
AUTO_MODE_INTERVAL = 30  # seconds
_auto_mode_running = True


def _auto_mode_scheduler():
    """Background thread that triggers auto mode for enabled devices every 30s."""
    logger.info(f"[AUTO MODE] Scheduler started (interval: {AUTO_MODE_INTERVAL}s)")
    
    while _auto_mode_running:
        cycle_start = time.time()
        
        try:
            # Query devices with auto mode enabled
            conn = get_connection()
            cur = conn.cursor()
            
            try:
                cur.execute("""
                    SELECT "deviceId", "userId" FROM device_mode
                    WHERE "autoMode" = TRUE;
                """)
                devices = cur.fetchall()
            finally:
                cur.close()
                release_connection(conn)
            
            if devices:
                for device_id, user_id in devices:
                    _trigger_auto_actuator(device_id, user_id)
                
                # Add blank line after each cycle for visual separation
                logger.info("")  # Blank line between 30-second cycles
                    
        except Exception as e:
            logger.error(f"[AUTO MODE] Error in scheduler: {e}", exc_info=True)
        
        # Calculate remaining time to maintain exact interval
        elapsed = time.time() - cycle_start
        sleep_time = max(0, AUTO_MODE_INTERVAL - elapsed)
        
        # Sleep in small increments for graceful shutdown
        for _ in range(int(sleep_time * 10)):
            if not _auto_mode_running:
                break
            time.sleep(0.1)
    
    logger.info("[AUTO MODE] Scheduler stopped")


def _trigger_auto_actuator(device_id: str, user_id: str):
    """Trigger auto mode for a device and create notification."""
    import requests
    
    try:
        # Call actuator endpoint via HTTP
        payload = {"phUp": 0, "phDown": 0, "nutrientAdd": 0, "valueS": 0, "manual": 0, "auto": 1, "refill": 0}
        r = requests.post(
            f"{API_BASE_URL}/actuator/event?deviceId={device_id}&userId={user_id}",
            json=payload,
            timeout=10
        )
        
        if r.status_code == 200:
            result = r.json()
            data = result.get("data", {})
        else:
            logger.warning(f"[AUTO MODE] ✗ {device_id} → Status {r.status_code}: {r.text}")
            return
        
        # Build action summary
        actions = []
        if data.get('phUp', 0) > 0:
            actions.append(f"pH Up: {data['phUp']}s")
        if data.get('phDown', 0) > 0:
            actions.append(f"pH Down: {data['phDown']}s")
        if data.get('nutrientAdd', 0) > 0:
            actions.append(f"Nutrient: {data['nutrientAdd']}s")
        if data.get('refill', 0) > 0:
            actions.append(f"Refill: {data['refill']}s")
        
        # actuator.py logs the details (AUTO_MODE, ML_PREDICT, EXECUTED)
        
        # Create notification
        if user_id:
            conn = get_connection()
            cur = conn.cursor()
            try:
                msg = f"Auto adjustment: {', '.join(actions)}" if actions else "All parameters within safe limits"
                cur.execute("""
                    INSERT INTO notifications ("userId", "deviceId", level, title, message, "createdAt")
                    VALUES (%s, %s, %s, %s, %s, NOW());
                """, (user_id, device_id, "info", "Auto Mode", msg))
                conn.commit()
            except Exception as ne:
                conn.rollback()
                logger.error(f"[AUTO MODE] Failed to create notification: {ne}")
            finally:
                cur.close()
                release_connection(conn)
                
    except Exception as e:
        logger.error(f"[AUTO MODE] ✗ {device_id} → Error: {e}", exc_info=True)


@app.on_event("startup")
async def startup_event():
    """Run database migrations and start auto mode scheduler on startup."""
    init_pool()
    run_migrations()
    
    # Start auto mode scheduler in background thread
    scheduler_thread = threading.Thread(target=_auto_mode_scheduler, daemon=True)
    scheduler_thread.start()
    logger.info("[STARTUP] Auto mode scheduler started")

class TelemetryPayload(BaseModel):
    ppm: float
    ph: float
    tempC: float
    humidity: float
    waterTemp: float
    waterLevel: float

class KitPayload(BaseModel):
    id: str
    name: str
    userId: str

# KITS CRUD
@app.post("/kits")
def add_kit(payload: KitPayload):
    """Add kit to user's list. Creates kit if not exists, then links to user."""
    device_id = payload.id.strip()
    name = payload.name.strip()
    user_id = payload.userId.strip()
    
    # Validation
    if not device_id or len(device_id) < 5:
        raise HTTPException(400, "Invalid Kit ID: must be at least 5 characters")
    
    if not name or len(name) < 3:
        raise HTTPException(400, "Invalid Kit Name: must be at least 3 characters")
    
    if not user_id or len(user_id) < 8:
        raise HTTPException(400, "Invalid userId: must be at least 8 characters")
    
    conn = get_connection()
    cur = conn.cursor()

    try:
        # 1. Insert kit if not exists (global registry)
        cur.execute("""
            INSERT INTO kits (id, name)
            VALUES (%s, %s)
            ON CONFLICT (id) DO NOTHING;
        """, (device_id, name))
        
        # 2. Link user to kit (junction table)
        cur.execute("""
            INSERT INTO user_kits ("userId", "kitId", "addedAt")
            VALUES (%s, %s, NOW())
            ON CONFLICT ("userId", "kitId") DO NOTHING;
        """, (user_id, device_id))

        conn.commit()
        return {"status": "ok"}

    except Exception as e:
        conn.rollback()
        raise HTTPException(500, str(e))

    finally:
        cur.close()
        release_connection(conn)


@app.get("/kits")
def get_kits(userId: str):
    """Get kits for a specific user (via junction table)."""
    user_id = userId.strip()
    
    if not user_id or len(user_id) < 8:
        raise HTTPException(400, "Invalid userId: must be at least 8 characters")
    
    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            SELECT k.id, k.name, k."createdAt"
            FROM kits k
            JOIN user_kits uk ON k.id = uk."kitId"
            WHERE uk."userId" = %s
            ORDER BY uk."addedAt" DESC;
        """, (user_id,))
        rows = cur.fetchall()

        return [
            {"id": r[0], "name": r[1], "createdAt": r[2]}
            for r in rows
        ]

    except Exception as e:
        raise HTTPException(500, str(e))

    finally:
        cur.close()
        release_connection(conn)


@app.get("/kits/all")
def get_all_kits():
    """Get all kits from global registry (no user filter). For publisher/simulator use."""
    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute('SELECT id, name, "createdAt" FROM kits ORDER BY "createdAt" DESC;')
        rows = cur.fetchall()

        return [
            {"id": r[0], "name": r[1], "createdAt": r[2]}
            for r in rows
        ]

    except Exception as e:
        raise HTTPException(500, str(e))

    finally:
        cur.close()
        release_connection(conn)


@app.get("/kits/with-latest")
def get_kits_with_latest(userId: str):
    """Get kits with latest telemetry for a specific user."""
    user_id = userId.strip()
    
    if not user_id or len(user_id) < 8:
        raise HTTPException(400, "Invalid userId: must be at least 8 characters")
    
    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            SELECT k.id, k.name, k."createdAt"
            FROM kits k
            JOIN user_kits uk ON k.id = uk."kitId"
            WHERE uk."userId" = %s
            ORDER BY uk."addedAt" DESC;
        """, (user_id,))
        kits = cur.fetchall()

        results = []

        for kit in kits:
            kit_id = kit[0]

            cur.execute("""
                SELECT "payloadJson", "ingestTime"
                FROM telemetry
                WHERE "deviceId" = %s
                ORDER BY "ingestTime" DESC
                LIMIT 1;
            """, (kit_id,))

            row = cur.fetchone()

            if row:
                telemetry = map_payload(row[0])
                telemetry["ingestTime"] = row[1]
            else:
                telemetry = None

            results.append({
                "id": kit[0],
                "name": kit[1],
                "createdAt": kit[2],
                "telemetry": telemetry
            })

        return results

    except Exception as e:
        raise HTTPException(500, str(e))

    finally:
        cur.close()
        release_connection(conn)


@app.get("/kits/{kit_id}")
def get_kit(kit_id: str):
    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute('SELECT id, name, "createdAt" FROM kits WHERE id = %s;', (kit_id,))
        row = cur.fetchone()

        if not row:
            raise HTTPException(404, "Kit not found")

        return {"id": row[0], "name": row[1], "createdAt": row[2]}

    except Exception as e:
        raise HTTPException(500, str(e))

    finally:
        cur.close()
        release_connection(conn)


@app.delete("/kits/{kit_id}")
def delete_kit(kit_id: str, userId: str):
    """Remove kit from user's list (unlink, does not delete kit from registry)."""
    user_id = userId.strip()
    device_id = kit_id.strip()
    
    if not user_id or len(user_id) < 8:
        raise HTTPException(400, "Invalid userId: must be at least 8 characters")
    
    conn = get_connection()
    cur = conn.cursor()

    try:
        # Only delete from junction table (unlink user from kit)
        cur.execute("""
            DELETE FROM user_kits 
            WHERE "userId" = %s AND "kitId" = %s;
        """, (user_id, device_id))
        conn.commit()

        return {"status": "deleted"}

    except Exception as e:
        conn.rollback()
        raise HTTPException(500, str(e))

    finally:
        cur.close()
        release_connection(conn)

# HELPERS
def is_valid_device(device_id: str):
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("SELECT 1 FROM kits WHERE id = %s;", (device_id,))
    found = cur.fetchone()
    cur.close()
    release_connection(conn)
    return found is not None


def map_payload(value):
    if isinstance(value, dict):
        p = value
    else:
        try:
            p = json.loads(value)
        except:
            return {}

    return {
        "ppm": p.get("ppm"),
        "ph": p.get("ph"),
        "tempC": p.get("tempC"),
        "humidity": p.get("humidity"),
        "waterTemp": p.get("waterTemp"),
        "waterLevel": p.get("waterLevel"),
    }

# TELEMETRY INSERT
@app.post("/telemetry")
def insert_telemetry(deviceId: str, data: TelemetryPayload):
    deviceId = deviceId.strip()

    if not is_valid_device(deviceId):
        raise HTTPException(400, "Invalid deviceId. Register it via /kits first.")

    conn = get_connection()
    cur = conn.cursor()

    rowId = str(uuid.uuid4())
    ingestTime = int(time.time() * 1000)
    payload_dict = data.dict()

    payloadHash = hashlib.sha1(
        f"{deviceId}-{json.dumps(payload_dict)}".encode()
    ).hexdigest()

    try:
        cur.execute("""
            INSERT INTO telemetry (
            "rowId", "deviceId", "ingestTime", "payloadJson",
            ppm, ph, "tempC", humidity, "waterTemp", "waterLevel",
            "payloadHash"
            )
            VALUES (
                %s, %s, %s, %s,
                %s, %s, %s, %s, %s, %s,
                %s
            )
            ON CONFLICT ("payloadHash") DO NOTHING;
            """, (
                rowId, deviceId, ingestTime, json.dumps(payload_dict),
                data.ppm, data.ph, data.tempC, data.humidity,
                data.waterTemp, data.waterLevel,
                payloadHash
            ))


        conn.commit()
        return {"status": "ok", "duplicate": cur.rowcount == 0}

    except Exception as e:
        conn.rollback()
        raise HTTPException(500, str(e))

    finally:
        cur.close()
        release_connection(conn)

# TELEMETRY GET LATEST
@app.get("/telemetry/latest")
def get_latest(deviceId: str):
    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            SELECT "payloadJson", "ingestTime"
            FROM telemetry
            WHERE "deviceId" = %s
            ORDER BY "ingestTime" DESC
            LIMIT 1;
        """, (deviceId,))

        row = cur.fetchone()
        if not row:
            return {"message": "no data"}

        return {
            "deviceId": deviceId,
            "ingestTime": row[1],
            "data": map_payload(row[0])
        }

    except Exception as e:
        raise HTTPException(500, str(e))

    finally:
        cur.close()
        release_connection(conn)

# TELEMETRY GET HISTORY
@app.get("/telemetry/history")
def get_history(deviceId: str, days: int = 7, limit: int = 10000):
    """
    Get telemetry history for a device.
    - days: How many days back to fetch (max 7)
    - limit: Max entries to return (default 10000, for safety)
    """
    days = max(1, min(days, 7))
    limit = max(1, min(limit, 50000))  # Safety cap
    
    # Calculate timestamp for N days ago
    cutoff_time = int((time.time() - (days * 24 * 60 * 60)) * 1000)

    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            SELECT "payloadJson", "ingestTime"
            FROM telemetry
            WHERE "deviceId" = %s AND "ingestTime" >= %s
            ORDER BY "ingestTime" DESC
            LIMIT %s;
        """, (deviceId, cutoff_time, limit))

        rows = cur.fetchall()

        return {
            "deviceId": deviceId,
            "days": days,
            "count": len(rows),
            "items": [
                {"ingestTime": r[1], "data": map_payload(r[0])}
                for r in rows
            ]
        }

    except Exception as e:
        raise HTTPException(500, str(e))

    finally:
        cur.close()
        release_connection(conn)


# ============== DEVICE MODE ENDPOINTS ==============

class DeviceModePayload(BaseModel):
    userId: str
    deviceId: str
    autoMode: bool


@app.post("/device/mode")
def set_device_mode(payload: DeviceModePayload):
    """Set auto/manual mode for a user's device."""
    # Validation: userId and deviceId must not be empty
    user_id = payload.userId.strip()
    device_id = payload.deviceId.strip()
    
    if not user_id or len(user_id) < 8:
        raise HTTPException(400, "Invalid userId: must be at least 8 characters")
    
    if not device_id or len(device_id) < 5:
        raise HTTPException(400, "Invalid deviceId: must be at least 5 characters")
    
    # Prevent test/placeholder userIds
    forbidden_patterns = ['test', 'firebase_user', 'dummy', 'example', 'placeholder']
    if any(pattern in user_id.lower() for pattern in forbidden_patterns):
        raise HTTPException(400, f"Invalid userId: cannot contain test/placeholder patterns")
    
    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            INSERT INTO device_mode ("userId", "deviceId", "autoMode", "updatedAt")
            VALUES (%s, %s, %s, NOW())
            ON CONFLICT ("userId", "deviceId")
            DO UPDATE SET "autoMode" = EXCLUDED."autoMode", "updatedAt" = NOW();
        """, (user_id, device_id, payload.autoMode))

        conn.commit()
        return {"status": "ok", "autoMode": payload.autoMode}

    except Exception as e:
        conn.rollback()
        raise HTTPException(500, str(e))

    finally:
        cur.close()
        release_connection(conn)



@app.get("/device/mode")
def get_device_mode(userId: str, deviceId: str):
    """Get current mode for a user's device."""
    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            SELECT "autoMode" FROM device_mode
            WHERE "userId" = %s AND "deviceId" = %s;
        """, (userId.strip(), deviceId.strip()))

        row = cur.fetchone()
        if not row:
            return {"autoMode": False}  # Default to manual

        return {"autoMode": row[0]}

    except Exception as e:
        raise HTTPException(500, str(e))

    finally:
        cur.close()
        release_connection(conn)


@app.get("/device/auto-enabled")
def get_auto_enabled_devices():
    """Get all devices with auto mode enabled (for subscriber timer).
    Returns list of {deviceId, userId} for each enabled device.
    """
    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            SELECT "deviceId", "userId" FROM device_mode
            WHERE "autoMode" = TRUE;
        """)

        rows = cur.fetchall()
        return {
            "devices": [{"deviceId": r[0], "userId": r[1]} for r in rows]
        }

    except Exception as e:
        raise HTTPException(500, str(e))

    finally:
        cur.close()
        release_connection(conn)


# ============== USER PREFERENCE ENDPOINTS ==============

class UserPreferencePayload(BaseModel):
    userId: str
    selectedKitId: str


@app.post("/user/preference")
def set_user_preference(payload: UserPreferencePayload):
    """Set user's selected kit preference."""
    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            INSERT INTO user_preference ("userId", "selectedKitId", "updatedAt")
            VALUES (%s, %s, NOW())
            ON CONFLICT ("userId")
            DO UPDATE SET "selectedKitId" = EXCLUDED."selectedKitId", "updatedAt" = NOW();
        """, (payload.userId.strip(), payload.selectedKitId.strip()))

        conn.commit()
        return {"status": "ok", "selectedKitId": payload.selectedKitId}

    except Exception as e:
        conn.rollback()
        raise HTTPException(500, str(e))

    finally:
        cur.close()
        release_connection(conn)


@app.get("/user/preference")
def get_user_preference(userId: str):
    """Get user's selected kit preference."""
    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            SELECT "selectedKitId" FROM user_preference
            WHERE "userId" = %s;
        """, (userId.strip(),))

        row = cur.fetchone()
        if not row or row[0] is None:
            return {"selectedKitId": None}

        return {"selectedKitId": row[0]}

    except Exception as e:
        raise HTTPException(500, str(e))

    finally:
        cur.close()
        release_connection(conn)


# ============== NOTIFICATION ENDPOINTS ==============

class NotificationPayload(BaseModel):
    userId: str
    deviceId: str
    level: str  # 'info', 'warning', 'urgent'
    title: str
    message: str


@app.post("/notifications")
def create_notification(payload: NotificationPayload):
    """Create a new notification."""
    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            INSERT INTO notifications ("userId", "deviceId", level, title, message, "createdAt")
            VALUES (%s, %s, %s, %s, %s, NOW())
            RETURNING id, "createdAt";
        """, (payload.userId.strip(), payload.deviceId.strip(), 
              payload.level.strip(), payload.title.strip(), payload.message.strip()))

        row = cur.fetchone()
        conn.commit()
        
        return {
            "status": "ok",
            "id": row[0],
            "createdAt": row[1].isoformat() if row[1] else None
        }

    except Exception as e:
        conn.rollback()
        raise HTTPException(500, str(e))

    finally:
        cur.close()
        release_connection(conn)


@app.get("/notifications")
def get_notifications(userId: str, level: Optional[str] = None, days: int = 7, limit: int = 100):
    """Get notifications with optional filters."""
    conn = get_connection()
    cur = conn.cursor()

    try:
        query = """
            SELECT id, "deviceId", level, title, message, "isRead", "createdAt"
            FROM notifications
            WHERE "userId" = %s
            AND "createdAt" >= NOW() - INTERVAL '%s days'
        """
        params = [userId.strip(), days]

        if level and level.strip().lower() != 'all':
            query += ' AND level = %s'
            params.append(level.strip().lower())

        query += ' ORDER BY "createdAt" DESC LIMIT %s'
        params.append(limit)

        cur.execute(query, params)
        rows = cur.fetchall()

        return {
            "items": [
                {
                    "id": r[0],
                    "deviceId": r[1],
                    "level": r[2],
                    "title": r[3],
                    "message": r[4],
                    "isRead": r[5],
                    "createdAt": r[6].isoformat() if r[6] else None
                }
                for r in rows
            ]
        }

    except Exception as e:
        raise HTTPException(500, str(e))

    finally:
        cur.close()
        release_connection(conn)


@app.put("/notifications/{notification_id}/read")
def mark_notification_read(notification_id: int):
    """Mark a notification as read."""
    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            UPDATE notifications SET "isRead" = TRUE WHERE id = %s;
        """, (notification_id,))

        conn.commit()
        return {"status": "ok"}

    except Exception as e:
        conn.rollback()
        raise HTTPException(500, str(e))

    finally:
        cur.close()
        release_connection(conn)


@app.put("/notifications/mark-all-read")
def mark_all_notifications_read(userId: str):
    """Mark all notifications as read for a user."""
    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            UPDATE notifications SET "isRead" = TRUE WHERE "userId" = %s;
        """, (userId.strip(),))

        conn.commit()
        return {"status": "ok"}

    except Exception as e:
        conn.rollback()
        raise HTTPException(500, str(e))

    finally:
        cur.close()
        release_connection(conn)


@app.delete("/notifications/{notification_id}")
def delete_notification(notification_id: int):
    """Delete a single notification."""
    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            DELETE FROM notifications WHERE id = %s;
        """, (notification_id,))

        conn.commit()
        return {"status": "ok"}

    except Exception as e:
        conn.rollback()
        raise HTTPException(500, str(e))

    finally:
        cur.close()
        release_connection(conn)


@app.delete("/notifications")
def clear_all_notifications(userId: str):
    """Delete all notifications for a user."""
    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            DELETE FROM notifications WHERE "userId" = %s;
        """, (userId.strip(),))

        conn.commit()
        return {"status": "ok"}

    except Exception as e:
        conn.rollback()
        raise HTTPException(500, str(e))

    finally:
        cur.close()
        release_connection(conn)


# SERVER RUNNER
if __name__ == "__main__":
    from services.api.database import init_pool, run_migrations
    init_pool()
    run_migrations()

    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True
    )
