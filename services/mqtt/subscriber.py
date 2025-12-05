import json
import time
import signal
import os
import requests
from paho.mqtt import client as mqtt
from threading import Lock
from datetime import datetime

RUNNING = True
def handle_signal(signum, frame):
    global RUNNING
    RUNNING = False

signal.signal(signal.SIGINT, handle_signal)
signal.signal(signal.SIGTERM, handle_signal)

BROKER = "localhost"
PORT = 1883

KIT_ID = os.getenv("KIT_ID")
IS_MULTI = KIT_ID is None

if IS_MULTI:
    TOPIC = "kit/+/telemetry"
else:
    TOPIC = f"kit/{KIT_ID}/telemetry"

BACKEND_URL = "http://127.0.0.1:8000/telemetry"
QOS = 1

CLIENT_ID = f"csv-subscriber-{KIT_ID}"

STATE = {}   # per-device state
state_lock = Lock()

# Track which sensors have updated since last backend send
sensor_updated = {}  # per-device: {sensor: bool}
REQUIRED_SENSORS = ["ppm", "ph", "tempC", "humidity", "waterTemp", "waterLevel"]

print("[INIT] KIT_ID:", KIT_ID)
print("[INIT] SUBSCRIBING:", TOPIC)

def safe_float(x, default=None):
    try:
        if x is None:
            return default
        if isinstance(x, str) and x.strip() == "":
            return default
        return float(x)
    except:
        return default

def pretty_json(obj):
    return json.dumps(obj, indent=2, ensure_ascii=False)

def send_snapshot(kit_id):
    with state_lock:
        payload = STATE.get(kit_id, {})

    print("\n📤 Sending Snapshot to Backend...")
    print(f"POST /telemetry?deviceId={kit_id}")
    print(pretty_json(payload))

    try:
        r = requests.post(
            f"{BACKEND_URL}?deviceId={kit_id}",
            json=payload,
            timeout=5
        )
        print(f"Backend Status → {r.status_code} | {r.text}")
    except Exception as e:
        print("[ERR] Backend error:", e)

def on_connect(client, userdata, flags, reason_code, properties):
    print("[MQTT] Connected →", TOPIC)
    client.subscribe(TOPIC, qos=QOS)

def on_message(client, userdata, msg):
    t = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    print("\n──────────────────────────────────────────────")
    print("📥 MQTT MESSAGE RECEIVED")
    print(f"🕒 {t}")
    print(f"📡 Topic: {msg.topic}")

    try:
        data = json.loads(msg.payload.decode())

        # detect deviceId from topic
        if IS_MULTI:
            kit_id = msg.topic.split("/")[1]
        else:
            kit_id = KIT_ID

        print(f"🔧 Device ID: {kit_id}")
        print("──────────────────────────────────────────────\n")

        print("Payload:")
        print(pretty_json(data))
        print()

        # ensure this device has its own state
        with state_lock:
            if kit_id not in STATE:
                STATE[kit_id] = {
                    "ppm": 0.0,
                    "ph": 0.0,
                    "tempC": 0.0,
                    "humidity": 0.0,
                    "waterTemp": 0.0,
                    "waterLevel": 0.0,
                }
                sensor_updated[kit_id] = {s: False for s in REQUIRED_SENSORS}

            # Update state with new data from MQTT and mark sensors as updated
            for key in data:
                if key in STATE[kit_id]:
                    STATE[kit_id][key] = safe_float(data[key], STATE[kit_id][key])
                    sensor_updated[kit_id][key] = True  # Mark this sensor as updated

        print("Updated State:")
        print(pretty_json(STATE[kit_id]))
        print()

        # Check if all sensors have been updated at least once
        all_updated = all(sensor_updated[kit_id].values())
        
        if all_updated:
            print("✅ All sensors updated, sending to backend...")
            send_snapshot(kit_id)
            # Reset the tracking
            sensor_updated[kit_id] = {s: False for s in REQUIRED_SENSORS}
        else:
            pending = [s for s, updated in sensor_updated[kit_id].items() if not updated]
            print(f"⏳ Waiting for: {', '.join(pending)}")

        print("──────────────────────────────────────────────")

    except Exception as e:
        print("[ERR] Failed to parse MQTT:", e)
        print("[RAW]", msg.payload)
        print("──────────────────────────────────────────────")

def main():
    client = mqtt.Client(
        mqtt.CallbackAPIVersion.VERSION2,
        client_id=CLIENT_ID,
        protocol=mqtt.MQTTv311
    )

    client.on_connect = on_connect
    client.on_message = on_message

    client.loop_start()
    client.connect(BROKER, PORT)

    print("[INFO] Subscriber running...\n")

    try:
        while RUNNING:
            time.sleep(0.1)
    finally:
        print("\n[STOP] Subscriber berhenti.")
        client.loop_stop()
        client.disconnect()

if __name__ == "__main__":
    main()
