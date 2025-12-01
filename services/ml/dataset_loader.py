import pandas as pd
import json
from services.api.database import get_connection, release_connection

TELEMETRY_FEATURES = ["ppm", "ph", "tempC", "humidity", "waterTemp", "waterLevel"]

def load_joined_dataset(limit=None, device_id=None):
    """
    Mengambil paired rows: telemetry (nearest BEFORE) dan actuator_event.
    Returns pandas.DataFrame with columns: telemetry features + actuator outputs.
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

        # FIX: execute dengan benar
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

        # Buang pair yang tidak punya telemetry
        df = df.dropna(subset=TELEMETRY_FEATURES, how="any")

        return df

    finally:
        cur.close()
        release_connection(conn)


def export_csv(path="data/raw/dataset_pairs.csv", limit=None, device_id=None):
    df = load_joined_dataset(limit=limit, device_id=device_id)

    import os
    os.makedirs(os.path.dirname(path), exist_ok=True)

    df.to_csv(path, index=False)
    print(f"[dataset_loader] exported {len(df)} rows to {path}")
    return path
