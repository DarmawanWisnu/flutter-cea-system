import os
import json
import joblib
import datetime
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from sklearn.multioutput import MultiOutputRegressor
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
from dataset_loader import load_joined_dataset, load_from_csv
from preprocessing import prepare_xy, split_and_scale

MODEL_DIR = "model_registry"

def train_from_csv(telemetry_csv, actuator_csv, n_estimators=100, max_depth=20, random_state=42):
    """
    Train model from CSV files (matches Colab notebook).
    
    Args:
        telemetry_csv: Path to synthetic_telemetry.csv
        actuator_csv: Path to synthetic_actuator_event.csv
        n_estimators: Number of trees in random forest
        max_depth: Maximum depth of trees
        random_state: Random seed
    
    Returns:
        version_dir: Path to saved model
        metadata: Training metadata
    """
    print("[trainer] Loading dataset from CSV...")
    df = load_from_csv(telemetry_csv, actuator_csv)
    
    if df.empty:
        raise RuntimeError("No training data available.")

    X, y = prepare_xy(df)
    
    # Create version directory
    ts = datetime.datetime.utcnow().strftime("%Y%m%dT%H%M%SZ")
    version = "v" + ts
    version_dir = os.path.join(MODEL_DIR, version)
    os.makedirs(version_dir, exist_ok=True)
    
    X_train_s, X_val_s, y_train, y_val, scaler = split_and_scale(
        X, y, scaler_path=os.path.join(version_dir, "scaler.pkl")
    )

    print(f"[trainer] Training RandomForest (n_estimators={n_estimators}, max_depth={max_depth})...")
    base = RandomForestRegressor(
        n_estimators=n_estimators,
        max_depth=max_depth,
        min_samples_split=5,
        min_samples_leaf=2,
        n_jobs=-1,
        random_state=random_state,
        verbose=1
    )
    model = MultiOutputRegressor(base)
    model.fit(X_train_s, y_train)

    # Predictions
    y_train_pred = model.predict(X_train_s)
    y_val_pred = model.predict(X_val_s)
    
    # Calculate metrics for each target
    TARGETS = ["phUp", "phDown", "nutrientAdd", "refill"]
    metrics = {}
    
    for i, target in enumerate(TARGETS):
        train_mae = mean_absolute_error(y_train.iloc[:, i], y_train_pred[:, i])
        val_mae = mean_absolute_error(y_val.iloc[:, i], y_val_pred[:, i])
        train_rmse = np.sqrt(mean_squared_error(y_train.iloc[:, i], y_train_pred[:, i]))
        val_rmse = np.sqrt(mean_squared_error(y_val.iloc[:, i], y_val_pred[:, i]))
        train_r2 = r2_score(y_train.iloc[:, i], y_train_pred[:, i])
        val_r2 = r2_score(y_val.iloc[:, i], y_val_pred[:, i])
        
        metrics[target] = {
            'train_mae': float(train_mae),
            'test_mae': float(val_mae),
            'train_rmse': float(train_rmse),
            'test_rmse': float(val_rmse),
            'train_r2': float(train_r2),
            'test_r2': float(val_r2)
        }
        
        print(f"\n🎯 {target.upper()}:")
        print(f"   Train MAE:  {train_mae:.3f}  |  Test MAE:  {val_mae:.3f}")
        print(f"   Train RMSE: {train_rmse:.3f}  |  Test RMSE: {val_rmse:.3f}")
        print(f"   Train R²:   {train_r2:.3f}  |  Test R²:   {val_r2:.3f}")
    
    # Overall metrics
    overall_val_mae = mean_absolute_error(y_val, y_val_pred)
    overall_val_rmse = np.sqrt(mean_squared_error(y_val, y_val_pred))
    
    print(f"\n📈 Overall Test Performance:")
    print(f"   MAE:  {overall_val_mae:.3f}")
    print(f"   RMSE: {overall_val_rmse:.3f}")

    # Save model
    joblib.dump(model, os.path.join(version_dir, "model.pkl"))
    joblib.dump(scaler, os.path.join(version_dir, "scaler.pkl"))

    # Save metadata
    metadata = {
        "version": version,
        "timestamp": ts,
        "training_samples": len(X_train),
        "test_samples": len(X_val),
        "features": list(X.columns),
        "targets": TARGETS,
        "metrics": metrics,
        "overall_test_mae": float(overall_val_mae),
        "overall_test_rmse": float(overall_val_rmse)
    }
    
    with open(os.path.join(version_dir, "metadata.json"), "w") as f:
        json.dump(metadata, f, indent=2)

    # Update LATEST pointer
    with open(os.path.join(MODEL_DIR, "LATEST"), "w") as f:
        f.write(version)

    print(f"\n✅ Model saved: {version_dir}")
    return version_dir, metadata


def train_and_save(limit=None, device_id=None, n_estimators=100, random_state=42):
    """
    Train model from database (legacy function for backward compatibility).
    """
    print("[trainer] loading dataset from database...")
    df = load_joined_dataset(limit=limit, device_id=device_id)
    if df.empty:
        raise RuntimeError("No training data available.")

    X, y = prepare_xy(df)
    
    # Create version directory
    ts = datetime.datetime.utcnow().strftime("%Y%m%dT%H%M%SZ")
    version = "v" + ts
    version_dir = os.path.join(MODEL_DIR, version)
    os.makedirs(version_dir, exist_ok=True)
    
    X_train_s, X_val_s, y_train, y_val, scaler = split_and_scale(
        X, y, scaler_path=os.path.join(version_dir, "scaler.pkl")
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


if __name__ == "__main__":
    # Example: Train from synthetic CSVs
    telemetry_path = "synthetic_telemetry.csv"
    actuator_path = "synthetic_actuator_event.csv"
    
    if os.path.exists(telemetry_path) and os.path.exists(actuator_path):
        print("Training from synthetic CSV files...")
        version_dir, metadata = train_from_csv(telemetry_path, actuator_path)
        print(f"\n✅ Training complete!")
        print(f"Model saved to: {version_dir}")
    else:
        print("Synthetic CSV files not found. Use database training instead:")
        print("  python trainer.py --database")
