from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from services.ml.predictor import predict_from_dict
from typing import Optional
from services.api.database import get_connection, release_connection
import time
import json

ml_router = APIRouter()

class TelemetryPayload(BaseModel):
    ppm: Optional[float] = 0.0
    ph: Optional[float] = 0.0
    tempC: Optional[float] = 0.0
    humidity: Optional[float] = 0.0
    waterTemp: Optional[float] = 0.0
    waterLevel: Optional[float] = 0.0

DEFAULT_CLAMPS = {
    "phUp": (0, 300),
    "phDown": (0, 300),
    "nutrientAdd": (0, 600),
    "refill": (0, 600)
}

@ml_router.post("/predict")
def ml_predict(payload: TelemetryPayload):
    data = payload.dict()
    try:
        result = predict_from_dict(data, clamp_limits=DEFAULT_CLAMPS)
    except Exception as e:
        import logging
        logger = logging.getLogger(__name__)
        logger.error(f"[ML Service] Prediction error: {type(e).__name__}: {str(e)}")
        import traceback
        logger.error(f"[ML Service] Traceback:\n{traceback.format_exc()}")
        raise HTTPException(status_code=500, detail=str(e))

    # optional: log prediction
    try:
        conn = get_connection()
        cur = conn.cursor()
        ts = int(time.time()*1000)
        cur.execute("""
            INSERT INTO ml_prediction_log ("deviceId", "predictTime", "payloadJson", "predictJson")
            VALUES (%s, %s, %s, %s);
        """, ("__unknown__", ts, json.dumps(data), json.dumps(result)))
        conn.commit()
        cur.close()
        release_connection(conn)
    except Exception:
        pass

    return result
