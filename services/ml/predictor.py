import os
import joblib
import numpy as np
from threading import Lock
import json

MODEL_REGISTRY = "model_registry"

_TELEMETRY_FEATURES = ["ppm", "ph", "tempC", "humidity", "waterTemp", "waterLevel"]
_TARGETS = ["phUp", "phDown", "nutrientAdd", "refill"]

_model = None
_scaler = None
_model_meta = None
_lock = Lock()

def _load_latest():
    global _model, _scaler, _model_meta
    with _lock:
        if _model is not None and _scaler is not None:
            return

        latest_marker = os.path.join(MODEL_REGISTRY, "LATEST")
        if os.path.exists(latest_marker):
            with open(latest_marker, "r") as f:
                version = f.read().strip()
            version_dir = os.path.join(MODEL_REGISTRY, version)
        else:
            candidates = [
                os.path.join(MODEL_REGISTRY, d)
                for d in os.listdir(MODEL_REGISTRY)
                if d.startswith("v")
            ]
            if not candidates:
                raise RuntimeError("No model found in registry.")
            version_dir = sorted(candidates, key=os.path.getmtime)[-1]
            version = os.path.basename(version_dir)

        model_path = os.path.join(version_dir, "model.pkl")
        scaler_path = os.path.join(version_dir, "scaler.pkl")
        meta_path = os.path.join(version_dir, "metadata.json")

        _model = joblib.load(model_path)
        _scaler = joblib.load(scaler_path) if os.path.exists(scaler_path) else None
        _model_meta = json.load(open(meta_path)) if os.path.exists(meta_path) else {"version": version}

        print(f"[predictor] loaded model {version}")

def predict_from_dict(payload: dict, clamp_limits=None):
    if _model is None or _scaler is None:
        _load_latest()

    x = []
    for k in _TELEMETRY_FEATURES:
        v = payload.get(k, 0.0)
        try:
            x.append(float(v))
        except:
            x.append(0.0)

    X = np.array(x).reshape(1, -1)
    Xs = _scaler.transform(X) if _scaler else X

    y_pred = _model.predict(Xs).flatten().tolist()

    out = {}
    for i, t in enumerate(_TARGETS):
        val = float(y_pred[i]) if i < len(y_pred) else 0.0
        if clamp_limits and t in clamp_limits:
            lo, hi = clamp_limits[t]
            val = max(lo, min(hi, val))
        out[t] = int(round(val))

    out["model_version"] = _model_meta.get("version")
    return out
