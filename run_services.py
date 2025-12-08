import os
import time
import logging
import subprocess
from logging.handlers import RotatingFileHandler

ROOT = os.path.dirname(os.path.abspath(__file__))
LOG_DIR = os.path.join(ROOT, "logs")

# Ensure logs folder exists
os.makedirs(LOG_DIR, exist_ok=True)

# Log rotation settings
MAX_BYTES = 10 * 1024 * 1024
BACKUP_COUNT = 5

services = [
    {
        "name": "API Service",
        "cmd": "uvicorn services.api.main:app --reload --host 0.0.0.0 --port 8000",
        "cwd": ROOT,  
        "log": os.path.join(LOG_DIR, "api.log")
    },
    {
        "name": "MQTT Subscriber",
        "cmd": "python subscriber.py",
        "cwd": os.path.join(ROOT, "services", "mqtt"),
        "log": os.path.join(LOG_DIR, "mqtt_sub.log")
    },
    {
        "name": "MQTT Publisher",
        "cmd": "python publisher.py",
        "cwd": os.path.join(ROOT, "services", "mqtt"),
        "log": os.path.join(LOG_DIR, "mqtt_pub.log")
    },
]

# Setup rotating logger
def setup_logger(log_path):
    logger = logging.getLogger(log_path)
    logger.setLevel(logging.INFO)

    handler = RotatingFileHandler(
        log_path,
        maxBytes=MAX_BYTES,
        backupCount=BACKUP_COUNT,
        encoding="utf-8"
    )

    formatter = logging.Formatter("[%(asctime)s] %(message)s")
    handler.setFormatter(formatter)

    # Avoid adding multiple handlers on re-runs
    if not logger.handlers:
        logger.addHandler(handler)

    return logger


print("=== Starting All Services ===\n")

loggers = {}

for svc in services:
    print(f"Starting {svc['name']} ...")

    # Prepare logger
    loggers[svc["name"]] = setup_logger(svc["log"])
    logger = loggers[svc["name"]]

    # Open new CMD window (NO redirection to log — logger handles all logging)
    command = f'start "" cmd /k "cd /d {svc["cwd"]} && {svc["cmd"]}"'

    print(command)

    # execute the command
    subprocess.Popen(command, shell=True)

    logger.info(f"{svc['name']} started.")
    
    # Give API extra time to fully start
    if svc['name'] == "API Service":
        time.sleep(3)  # Wait 3 seconds for API to be ready
    else:
        time.sleep(0.4)

print("\n=== All services started successfully! ===")
print("Log files located at: logs/")
print("Each service writes max 10MB logs (5 backups).")
print("Close each CMD window to stop its service.\n")

while True:
    time.sleep(1)