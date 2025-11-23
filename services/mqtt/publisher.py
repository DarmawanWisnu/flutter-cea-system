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
KIT_ID = os.getenv("KIT_ID", "devkit-01")
TOPIC = f"kit/{KIT_ID}/telemetry"
CSV_PATH = os.path.join(os.path.dirname(__file__), "data.csv")
INTERVAL = 5.0
QOS = 1
RETAIN = False
CLIENT_ID = f"csv-publisher-{KIT_ID}"

def rc_value(rc):
    try:
        return int(rc)
    except Exception:
        return getattr(rc, "value", rc)

def read_csv_rows(path):
    with open(path, newline='', encoding='utf-8') as f:
        rows = list(csv.DictReader(f))
        if not rows:
            raise ValueError("CSV kosong atau header salah.")
        return rows

def connect_with_retry(client, host, port, keepalive=60):
    while RUNNING:
        try:
            client.connect(host, port, keepalive)
            return
        except OSError as e:
            print(f"[WARN] Gagal connect ke {host}:{port}: {e}. Coba lagi 2 detik...")
            time.sleep(2)

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
    connect_with_retry(client, BROKER, PORT)

    print(f"[OK] Publisher jalan. Target TOPIC = {TOPIC}")

    try:
        while RUNNING:
            for i, row in enumerate(rows):
                if not RUNNING:
                    break

                payload = {
                    "id": i + 1,
                    "ppm": float(row.get("TDS", 0)),
                    "ph": float(row.get("pH", 0)),
                    "tempC": float(row.get("DHT_temp", 0)),       # BENAR
                    "humidity": float(row.get("DHT_humidity", 0)),
                    "waterTemp": float(row.get("water_temp", 0)),
                    "waterLevel": float(row.get("water_level", 0)),
                    "pH_reducer": False,
                    "add_water": False,
                    "nutrients_adder": False,
                    "humidifier": False,
                    "ex_fan": False,
                    "isDefault": False
                }

                client.publish(TOPIC, json.dumps(payload), qos=QOS, retain=RETAIN)
                print(f"[PUB] {json.dumps(payload)}")
                time.sleep(INTERVAL)

    finally:
        print("[STOP] Publisher berhenti.")
        client.loop_stop()
        client.disconnect()

if __name__ == "__main__":
    main()
