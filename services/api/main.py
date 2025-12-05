from fastapi import FastAPI, HTTPException
from typing import Optional
from pydantic import BaseModel
from services.api.database import get_connection, release_connection
from services.api.ml_service import ml_router
import uuid
import hashlib
import time
import json
from services.api import actuator

app = FastAPI()
app.include_router(actuator.router, prefix="/actuator")
app.include_router(ml_router, prefix="/ml")

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

# KITS CRUD
@app.post("/kits")
def add_kit(payload: KitPayload):
    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            INSERT INTO kits (id, name)
            VALUES (%s, %s)
            ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;
        """, (payload.id.strip(), payload.name.strip()))

        conn.commit()
        return {"status": "ok"}

    except Exception as e:
        conn.rollback()
        raise HTTPException(500, str(e))

    finally:
        cur.close()
        release_connection(conn)


@app.get("/kits")
def get_kits():
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


@app.get("/kits/with-latest")
def get_kits_with_latest():
    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute('SELECT id, name, "createdAt" FROM kits ORDER BY "createdAt" DESC;')
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


@app.delete("/kits/{kit_id}")
def delete_kit(kit_id: str):
    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute("DELETE FROM kits WHERE id = %s;", (kit_id,))
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
    - days: How many days back to fetch (default 7, max 30)
    - limit: Max entries to return (default 10000, for safety)
    """
    days = max(1, min(days, 30))  # 1-30 days
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
