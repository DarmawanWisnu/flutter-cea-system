from fastapi import FastAPI, HTTPException
from typing import Optional
from pydantic import BaseModel
from dotenv import load_dotenv
from database import get_connection, release_connection
import uuid
import hashlib
import time
import json
import actuator

load_dotenv()

app = FastAPI()
app.include_router(actuator.router, prefix="/actuator")

# TELEMETRY PAYLOAD
class TelemetryPayload(BaseModel):
    ppm: float
    ph: float
    tempC: float
    humidity: float
    waterTemp: float
    waterLevel: float

# INSERT TELEMETRY
@app.post("/telemetry")
def insert_telemetry(device_id: str, data: TelemetryPayload):
    device_id = device_id.strip()

    conn = get_connection()
    cur = conn.cursor()

    row_id = str(uuid.uuid4())
    ingest_time = int(time.time() * 1000)
    json_str = json.dumps(data.dict())
    payload_hash = hashlib.sha1(json_str.encode()).hexdigest()

    try:
        cur.execute("""
            INSERT INTO telemetry (
                row_id, device_id, ingest_time, payload_json,
                ppm, ph, tempC, humidity, waterTemp, waterLevel,
                payload_hash
            )
            VALUES (
                %s, %s, %s, %s,
                %s, %s, %s, %s, %s, %s,
                %s
            )
            ON CONFLICT (payload_hash) DO NOTHING;
        """, (
            row_id, device_id, ingest_time, json_str,
            data.ppm, data.ph, data.tempC, data.humidity, data.waterTemp, data.waterLevel,
            payload_hash
        ))

        conn.commit()
        return {"status": "ok", "duplicate": cur.rowcount == 0}

    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        cur.close()
        release_connection(conn)

# CLEAN MAPPER — camelCase only
def map_payload(p):
    return {
        "ppm": p.get("ppm"),
        "ph": p.get("ph"),
        "tempC": p.get("tempC"),
        "humidity": p.get("humidity"),
        "waterTemp": p.get("waterTemp"),
        "waterLevel": p.get("waterLevel"),
    }

# LATEST
@app.get("/telemetry/latest")
def get_latest(device_id: str):
    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            SELECT payload_json, ingest_time
            FROM telemetry
            WHERE device_id = %s
            ORDER BY ingest_time DESC
            LIMIT 1;
        """, (device_id,))

        row = cur.fetchone()
        if not row:
            return {"message": "no data"}

        mapped = map_payload(row[0])

        return {
            "device_id": device_id,
            "ingest_time": row[1],
            "data": mapped
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        cur.close()
        conn.close()

# HISTORY
@app.get("/telemetry/history")
def get_history(device_id: str, limit: int = 50):
    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            SELECT payload_json, ingest_time
            FROM telemetry
            WHERE device_id = %s
            ORDER BY ingest_time DESC
            LIMIT %s;
        """, (device_id, limit))

        rows = cur.fetchall()

        items = [
            {
                "ingest_time": r[1],
                "data": map_payload(r[0])
            }
            for r in rows
        ]

        return {
            "device_id": device_id,
            "count": len(items),
            "items": items
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        cur.close()
        conn.close()

# RUN UVICORN
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True
    )
