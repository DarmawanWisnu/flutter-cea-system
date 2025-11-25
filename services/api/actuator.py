from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from database import get_connection, release_connection
import time
import uuid

router = APIRouter()

class ActuatorEvent(BaseModel):
    action: str
    value: float = 0

@router.post("/event")
def insert_event(device_id: str, data: ActuatorEvent):
    conn = get_connection()
    cur = conn.cursor()

    row_id = str(uuid.uuid4())
    ingest_time = int(time.time() * 1000)

    try:
        cur.execute("""
            INSERT INTO actuator_event (row_id, device_id, ingest_time, action, value)
            VALUES (%s, %s, %s, %s, %s)
        """, (
            row_id, device_id, ingest_time, data.action, data.value
        ))

        conn.commit()
        return {"status": "ok"}

    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        cur.close()
        release_connection(conn)

@router.get("/history")
def get_event_history(device_id: str, limit: int = 50):
    conn = get_connection()
    cur = conn.cursor()

    try:
        cur.execute("""
            SELECT action, value, ingest_time
            FROM actuator_event
            WHERE device_id = %s
            ORDER BY ingest_time DESC
            LIMIT %s
        """, (device_id, limit))

        rows = cur.fetchall()

        return [
            {
                "action": r[0],
                "value": r[1],
                "ingest_time": r[2]
            }
            for r in rows
        ]

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        cur.close()
        release_connection(conn)
