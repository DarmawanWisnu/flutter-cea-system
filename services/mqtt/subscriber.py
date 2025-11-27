import json
import time
import signal
import os
import requests
from paho.mqtt import client as mqtt
from statistics import median
from collections import deque
from threading import Lock

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
AUTO_INTERVAL = 5.0         # default sementara (float)
last_msg_time = None
interval_samples = deque(maxlen=10)   # ring buffer interval
MAX_SAMPLES = 10

# Tick counter
LAST_TICK = 0.0

STATE = {
    "ppm": None,
    "ph": None,
    "tempC": None,
    "humidity": None,
    "waterTemp": None,
    "waterLevel": None
}

# Lock to protect STATE and interval_samples across threads
state_lock = Lock()

print("[KIT_ID]", KIT_ID)
print("[SUBSCRIBE]", TOPIC)


def update_interval():
    """Hitung interval publisher otomatis berdasarkan median sampel."""
    global AUTO_INTERVAL

    if len(interval_samples) < 3:
        return  # belum cukup data

    try:
        new_interval = float(median(list(interval_samples)))
    except Exception:
        return

    # batasan wajar (2-60 detik)
    if 2.0 <= new_interval <= 60.0:
        AUTO_INTERVAL = new_interval
        print(f"[INTERVAL] Auto calibrated → {AUTO_INTERVAL:.2f} sec")


def send_snapshot():
    # baca STATE dengan lock supaya konsisten
    with state_lock:
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


def safe_float(x, default=None):
    try:
        if x is None:
            return default
        # handle strings like "" as default
        if isinstance(x, str) and x.strip() == "":
            return default
        return float(x)
    except Exception:
        return default


def on_message(client, userdata, msg):
    global last_msg_time

    now = time.time()

    # Hitung interval pesan
    if last_msg_time is not None:
        delta = now - last_msg_time
        if delta > 0.2:
            with state_lock:
                interval_samples.append(delta)
            update_interval()

    last_msg_time = now

    # Parse payload full row
    try:
        data = json.loads(msg.payload.decode())

        # Update seluruh state atomically
        with state_lock:
            for key in STATE.keys():
                if key in data:
                    val = safe_float(data.get(key), default=None)
                    # hanya update jika val bukan None (atau sesuai kebijakanmu)
                    STATE[key] = val

        print("[MQTT] STATE UPDATED →", STATE)

    except Exception as e:
        print("[ERR] parse MQTT:", e)
        print("[RAW]", msg.payload)


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
