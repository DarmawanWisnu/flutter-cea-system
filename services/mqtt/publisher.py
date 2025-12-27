import csv, json, time, os, signal, sys, random
import requests
from paho.mqtt import client as mqtt

RUNNING = True
def handle_signal(signum, frame):
    global RUNNING
    RUNNING = False

signal.signal(signal.SIGINT, handle_signal)
signal.signal(signal.SIGTERM, handle_signal)

# Environment configuration
BROKER = os.getenv("MQTT_BROKER", "localhost")
PORT = int(os.getenv("MQTT_PORT", "1883"))
BACKEND_URL = os.getenv("BACKEND_URL", "http://localhost:8000/kits/all")
CSV_PATH = os.path.join(os.path.dirname(__file__), "data.csv")
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

        # timer per kit per sensor (initialize to trigger immediately on first loop)
        start_time = time.time()
        device_timer = {
            kit: {s: start_time - INTERVALS[s] for s in INTERVALS.keys()}
            for kit in device_ids
        }

        # randow row each kit
        device_row_idx = {
            kit: random.randint(0, len(rows) - 1)
            for kit in device_ids
        }

        # Track last refresh time for auto-refresh
        last_refresh = time.time()
        REFRESH_INTERVAL = 3  # seconds

        while RUNNING:
            now = time.time()

            # Auto-refresh: check for new kits every 3 seconds
            if IS_MULTI and (now - last_refresh >= REFRESH_INTERVAL):
                new_ids = fetch_device_ids()
                for new_kit in new_ids:
                    if new_kit not in device_ids:
                        print(f"\n[NEW] Detected new kit: {new_kit}")
                        # Add to device list
                        device_ids.append(new_kit)
                        # Create MQTT client
                        clients[new_kit] = create_client(f"pub-{new_kit}")
                        # Initialize state
                        device_state[new_kit] = {s: 0.0 for s in INTERVALS.keys()}
                        device_timer[new_kit] = {s: now - INTERVALS[s] for s in INTERVALS.keys()}
                        device_row_idx[new_kit] = random.randint(0, len(rows) - 1)
                        print(f"[NEW] Started publishing to {new_kit}\n")
                last_refresh = now

            for kit in device_ids:
                client = clients[kit]
                
                # Build partial payload with only updated sensors
                partial_payload = {}

                for sensor in INTERVALS:
                    elapsed = now - device_timer[kit][sensor]
                    
                    if elapsed >= INTERVALS[sensor]:
                        # Pick a random row for THIS sensor update
                        row = rows[random.randint(0, len(rows) - 1)]
                        
                        if sensor == "ppm":
                            value = pick(row, "TDS", "tds")
                        elif sensor == "ph":
                            value = pick(row, "pH", "ph")
                        elif sensor == "tempC":
                            value = pick(row, "DHT_temp", "dht_temp", "tempC")
                        elif sensor == "humidity":
                            value = pick(row, "DHT_humidity", "humidity")
                        elif sensor == "waterTemp":
                            value = pick(row, "water_temp")
                        elif sensor == "waterLevel":
                            value = pick(row, "water_level")
                        
                        # Update state and add to partial payload
                        device_state[kit][sensor] = value
                        partial_payload[sensor] = value
                        device_timer[kit][sensor] = now

                # Only publish if there are updates
                if partial_payload:
                    topic = f"kit/{kit}/telemetry"
                    payload = json.dumps(partial_payload)
                    client.publish(topic, payload, qos=QOS, retain=RETAIN)

                    print(f"[PUB] {kit} → {list(partial_payload.keys())} = {partial_payload}")

            time.sleep(0.2)


    finally:
        print("\n[STOP] Publisher berhenti.\n")
        for c in clients.values():
            c.loop_stop()
            c.disconnect()

if __name__ == "__main__":
    main()
