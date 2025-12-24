# Flutter CEA System - Mobile Setup Guide

Complete guide for running the application on **Physical Android Devices** or **Android Emulators**.

---

## Table of Contents

- [Physical Device Setup](#physical-device-setup)
- [Emulator Setup](#emulator-setup)
- [Configuration Summary](#configuration-summary)
- [Quick Start](#quick-start)
- [Remote Access with NGROK](#remote-access-with-ngrok)
- [Troubleshooting](#troubleshooting)

---

# Physical Device Setup

This section covers setup for installing the app on real Android devices via WiFi (no USB required).

## Configuration Files

### Mobile App Environment

**File:** `apps/mobile/.env`

```env
MQTT_HOST=<IP_KOMPUTER>
MQTT_PORT=1883
API_BASE_URL=http://<IP_KOMPUTER>:8000
```

> [!IMPORTANT]
> Replace `<IP_KOMPUTER>` with your computer's WiFi IP address. Use `ipconfig` command to find it.

### MQTT Subscriber Service

**File:** `services/mqtt/subscriber.py`

```python
BROKER = "localhost"  # Keep as localhost (runs on same machine as backend)
BACKEND_URL = "http://localhost:8000/telemetry"
```

### MQTT Publisher Service

**File:** `services/mqtt/publisher.py`

```python
BROKER = "localhost"  # Keep as localhost
BACKEND_URL = "http://localhost:8000/kits"
```

### Service Runner Configuration

**File:** `run_services.py`

```python
"cmd": "uvicorn services.api.main:app --reload --host 0.0.0.0 --port 8000",
#                                              ^^^^^^^^^^^^^^^^
#                                              REQUIRED: 0.0.0.0 for device access
```

> [!NOTE]
> MQTT Publisher/Subscriber use `localhost` because they run on the same computer as the backend. Only the Flutter app needs the computer's IP address since it runs on the phone.

## Build and Install APK

Build the release APK:

```bash
cd apps/mobile
flutter build apk
```

The APK will be located at:
```
build/app/outputs/apk/release/Fountaine-1.0.0.apk
```

**Transfer to phone via:**
- WhatsApp
- Telegram
- Google Drive
- Bluetooth

## Pre-Deployment Checklist

| Requirement | How to Verify |
|-------------|---------------|
| Service runner uses `--host 0.0.0.0` | Check `run_services.py` configuration |
| `.env` uses computer IP | Must NOT be `localhost` or `10.0.2.2` |
| Mosquitto service running | Run `net start mosquitto` (Admin CMD) |
| Firewall allows port 8000 | See firewall commands below |
| Firewall allows port 1883 | See firewall commands below |
| Phone & Computer on same WiFi | Verify network connection |

### Firewall Configuration

Run these commands in **Administrator Command Prompt**:

```bash
netsh advfirewall firewall add rule name="Backend API" dir=in action=allow protocol=tcp localport=8000
netsh advfirewall firewall add rule name="MQTT Broker" dir=in action=allow protocol=tcp localport=1883
```

## Connection Testing

Test the connection from your phone's browser:

```
http://<IP_KOMPUTER>:8000/kits
```

> [!TIP]
> If you see `[]` or a list of kits, the connection is successful!

---

# Emulator Setup

This section covers setup for Android Emulator development.

## Configuration Files

### Mobile App Environment

**File:** `apps/mobile/.env`

```env
MQTT_HOST=10.0.2.2
MQTT_PORT=1883
API_BASE_URL=http://10.0.2.2:8000
```

> [!NOTE]
> `10.0.2.2` is a special IP that refers to the host machine's `localhost` from within the emulator.

### MQTT Services Configuration

**Files:** `services/mqtt/subscriber.py` and `services/mqtt/publisher.py`

```python
BROKER = "localhost"
BACKEND_URL = "http://localhost:8000/telemetry"  # or /kits for publisher
```

### Service Runner Configuration

**File:** `run_services.py`

```python
"cmd": "uvicorn services.api.main:app --reload --host 0.0.0.0 --port 8000",
```

## Running the Application

Execute in two separate terminals:

```bash
# Terminal 1: Start backend services
python run_services.py

# Terminal 2: Run Flutter app
cd apps/mobile
flutter run
```

> [!TIP]
> Hot-reload is automatically enabled! Code changes are reflected immediately without rebuilding.

## Pre-Deployment Checklist

| Requirement | How to Verify |
|-------------|---------------|
| `.env` uses `10.0.2.2` | Must NOT be computer IP |
| Mosquitto service running | Run `net start mosquitto` |
| Emulator is running | Check with `flutter devices` |

---

# Configuration Summary

Comparison of configuration values for different deployment targets:

| Configuration | Physical Device | Emulator |
|---------------|-----------------|----------|
| `.env` MQTT_HOST | `<IP_KOMPUTER>` | `10.0.2.2` |
| `.env` API_BASE_URL | `http://<IP_KOMPUTER>:8000` | `http://10.0.2.2:8000` |
| `subscriber.py` BROKER | `localhost` | `localhost` |
| `subscriber.py` BACKEND_URL | `localhost:8000` | `localhost:8000` |
| `publisher.py` BROKER | `localhost` | `localhost` |
| `publisher.py` BACKEND_URL | `localhost:8000` | `localhost:8000` |
| `run_services.py` host | `0.0.0.0` | `0.0.0.0` |

---

# Quick Start

Start all backend services with a single command:

```bash
cd c:\WisnuDarmawan\Coding\Project\flutter-cea-system
python run_services.py
```

This will launch 3 separate CMD windows:
- **Backend API** (FastAPI) on port 8000
- **MQTT Subscriber** service
- **MQTT Publisher** service

---

# Remote Access with NGROK

## When to Use NGROK

| Scenario | NGROK Required? |
|----------|-----------------|
| Phone & Computer on same WiFi | No |
| Phone uses cellular data | Yes |
| Access from outside local network | Yes |

---

## Installation

### Step 1: Download NGROK

1. Visit: https://ngrok.com/download
2. Download for Windows
3. Extract `ngrok.exe` to an accessible folder (e.g., `C:\ngrok\`)

### Step 2: Account Setup

1. Sign up for free at: https://dashboard.ngrok.com/signup
2. Log in to dashboard
3. Copy your **Authtoken** from: https://dashboard.ngrok.com/get-started/your-authtoken

### Step 3: Configure Authentication

Run once (replace `YOUR_AUTHTOKEN` with actual token):

```bash
C:\ngrok\ngrok.exe config add-authtoken YOUR_AUTHTOKEN
```

---

## Usage Options

### Option 1: API Backend Only (Free Plan)

> [!NOTE]
> This option tunnels only the HTTP API. MQTT still requires same WiFi network.

**Step 1:** Start backend services

```bash
cd c:\WisnuDarmawan\Coding\Project\flutter-cea-system
python run_services.py
```

**Step 2:** Start NGROK tunnel (new terminal)

```bash
C:\ngrok\ngrok.exe http 8000
```

**Step 3:** Copy the forwarding URL

```
Forwarding    https://abcd-1234-5678.ngrok-free.app -> http://localhost:8000
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
              Copy this URL
```

**Step 4:** Update mobile app configuration

**File:** `apps/mobile/.env`

```env
MQTT_HOST=<IP_KOMPUTER>  # Keep local IP if phone on same WiFi
MQTT_PORT=1883
API_BASE_URL=https://abcd-1234-5678.ngrok-free.app  # Use ngrok URL
```

> [!WARNING]
> MQTT still uses local IP because ngrok free plan only supports HTTP/HTTPS. Phone must remain on same WiFi for MQTT connectivity.

---

### Option 2: API + MQTT Tunneling (Paid Plan)

> [!CAUTION]
> MQTT tunneling requires ngrok **paid plan** as the free plan does not support TCP tunneling.

If you have ngrok premium:

```bash
# Terminal 1: API tunnel
C:\ngrok\ngrok.exe http 8000

# Terminal 2: MQTT tunnel
C:\ngrok\ngrok.exe tcp 1883
```

Then update configuration:

**File:** `apps/mobile/.env`

```env
MQTT_HOST=0.tcp.ngrok.io  # Adjust based on ngrok output
MQTT_PORT=12345           # Port from ngrok output
API_BASE_URL=https://abcd-1234-5678.ngrok-free.app
```

---

## Setup Checklist

| Task | Action |
|------|--------|
| Install NGROK | [Download from ngrok.com](https://ngrok.com/download) |
| Configure authtoken | `ngrok config add-authtoken <TOKEN>` |
| Start backend services | `python run_services.py` |
| Start NGROK tunnel | `ngrok http 8000` |
| Update `.env` with URL | Copy URL to `API_BASE_URL` |
| Rebuild APK | `flutter build apk` |

---

## Testing NGROK Connection

Open your phone's browser (using cellular data):

```
https://your-ngrok-url.ngrok-free.app/kits
```

> [!TIP]
> If you see `[]` or a list of kits, NGROK is configured correctly!

---

## NGROK Best Practices

| Feature | Description |
|---------|-------------|
| Dynamic URLs | Free tier generates new URLs on each restart. Save the URL or upgrade to paid plan. |
| Custom domains | Paid plan supports custom domains that remain constant. |
| Request monitoring | Access `http://localhost:4040` to view ngrok request logs. |
| Session limits | Free tier has 2-hour session limit. Restart ngrok if it times out. |

---

## Comparison: Local WiFi vs NGROK

| Feature | Local WiFi | NGROK |
|---------|-----------|-------|
| Connection Type | Same network required | Internet-based (anywhere) |
| Speed | Very fast | Depends on internet speed |
| Setup Complexity | Simple (local IP only) | Requires ngrok installation |
| Cost | Free | Free (limited) / Paid (full features) |
| MQTT Support | Full support | Free plan does NOT support TCP |
| Best For | Development | Remote demos/testing |

---

# Utilities

## Finding Computer IP Address

```bash
ipconfig | findstr "IPv4"
```

Look for the IPv4 address under your active WiFi adapter.

---

# Troubleshooting

| Issue | Solution |
|-------|----------|
| App cannot connect | Verify IP address in `.env` matches computer IP |
| Connection refused | Add firewall rules for ports 8000 and 1883 |
| Monitor screen stuck loading | Ensure MQTT broker is running and `MQTT_HOST` is correct |
| APK install fails | Enable "Install from unknown sources" in Android settings |
| `run_services.py` port error | Close other CMD windows using port 8000 |
| NGROK URL changes | Free tier generates new URLs each restart; use paid plan for static URLs |
| MQTT not working with NGROK | MQTT requires TCP tunneling (paid plan) or same WiFi network |

---

## Development Recommendations

> [!TIP]
> For development, use **Android Emulator** with `flutter run` for hot-reload capabilities. Only build APK for final testing and deployment.

> [!TIP]
> Use **local WiFi** setup for fastest development iteration. Reserve NGROK for remote demos or testing from outside the local network.
