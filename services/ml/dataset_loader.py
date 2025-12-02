import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "../../")))

import pandas as pd
import json
from services.api.database import get_connection, release_connection

TELEMETRY_FEATURES = ["ppm", "ph", "tempC", "humidity", "waterTemp", "waterLevel"]

def load_from_csv(telemetry_csv, actuator_csv):
    """
    Load and merge telemetry and actuator CSV files.
    Matches the Colab notebook approach.
    
    Args:
        telemetry_csv: Path to synthetic_telemetry.csv
        actuator_csv: Path to synthetic_actuator_event.csv
    
    Returns:
        pandas.DataFrame with merged data
    """
    print(f"[dataset_loader] Loading telemetry from: {telemetry_csv}")
    print(f"[dataset_loader] Loading actuator from: {actuator_csv}")
    
    telemetry_df = pd.read_csv(telemetry_csv)
    actuator_df = pd.read_csv(actuator_csv)
    
    print(f"[dataset_loader] Telemetry rows: {len(telemetry_df):,}")
    print(f"[dataset_loader] Actuator rows:  {len(actuator_df):,}")
    
    # Merge on common columns
    # Note: telemetry has 'rowId', actuator has 'id'
    # We'll merge on deviceId and ingestTime
    df = pd.merge(
        telemetry_df,
        actuator_df,
        on=['deviceId', 'ingestTime'],
        how='inner',
        suffixes=('_telemetry', '_actuator')
    )
    
    print(f"[dataset_loader] Merged dataset: {len(df):,} rows")
    
    # Safety cast numeric values
    numeric_cols = TELEMETRY_FEATURES + ["phUp", "phDown", "nutrientAdd", "refill", "valueS"]
    for col in numeric_cols:
        if col in df.columns:
            df[col] = pd.to_numeric(df[col], errors="coerce")
    
    # Drop rows with missing telemetry features
    df = df.dropna(subset=TELEMETRY_FEATURES, how="any")
    
    print(f"[dataset_loader] After cleaning: {len(df):,} rows")
    
    return df


def load_joined_dataset(limit=None, device_id=None):
    """
    Load paired rows from database: telemetry (nearest BEFORE) and actuator_event.
    Returns pandas.DataFrame with columns: telemetry features + actuator outputs.
    
    This is the original database-based loader, kept for backward compatibility.
    """
    conn = get_connection()
    cur = conn.cursor()

    try:
        sql = """
        SELECT
          ae.id as event_id,
          ae."deviceId" as device_id,
          ae."ingestTime" as event_time,
          t."ingestTime" as telemetry_time,
          t.ppm, t.ph, t."tempC", t.humidity, t."waterTemp", t."waterLevel",
          ae."phUp", ae."phDown", ae."nutrientAdd", ae."refill", ae."valueS",
          ae.manual, ae.auto
        FROM actuator_event ae
        LEFT JOIN LATERAL (
          SELECT *
          FROM telemetry tx
          WHERE tx."deviceId" = ae."deviceId"
            AND tx."ingestTime" <= ae."ingestTime"
          ORDER BY tx."ingestTime" DESC
          LIMIT 1
        ) t ON true
        WHERE 1=1
        """

        params = []

        if device_id:
            sql += " AND ae.\"deviceId\" = %s"
            params.append(device_id)

        sql += " ORDER BY ae.\"ingestTime\" DESC"

        if limit:
            sql += " LIMIT %s"
            params.append(limit)

        if len(params) > 0:
            cur.execute(sql, tuple(params))
        else:
            cur.execute(sql)

        rows = cur.fetchall()
        cols = [desc[0] for desc in cur.description]

        df = pd.DataFrame(rows, columns=cols)

        # Safety cast numeric values
        numeric_cols = TELEMETRY_FEATURES + ["phUp", "phDown", "nutrientAdd", "refill", "valueS"]
        for col in numeric_cols:
            if col in df.columns:
                df[col] = pd.to_numeric(df[col], errors="coerce")

        # Drop rows without telemetry
        df = df.dropna(subset=TELEMETRY_FEATURES, how="any")

        return df

    finally:
        cur.close()
        release_connection(conn)


def export_csv(path="data/raw/dataset_pairs.csv", limit=None, device_id=None):
    """Export database data to CSV (legacy function)."""
    df = load_joined_dataset(limit=limit, device_id=device_id)

    import os
    os.makedirs(os.path.dirname(path), exist_ok=True)

    df.to_csv(path, index=False)
    print(f"[dataset_loader] exported {len(df)} rows to {path}")
    return path

if __name__ == "__main__":
    # Example: Load from synthetic CSVs
    telemetry_path = "synthetic_telemetry.csv"
    actuator_path = "synthetic_actuator_event.csv"
    
    if os.path.exists(telemetry_path) and os.path.exists(actuator_path):
        df = load_from_csv(telemetry_path, actuator_path)
        print(f"\nDataset shape: {df.shape}")
        print(f"Columns: {list(df.columns)}")
    else:
        print("Synthetic CSV files not found. Using database export...")
        export_csv()
