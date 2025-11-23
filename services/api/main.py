from fastapi import FastAPI, HTTPException
from typing import Optional
from pydantic import BaseModel
from dotenv import load_dotenv
from database import get_connection, release_connection
import uuid
import hashlib
import time
import json

load_dotenv()

app = FastAPI()

# Telemetry
class TelemetryPayload(BaseModel):
    id: Optional[int] = None
    ppm: float
    ph: float
    tempC: float
    humidity: float
    waterTemp: float
    waterLevel: float
    pH_reducer: bool = False
    add_water: bool = False
    nutrients_adder: bool = False
    humidifier: bool = False
    ex_fan: bool = False
    isDefault: bool = False

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
                id, ppm, ph, tempC, humidity, waterTemp, waterLevel,
                pH_reducer, add_water, nutrients_adder, humidifier, ex_fan, isDefault,
                payload_hash
            )
            VALUES (
                %s, %s, %s, %s,
                %s, %s, %s, %s, %s, %s, %s,
                %s, %s, %s, %s, %s, %s,
                %s
            )
            ON CONFLICT (payload_hash) DO NOTHING;
        """, (
            row_id, device_id, ingest_time, json_str,
            data.id, data.ppm, data.ph, data.tempC, data.humidity, data.waterTemp, data.waterLevel,
            data.pH_reducer, data.add_water, data.nutrients_adder, data.humidifier, data.ex_fan, data.isDefault,
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

# GET LATEST DATA
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

        payload = row[0]      # SUDAH DICT, JANGAN json.loads()

        return {
            "device_id": device_id,
            "ingest_time": row[1],
            "data": payload
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        cur.close()
        conn.close()


# GET HISTORY
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

        data = [
            {
                "ingest_time": r[1],
                "data": r[0]     # JSONB → otomatis dict, JANGAN json.loads()
            }
            for r in rows
        ]

        return {
            "device_id": device_id,
            "count": len(data),
            "items": data
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        cur.close()
        conn.close()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True
    )
