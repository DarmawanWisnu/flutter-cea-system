import json, time, signal, os, requests
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
BACKEND_URL = "http://127.0.0.1:8000/telemetry"
QOS = 1
CLIENT_ID = f"csv-subscriber-{KIT_ID}"
STATE = {
    "ppm": None,
    "ph": None,
    "tempC": None,
    "humidity": None,
    "waterTemp": None,
    "waterLevel": None
}

def send_to_backend():
    if any(v is None for v in STATE.values()):
        return

    try:
        r = requests.post(
            f"{BACKEND_URL}?device_id={KIT_ID}",
            json=STATE,
            timeout=5
        )
        print(f"[BACKEND] {r.status_code} → {r.text}")
    except Exception as e:
        print(f"[ERR] Backend gagal: {e}")

def on_connect(client, userdata, flags, reason_code, properties):
    print(f"[OK] Subscriber konek: {TOPIC}")
    client.subscribe(TOPIC, qos=QOS)

def on_message(client, userdata, msg):
    try:
        data = json.loads(msg.payload.decode())

        sensor = data.get("sensor")
        value = data.get("value")

        if sensor not in STATE:
            print(f"[WARN] Sensor tidak dikenal: {sensor}")
            return

        STATE[sensor] = value
        print(f"[MQTT] UPDATE {sensor} = {value}")

        send_to_backend()

    except Exception as e:
        print(f"[ERR] parse MQTT: {e}")

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

    print("[INFO] Subscriber jalan.")

    try:
        while RUNNING:
            time.sleep(0.1)
    finally:
        print("[STOP] Subscriber berhenti.")
        client.loop_stop()
        client.disconnect()

if __name__ == "__main__":
    main()
