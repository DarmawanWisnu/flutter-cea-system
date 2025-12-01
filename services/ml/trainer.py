import os
import json
import joblib
import datetime
import numpy as np
from sklearn.ensemble import RandomForestRegressor
from sklearn.multioutput import MultiOutputRegressor
from sklearn.metrics import mean_absolute_error, mean_squared_error
from dataset_loader import load_joined_dataset
from preprocessing import prepare_xy, split_and_scale

MODEL_DIR = "model_registry"

def train_and_save(limit=None, device_id=None, n_estimators=100, random_state=42):
    print("[trainer] loading dataset...")
    df = load_joined_dataset(limit=limit, device_id=device_id)
    if df.empty:
        raise RuntimeError("No training data available.")

    X, y = prepare_xy(df)
    X_train_s, X_val_s, y_train, y_val, scaler = split_and_scale(
        X, y, scaler_path=os.path.join(MODEL_DIR, "scaler.pkl")
    )

    print("[trainer] training RandomForest...")
    base = RandomForestRegressor(
        n_estimators=n_estimators, n_jobs=-1, random_state=random_state
    )
    model = MultiOutputRegressor(base)
    model.fit(X_train_s, y_train)

    y_pred = model.predict(X_val_s)
    maes = mean_absolute_error(y_val, y_pred, multioutput='raw_values')
    rmses = np.sqrt(mean_squared_error(y_val, y_pred, multioutput='raw_values'))

    ts = datetime.datetime.utcnow().strftime("%Y%m%dT%H%M%SZ")
    version = "v" + ts
    version_dir = os.path.join(MODEL_DIR, version)
    os.makedirs(version_dir, exist_ok=True)

    joblib.dump(model, os.path.join(version_dir, "model.pkl"))
    joblib.dump(scaler, os.path.join(version_dir, "scaler.pkl"))

    metadata = {
        "version": version,
        "timestamp": ts,
        "mae": maes.tolist(),
        "rmse": rmses.tolist(),
        "features": list(X.columns),
        "targets": list(y.columns),
    }
    with open(os.path.join(version_dir, "metadata.json"), "w") as f:
        json.dump(metadata, f, indent=2)

    with open(os.path.join(MODEL_DIR, "LATEST"), "w") as f:
        f.write(version)

    print("[trainer] saved:", version)
    return version_dir, metadata
