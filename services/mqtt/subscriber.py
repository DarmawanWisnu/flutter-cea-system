import json, time, signal, os, requests
from paho.mqtt import client as mqtt
from statistics import median

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
BACKEND_URL = "http://127.0.0.1:8000/telemetry"
QOS = 1
CLIENT_ID = f"csv-subscriber-{KIT_ID}"

# Auto-detected interval
AUTO_INTERVAL = 5         # default sementara
last_msg_time = None
interval_samples = []     # ring buffer interval
MAX_SAMPLES = 10

last_sent_payload = None

# Tick counter
LAST_TICK = 0

STATE = {
    "ppm": None,
    "ph": None,
    "tempC": None,
    "humidity": None,
    "waterTemp": None,
    "waterLevel": None
}

print("[KIT_ID]", KIT_ID)
print("[SUBSCRIBE]", TOPIC)


def update_interval():
    """Hitung interval publisher otomatis berdasarkan median sampel."""
    global AUTO_INTERVAL

    if len(interval_samples) < 3:
        return  # belum cukup data

    new_interval = median(interval_samples)

    # batasan wajar (2-60 detik)
    if 2 <= new_interval <= 60:
        AUTO_INTERVAL = new_interval
        print(f"[INTERVAL] Auto calibrated → {AUTO_INTERVAL:.2f} sec")


def send_snapshot():
    payload = {k: (v if v is not None else 0.0) for k, v in STATE.items()}
    print("[SEND PAYLOAD]", payload)

    try:
        r = requests.post(
            f"{BACKEND_URL}?deviceId={KIT_ID}",
            json=payload,
            timeout=5
        )
        print("[BACKEND]", r.status_code, "→", r.text)
    except Exception as e:
        print("[ERR] Backend gagal:", e)


def on_connect(client, userdata, flags, reason_code, properties):
    print("[OK] Subscriber konek:", TOPIC)
    client.subscribe(TOPIC, qos=QOS)


def on_message(client, userdata, msg):
    """Update state dan hitung interval publisher otomatis."""
    global last_msg_time

    now = time.time()

    # Hitung interval pesan untuk deteksi tempo publisher
    if last_msg_time is not None:
        delta = now - last_msg_time

        # buang noise aneh (<0.2s)
        if delta > 0.2:
            interval_samples.append(delta)
            if len(interval_samples) > MAX_SAMPLES:
                interval_samples.pop(0)
            update_interval()

    last_msg_time = now

    # Update state
    try:
        data = json.loads(msg.payload.decode())

        sensor = data.get("sensor")
        value = data.get("value")

        if sensor in STATE:
            STATE[sensor] = float(value)
            print(f"[MQTT] UPDATE {sensor} = {value}")
        else:
            print("[WARN] Sensor tidak dikenal:", sensor)

    except Exception as e:
        print("[ERR] parse MQTT:", e)
        print("[STATE]", STATE)


def main():
    global LAST_TICK

    client = mqtt.Client(
        mqtt.CallbackAPIVersion.VERSION2,
        client_id=CLIENT_ID,
        protocol=mqtt.MQTTv311
    )

    client.on_connect = on_connect
    client.on_message = on_message

    client.loop_start()
    client.connect(BROKER, PORT)

    LAST_TICK = time.time()
    print("[INFO] Subscriber jalan.")

    try:
        while RUNNING:
            now = time.time()

            # snapshot based on auto interval
            if now - LAST_TICK >= AUTO_INTERVAL:
                send_snapshot()
                LAST_TICK = now

            time.sleep(0.1)

    finally:
        print("[STOP] Subscriber berhenti.")
        client.loop_stop()
        client.disconnect()


if __name__ == "__main__":
    main()
