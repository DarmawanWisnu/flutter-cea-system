import csv, json, time, os, signal, sys, random
import requests
from paho.mqtt import client as mqtt

RUNNING = True
def handle_signal(signum, frame):
    global RUNNING
    RUNNING = False

signal.signal(signal.SIGINT, handle_signal)
signal.signal(signal.SIGTERM, handle_signal)

BROKER = "localhost"
PORT = 1883
CSV_PATH = os.path.join(os.path.dirname(__file__), "data.csv")
BACKEND_URL = "http://127.0.0.1:8000/kits"
QOS = 1
RETAIN = False

KIT_ID = os.getenv("KIT_ID")      # None = multi mode
IS_MULTI = KIT_ID is None

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

def fetch_device_ids():
    try:
        res = requests.get(BACKEND_URL, timeout=5)
        if res.status_code == 200:
            data = res.json()
            return [item["id"] for item in data]
        else:
            print("[ERR] Failed fetch /kits:", res.status_code, res.text)
            return []
    except Exception as e:
        print("[ERR] Cannot reach backend:", e)
        return []

def create_client(client_id):
    c = mqtt.Client(
        mqtt.CallbackAPIVersion.VERSION2,
        client_id=client_id,
        protocol=mqtt.MQTTv311
    )
    c.connect(BROKER, PORT)
    c.loop_start()
    return c

def build_payload(row):
    return {
        "tempC": pick(row, "DHT_temp", "dht_temp", "tempC", "temperature"),
        "humidity": pick(row, "DHT_humidity", "dht_humidity", "humidity"),
        "waterLevel": pick(row, "water_level", "waterLevel"),
        "waterTemp": pick(row, "water_temp", "waterTemp"),
        "ppm": pick(row, "TDS", "tds"),
        "ph": pick(row, "pH", "ph"),
    }

def main():
    try:
        rows = read_csv_rows(CSV_PATH)
    except Exception as e:
        print("[ERR] Gagal baca CSV:", e)
        sys.exit(1)

    if IS_MULTI:
        device_ids = fetch_device_ids()
        if not device_ids:
            print("[ERR] Tidak ada deviceId di backend.")
            sys.exit(1)
        print("[MODE] MULTI-KIT")
        print("[DEVICES]", device_ids)
    else:
        device_ids = [KIT_ID]
        print("[MODE] SINGLE-KIT →", KIT_ID)

    clients = {kit: create_client(f"pub-{kit}") for kit in device_ids}

    print("[OK] Publisher berjalan...\n")

    try:
        # interval sensor, dalam detik
        INTERVALS = {
            "tempC": 5,
            "humidity": 5,
            "waterLevel": 10,
            "waterTemp": 15,
            "ppm": 20,
            "ph": 30,
        }

        # state per kit
        device_state = {
            kit: {s: 0.0 for s in INTERVALS.keys()}
            for kit in device_ids
        }

        # timer per kit per sensor
        device_timer = {
            kit: {s: 0 for s in INTERVALS.keys()}
            for kit in device_ids
        }

        # CHANGED: Each kit has its own random row index
        device_row_idx = {
            kit: random.randint(0, len(rows) - 1)
            for kit in device_ids
        }

        while RUNNING:
            now = time.time()

            for kit in device_ids:
                client = clients[kit]
                # CHANGED: Each kit uses its own random row
                row = rows[device_row_idx[kit]]
                updated = False

                for sensor in INTERVALS:
                    if now - device_timer[kit][sensor] >= INTERVALS[sensor]:
                        if sensor == "ppm":
                            device_state[kit]["ppm"] = pick(row, "TDS", "tds")
                        elif sensor == "ph":
                            device_state[kit]["ph"] = pick(row, "pH", "ph")
                        elif sensor == "tempC":
                            device_state[kit]["tempC"] = pick(row, "DHT_temp", "dht_temp", "tempC")
                        elif sensor == "humidity":
                            device_state[kit]["humidity"] = pick(row, "DHT_humidity", "humidity")
                        elif sensor == "waterTemp":
                            device_state[kit]["waterTemp"] = pick(row, "water_temp")
                        elif sensor == "waterLevel":
                            device_state[kit]["waterLevel"] = pick(row, "water_level")

                        device_timer[kit][sensor] = now
                        updated = True

                if updated:
                    topic = f"kit/{kit}/telemetry"
                    payload = json.dumps(device_state[kit])
                    client.publish(topic, payload, qos=QOS, retain=RETAIN)

                    print(f"[PUB] {kit} → row#{device_row_idx[kit]}", device_state[kit])
                    
                    # CHANGED: Move to next random row for this kit
                    device_row_idx[kit] = random.randint(0, len(rows) - 1)

            time.sleep(0.2)


    finally:
        print("\n[STOP] Publisher berhenti.\n")
        for c in clients.values():
            c.loop_stop()
            c.disconnect()

if __name__ == "__main__":
    main()
