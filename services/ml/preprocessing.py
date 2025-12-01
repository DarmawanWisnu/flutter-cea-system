import os
import joblib
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler

TELEMETRY_FEATURES = ["ppm", "ph", "tempC", "humidity", "waterTemp", "waterLevel"]
TARGETS = ["phUp", "phDown", "nutrientAdd", "refill"]

def prepare_xy(df):
    X = df[TELEMETRY_FEATURES].copy()
    y = df[TARGETS].copy()
    X = X.fillna(method="ffill").fillna(0.0)
    y = y.fillna(0)
    return X, y

def split_and_scale(X, y, test_size=0.2, random_state=42, scaler_path="model_registry/scaler.pkl"):
    os.makedirs(os.path.dirname(scaler_path), exist_ok=True)
    scaler = StandardScaler()
    X_train, X_val, y_train, y_val = train_test_split(X, y, test_size=test_size, random_state=random_state)
    scaler.fit(X_train)
    X_train_s = scaler.transform(X_train)
    X_val_s = scaler.transform(X_val)
    joblib.dump(scaler, scaler_path)
    print(f"[preprocessing] scaler saved → {scaler_path}")
    return X_train_s, X_val_s, y_train, y_val, scaler
