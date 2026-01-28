import json
import time
import signal
import os
import ssl
import requests
from dotenv import load_dotenv
from paho.mqtt import client as mqtt
from threading import Lock, Thread
from datetime import datetime

# Load .env file from same directory
load_dotenv(os.path.join(os.path.dirname(__file__), '.env'))

# ANSI Color Codes for professional terminal output
class Colors:
    RESET = "\033[0m"
    BOLD = "\033[1m"
    DIM = "\033[2m"
    
    CYAN = "\033[36m"       # Headers, RECV
    GREEN = "\033[32m"      # OK, Success
    YELLOW = "\033[33m"     # WAIT, Pending
    RED = "\033[31m"        # ERROR
    WHITE = "\033[97m"      # SEND
    MAGENTA = "\033[35m"    # Separator
    BLUE = "\033[34m"       # INFO

RUNNING = True
def handle_signal(signum, frame):
    global RUNNING
    RUNNING = False

signal.signal(signal.SIGINT, handle_signal)
signal.signal(signal.SIGTERM, handle_signal)

# Environment configuration - HiveMQ Cloud
BROKER = os.getenv("MQTT_BROKER", "")
PORT = int(os.getenv("MQTT_PORT", ""))
MQTT_USERNAME = os.getenv("MQTT_USERNAME", "")
MQTT_PASSWORD = os.getenv("MQTT_PASSWORD", "")
USE_TLS = os.getenv("MQTT_USE_TLS", "true").lower() == "true"

BACKEND_URL = os.getenv("BACKEND_URL", "http://localhost:8000/telemetry")

KIT_ID = os.getenv("KIT_ID")
IS_MULTI = KIT_ID is None

if IS_MULTI:
    TOPIC = "kit/+/telemetry"
else:
    TOPIC = f"kit/{KIT_ID}/telemetry"

QOS = 1

CLIENT_ID = f"csv-subscriber-{KIT_ID}"

STATE = {}   # per-device state
state_lock = Lock()

# Track which sensors have updated since last backend send
sensor_updated = {}  # per-device: {sensor: bool}
REQUIRED_SENSORS = ["ppm", "ph", "tempC", "humidity", "waterTemp", "waterLevel"]

print(f"{Colors.BLUE}[INIT]{Colors.RESET} KIT_ID: {KIT_ID}")
print(f"{Colors.BLUE}[INIT]{Colors.RESET} SUBSCRIBING: {TOPIC}")

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

    print(f"\n{Colors.BOLD}{Colors.WHITE}[SEND]{Colors.RESET} Sending Snapshot to Backend...")
    print(f"{Colors.WHITE}POST /telemetry?deviceId={kit_id}{Colors.RESET}")
    print(f"{Colors.WHITE}{pretty_json(payload)}{Colors.RESET}")

    try:
        r = requests.post(
            f"{BACKEND_URL}?deviceId={kit_id}",
            json=payload,
            timeout=5
        )
        print(f"{Colors.GREEN}[RESP]{Colors.RESET} Backend Status: {r.status_code} | {r.text}")
    except Exception as e:
        print(f"{Colors.RED}[ERR]{Colors.RESET} Backend error:", e)


def on_connect(client, userdata, flags, reason_code, properties):
    print(f"{Colors.GREEN}[MQTT]{Colors.RESET} Connected → {TOPIC}")
    client.subscribe(TOPIC, qos=QOS)

def on_message(client, userdata, msg):
    t = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    print(f"\n{Colors.DIM}{Colors.MAGENTA}{'=' * 50}{Colors.RESET}")
    print(f"{Colors.CYAN}[RECV]{Colors.RESET} MQTT MESSAGE RECEIVED")
    print(f"{Colors.CYAN}[TIME]{Colors.RESET} {t}")
    print(f"{Colors.CYAN}[TOPIC]{Colors.RESET} {msg.topic}")

    try:
        data = json.loads(msg.payload.decode())

        # detect deviceId from topic
        if IS_MULTI:
            kit_id = msg.topic.split("/")[1]
        else:
            kit_id = KIT_ID

        print(f"{Colors.CYAN}[DEVICE]{Colors.RESET} {kit_id}")
        print(f"{Colors.DIM}{Colors.MAGENTA}{'=' * 50}{Colors.RESET}\n")

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
            print(f"{Colors.GREEN}[OK]{Colors.RESET} All sensors updated, sending to backend...")
            send_snapshot(kit_id)
            # Reset the tracking
            sensor_updated[kit_id] = {s: False for s in REQUIRED_SENSORS}
        else:
            pending = [s for s, updated in sensor_updated[kit_id].items() if not updated]
            print(f"{Colors.YELLOW}[WAIT]{Colors.RESET} Pending: {', '.join(pending)}")

        print(f"{Colors.DIM}{Colors.MAGENTA}{'=' * 50}{Colors.RESET}")

    except Exception as e:
        print(f"{Colors.RED}[ERR]{Colors.RESET} Failed to parse MQTT:", e)
        print(f"{Colors.RED}[RAW]{Colors.RESET}", msg.payload)
        print(f"{Colors.DIM}{Colors.MAGENTA}{'=' * 50}{Colors.RESET}")

def main():
    client = mqtt.Client(
        mqtt.CallbackAPIVersion.VERSION2,
        client_id=CLIENT_ID,
        protocol=mqtt.MQTTv311
    )

    # HiveMQ Cloud requires TLS and authentication
    if USE_TLS:
        client.tls_set(tls_version=ssl.PROTOCOL_TLS)
    
    if MQTT_USERNAME and MQTT_PASSWORD:
        client.username_pw_set(MQTT_USERNAME, MQTT_PASSWORD)

    client.on_connect = on_connect
    client.on_message = on_message

    client.loop_start()
    client.connect(BROKER, PORT)

    print(f"{Colors.BLUE}[INFO]{Colors.RESET} Subscriber running...\n")

    try:
        while RUNNING:
            time.sleep(0.1)
    finally:
        print(f"\n{Colors.YELLOW}[STOP]{Colors.RESET} Subscriber berhenti.")
        client.loop_stop()
        client.disconnect()

if __name__ == "__main__":
    main()
