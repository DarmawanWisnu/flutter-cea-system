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

    client.connect(BROKER, PORT)
    client.loop_start()
    print(f"[OK] Publisher jalan — TOPIC = {TOPIC}")
    print("Publishing to:", BROKER, ":", PORT, "->", TOPIC)

    state = {s: 0.0 for s in INTERVALS.keys()}  # nilai awal
    last_update = {s: 0 for s in INTERVALS.keys()}

    row_idx = 0

    try:
        while RUNNING:
            now = time.time()
            row = rows[row_idx]
            updated = False

            # cek tiap sensor
            for sensor in INTERVALS:
                if now - last_update[sensor] >= INTERVALS[sensor]:
                    # waktunya update sensor ini
                    if sensor == "ppm":
                        state["ppm"] = pick(row, "TDS", "tds")
                    elif sensor == "ph":
                        state["ph"] = pick(row, "pH", "ph")
                    elif sensor == "tempC":
                        state["tempC"] = pick(row, "DHT_temp", "dht_temp", "tempC", "temperature")
                    elif sensor == "humidity":
                        state["humidity"] = pick(row, "DHT_humidity", "dht_humidity", "humidity")
                    elif sensor == "waterTemp":
                        state["waterTemp"] = pick(row, "water_temp", "waterTemp")
                    elif sensor == "waterLevel":
                        state["waterLevel"] = pick(row, "water_level", "waterLevel")

                    last_update[sensor] = now
                    updated = True

            # hanya kirim jika ada sensor yg berubah
            if updated:
                client.publish(TOPIC, json.dumps(state), qos=QOS, retain=RETAIN)
                print("[PUB]", state)

            row_idx = (row_idx + 1) % len(rows)
            time.sleep(0.1)

    finally:
        print("[STOP] Publisher berhenti.")
        client.loop_stop()
        client.disconnect()


if __name__ == "__main__":
    main()
