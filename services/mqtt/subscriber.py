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

def rc_value(rc):
    try:
        return int(rc)
    except Exception:
        return getattr(rc, "value", rc)

def connect_with_retry(client, host, port, keepalive=60):
    while RUNNING:
        try:
            client.connect(host, port, keepalive)
            return
        except OSError as e:
            print(f"[WARN] MQTT connect gagal: {e}. Retry...")
            time.sleep(2)

def send_to_backend(data):
    try:
        r = requests.post(
            f"{BACKEND_URL}?device_id={KIT_ID}",
            json=data,
            timeout=5
        )
        print(f"[BACKEND] {r.status_code} → {r.text}")
    except Exception as e:
        print(f"[ERR] Backend gagal: {e}")

def on_connect(client, userdata, flags, reason_code, properties):
    if rc_value(reason_code) == 0:
        print(f"[OK] Subscriber konek. TOPIC={TOPIC}")
        client.subscribe(TOPIC, qos=QOS)
    else:
        print(f"[ERR] Connect gagal: {reason_code}")

def on_message(client, userdata, msg):
    try:
        data = json.loads(msg.payload.decode())
        print(f"[MQTT] {data}")
        send_to_backend(data)
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
    connect_with_retry(client, BROKER, PORT)

    print("[INFO] Subscriber jalan. Ctrl+C untuk stop.")

    try:
        while RUNNING:
            time.sleep(0.1)
    finally:
        print("[STOP] Subscriber berhenti.")
        client.loop_stop()
        client.disconnect()

if __name__ == "__main__":
    main()
