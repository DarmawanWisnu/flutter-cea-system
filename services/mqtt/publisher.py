import csv, json, time, os, signal, sys
from paho.mqtt import client as mqtt

RUNNING = True
def handle_signal(signum, frame):
    global RUNNING
    RUNNING = False

signal.signal(signal.SIGINT, handle_signal)
signal.signal(signal.SIGTERM, handle_signal)

BROKER = "localhost"
PORT = 1883
KIT_ID = os.getenv("KIT_ID", "CEA-01")
TOPIC = f"kit/{KIT_ID}/telemetry"
CSV_PATH = os.path.join(os.path.dirname(__file__), "data.csv")
QOS = 1
RETAIN = False
CLIENT_ID = f"csv-publisher-{KIT_ID}"
INTERVALS = {
    "tempC": 5,
    "humidity": 5,
    "waterLevel": 10,
    "waterTemp": 15,
    "ppm": 20,
    "ph": 30
}

def pick(row, *keys, default=0.0):
    for k in keys:
        if k in row and row[k] not in ("", None):
            try:
                return float(row[k])
            except:
                return default
    return default

def read_csv_rows(path):
    with open(path, newline='', encoding='utf-8') as f:
        rows = list(csv.DictReader(f))
        if not rows:
            raise ValueError("CSV kosong atau header salah.")
        return rows

def main():
    try:
        rows = read_csv_rows(CSV_PATH)
    except Exception as e:
        print(f"[ERR] Gagal baca CSV: {e}")
        sys.exit(1)

    client = mqtt.Client(
        mqtt.CallbackAPIVersion.VERSION2,
        client_id=CLIENT_ID,
        protocol=mqtt.MQTTv311
    )

    client.loop_start()
    client.connect(BROKER, PORT)
    print(f"[OK] Publisher jalan — TOPIC = {TOPIC}")

    last_sent = {k: 0 for k in INTERVALS.keys()}
    row_idx = 0

    try:
        while RUNNING:
            row = rows[row_idx]
            now = time.time()

            sensor_values = {
                "ppm": pick(row, "TDS", "tds"),
                "ph": pick(row, "pH", "ph"),
                "tempC": pick(row, "DHT_temp", "dht_temp", "tempC", "temperature"),
                "humidity": pick(row, "DHT_humidity", "dht_humidity", "humidity"),
                "waterTemp": pick(row, "water_temp", "waterTemp"),
                "waterLevel": pick(row, "water_level", "waterLevel"),
            }

            for sensor, interval in INTERVALS.items():
                if now - last_sent[sensor] >= interval:
                    payload = {
                        "sensor": sensor,
                        "value": sensor_values[sensor]
                    }
                    client.publish(TOPIC, json.dumps(payload), qos=QOS, retain=RETAIN)
                    print(f"[PUB] {payload}")
                    last_sent[sensor] = now

            row_idx = (row_idx + 1) % len(rows)
            time.sleep(0.1)

    finally:
        print("[STOP] Publisher berhenti.")
        client.loop_stop()
        client.disconnect()

if __name__ == "__main__":
    main()
