# Interface Control Document (ICD)

## Hydroponic Kit ↔ App Communication (MQTT)

This document defines the communication contract between IoT devices (kits) and the mobile application using the MQTT protocol. It ensures consistent, standardized, and testable integration between the IoT system and application.

---

## 📡 **1. Broker & Identity**

| Parameter | Value |
|-----------|-------|
| **Broker** | HiveMQ Cloud (TLS port 8883) |
| **QoS Default** | 1 |
| **Kit ID Format** | String without spaces (e.g., `CEA-01`, `CEA-02`) |
| **ClientID (App)** | `fountaine-app-{epoch}` |
| **ClientID (Kit)** | `fountaine-kit-{kitId}` |
| **Authentication** | Username & Password (from HiveMQ) |
| **Protocol Version** | MQTT 3.1.1 |

### **Last Will Testament (LWT)**
When a kit disconnects abnormally, the broker sends a retained message to the status topic:
```json
{
  "online": false,
  "ts": "2025-12-02T00:00:00Z"
}
```

---

## 📬 **2. Topics**

| Topic | Direction | QoS | Retained | Description |
|-------|-----------|-----|----------|-------------|
| `kit/{kitId}/telemetry` | Kit → App | 1 | No | Periodic sensor data (~5 seconds) |
| `kit/{kitId}/status` | Kit ↔ App | 1 | Yes | Online/offline status (LWT) |
| `kit/{kitId}/control` | App → Kit | 1 | No | Control commands from app |

---

## 📦 **3. Payload Schemas**

### **3.1 Telemetry** (`kit/{kitId}/telemetry`)

**Example:**
```json
{
  "ts": "2025-12-02T00:00:00Z",
  "ppm": 930.0,
  "ph": 6.03,
  "tempC": 27.1,
  "humidity": 65.0,
  "waterLevel": 2.1,
  "waterTemp": 22.5
}
```

**Field Descriptions:**

| Field | Type | Range | Description |
|-------|------|-------|-------------|
| `ts` | string | ISO 8601 UTC | Data collection timestamp |
| `ppm` | float | 0–2000 | Nutrient concentration (TDS) |
| `ph` | float | 0–14 | Acidity level |
| `tempC` | float | 0–50 | Air temperature (°C) |
| `humidity` | float | 0–100 | Relative humidity (%) |
| `waterLevel` | float | 0–3 | Water level (0=empty, 3=full) |
| `waterTemp` | float | 0–40 | Water temperature (°C) |

---

### **3.2 Status** (`kit/{kitId}/status`)

**Example:**
```json
{
  "online": true,
  "ts": "2025-12-02T00:00:00Z"
}
```

**Notes:**
- **Retained:** ON
- Kit sends `online: true` when successfully connected
- Broker sends `online: false` when kit disconnects (LWT active)

---

### **3.3 Control** (`kit/{kitId}/control`)

**Example:**
```json
{
  "cmd": "phUp",
  "args": {
    "duration": 3
  },
  "ts": "2025-12-02T00:00:00Z",
  "by": "app",
  "mode": "manual"
}
```

**Command List:**

| Command | Args | Description |
|---------|------|-------------|
| `phUp` | `{ duration: number }` | Add pH Up solution for N seconds |
| `phDown` | `{ duration: number }` | Add pH Down solution for N seconds |
| `nutrientAdd` | `{ duration: number }` | Add nutrient A+B for N seconds |
| `refill` | `{ duration: number }` | Add water for N seconds |
| `setMode` | `{ mode: "manual" \| "auto" }` | Change operation mode |

**Field Descriptions:**

| Field | Type | Description |
|-------|------|-------------|
| `cmd` | string | Command name |
| `args` | object | Command arguments |
| `ts` | string | Command timestamp (ISO 8601 UTC) |
| `by` | string | Source: `"app"` or `"auto"` |
| `mode` | string | Current mode: `"manual"` or `"auto"` |

---

## 🛡️ **4. Safety Rules & Control Logic**

### **Priority-Based Control System**

The system uses a **priority-based approach** to prevent conflicting actions:

1. **Priority 1:** Critical water level (< 1.2) → Refill ONLY
2. **Priority 2:** High PPM (> 840) → Dilute (if water < 2.5)
3. **Priority 3:** pH out of range (< 5.5 or > 6.5) → Adjust pH
4. **Priority 4:** Low PPM (< 560) → Add nutrient
5. **Priority 5:** Micro-adjustments → Fine-tuning

### **Safety Limits**

| Parameter | Min | Max | Ideal Range |
|-----------|-----|-----|-------------|
| **pH** | 5.5 | 6.5 | 5.5 - 6.5 |
| **PPM** | 560 | 840 | 560 - 840 |
| **Temperature** | 18°C | 24°C | 18 - 24°C |
| **Water Level** | 1.2 | 2.5 | 1.2 - 2.5 |

### **Control Rules**

- **Cooldown:** 3 minutes (180 seconds) between automatic actions per actuator type
- **Critical Bypass:** Cooldown bypassed when parameters reach critical levels (pH <5.0 or >7.0, PPM <400 or >1200, WL <1.0)
- **Manual Priority:** Manual mode disables all automatic actions

---

## 📋 **5. Example Payloads**

### **Telemetry (Kit → App)**
```json
{
  "ts": "2025-12-02T08:00:00Z",
  "ppm": 750.0,
  "ph": 6.1,
  "tempC": 22.5,
  "humidity": 68.0,
  "waterLevel": 2.0,
  "waterTemp": 21.0
}
```

### **Status - Online (Kit → App, Retained)**
```json
{
  "online": true,
  "ts": "2025-12-02T08:00:00Z"
}
```

### **Status - Offline (Broker → App, LWT)**
```json
{
  "online": false,
  "ts": "2025-12-02T08:05:00Z"
}
```

### **Control - Manual (App → Kit)**
```json
{
  "cmd": "phUp",
  "args": {
    "duration": 3
  },
  "ts": "2025-12-02T08:10:00Z",
  "by": "app",
  "mode": "manual"
}
```

### **Control - Auto Mode (App → Kit)**
```json
{
  "cmd": "setMode",
  "args": {
    "mode": "auto"
  },
  "ts": "2025-12-02T08:15:00Z",
  "by": "app"
}
```

---

## 🔄 **6. Auto Mode Behavior**

When `mode: "auto"` is active:

1. **ML Prediction** (Primary)
   - Backend uses Random Forest model
   - Predicts actuator durations based on sensor readings
   - Fallback to rule-based if ML unavailable

2. **Rule-Based Logic** (Fallback)
   - Priority-based system (see section 4)
   - Prevents conflicting actions
   - Ensures chemical efficiency

3. **Actuator Events**
   - Logged to database
   - Includes source (`ml` or `rule`)
   - Tracked for ML retraining

---

## 📊 **7. Data Flow**

```
┌─────────────┐
│  IoT Kit    │
│  (ESP32)    │
└──────┬──────┘
       │ Publish telemetry every 5s
       ▼
┌─────────────┐
│ MQTT Broker │
│  (HiveMQ)   │
└──────┬──────┘
       │ Subscribe
       ▼
┌─────────────┐
│  Backend    │
│  (FastAPI)  │
│             │
│  ┌────────┐ │
│  │   ML   │ │ Auto Mode
│  │ Model  │ │ Prediction
│  └────────┘ │
└──────┬──────┘
       │ Publish control
       ▼
┌─────────────┐
│  IoT Kit    │
│  Execute    │
└─────────────┘
```

---

## 📝 **8. Implementation Notes**

1. **Payload Format**
   - All payloads sent in JSON UTF-8
   - Use QoS 1 for reliability
   - Field `ts` uses real UTC time

2. **Data Types**
   - All numeric values stored as `float`
   - Timestamps in ISO 8601 format
   - Boolean for status flags

3. **Extensibility**
   - Additional fields allowed if core structure unchanged
   - Backward compatibility maintained

4. **Offline Handling**
   - App displays "Offline" status from retained message
   - Last known telemetry cached locally
   - Reconnection automatic

---

## 🌐 **11. REST API Endpoints**

### **11.1 Kit Management**

| Endpoint | Method | Description | Auth Required |
|----------|--------|-------------|---------------|
| `/kits?userId={uid}` | GET | Get user's kits | Yes |
| `/kits` | POST | Add kit to user | Yes |
| `/kits/{id}?userId={uid}` | DELETE | Unlink kit from user | Yes |
| `/kits/all` | GET | Get all kits (for publisher) | No |
| `/kits/with-latest?userId={uid}` | GET | Get kits with latest telemetry | Yes |

**POST /kits Request:**
```json
{
  "id": "CEA-01",
  "name": "Kebun A",
  "userId": "firebase_uid"
}
```

> [!IMPORTANT]
> The `/kits` DELETE only removes the user-kit link, not the global kit record. This allows multiple users to share the same kit.

---

### **11.2 User Preferences**

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/user/preference?userId={uid}` | GET | Get selected kit preference |
| `/user/preference` | POST | Set selected kit preference |

**POST /user/preference Request:**
```json
{
  "userId": "firebase_uid",
  "selectedKitId": "CEA-01"
}
```

---

### **11.3 Notifications**

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/notifications?userId={uid}&days=7` | GET | Get notifications (filtered) |
| `/notifications` | POST | Create notification |
| `/notifications/{id}/read` | PUT | Mark notification as read |
| `/notifications/mark-all-read?userId={uid}` | PUT | Mark all as read |
| `/notifications/{id}` | DELETE | Delete notification |
| `/notifications?userId={uid}` | DELETE | Clear all notifications |

**POST /notifications Request (Manual Mode):**
```json
{
  "userId": "firebase_uid",
  "deviceId": "CEA-01",
  "level": "warning",
  "title": "Warning",
  "message": "pH Low: 5.2, PPM Low: 450"
}
```

**Notification Levels:**
| Level | Description |
|-------|-------------|
| `info` | Informational (all parameters OK) |
| `warning` | Parameters outside threshold |
| `urgent` | Critical deviation requiring action |

---

### **11.4 Telemetry**

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/telemetry?deviceId={id}` | POST | Insert new telemetry data |
| `/telemetry/latest?deviceId={id}` | GET | Get latest telemetry for device |
| `/telemetry/history?deviceId={id}&days=7` | GET | Get telemetry history |

---

### **11.5 Actuator Control**

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/actuator/event?deviceId={id}` | POST | Trigger actuator action |
| `/actuator/latest?deviceId={id}` | GET | Get latest actuator event |
| `/actuator/history?deviceId={id}&limit=50` | GET | Get actuator history |
| `/actuator/all?deviceId={id}` | GET | Get all actuator events |

---

### **11.6 Device Mode**

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/device/mode` | POST | Set auto/manual mode |
| `/device/mode?userId={uid}&deviceId={id}` | GET | Get current mode |
| `/device/auto-enabled` | GET | Get all auto-enabled devices |

---

### **11.7 Machine Learning**

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/ml/predict` | POST | Get ML prediction for actuator durations |

**POST /ml/predict Request:**
```json
{
  "ppm": 750.0,
  "ph": 6.1,
  "tempC": 22.5,
  "humidity": 68.0,
  "waterTemp": 21.0,
  "waterLevel": 2.0
}
```

**Response:**
```json
{
  "phUp": 0,
  "phDown": 0,
  "nutrientAdd": 0,
  "refill": 0,
  "model_version": "v3"
}
```

---

## 📚 **12. Version History**

| Version | Date | Description |
|---------|------|-------------|
| **v1.0** | 2025-10-16 | Initial draft for thesis integration |
| **v1.1** | 2025-11-23 | Added humidity and water temp sensors |
| **v2.0** | 2025-12-02 | Added ML auto mode, priority-based logic |
| **v2.1** | 2025-12-27 | Added per-user kit management, notification persistence |
| **v2.2** | 2025-12-28 | Documentation sync, fixed diagram discrepancies |

---

## ✅ **10. Compliance Checklist**

- [x] All topics follow naming convention
- [x] QoS 1 for all critical messages
- [x] Retained flag for status topic
- [x] LWT configured for offline detection
- [x] JSON schema validated
- [x] Safety limits defined
- [x] Priority system documented
- [x] Example payloads provided

---

## 📞 **Contact**

For questions or clarifications about this ICD:
- **Project:** CEA Hydroponic System
- **Author:** Wisnu Darmawan
- **Last Updated:** 2025-12-28

---

**This document serves as the official reference for development, integration, and testing of communication between the application and IoT Hydroponic Smart Kit.**
