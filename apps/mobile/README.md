# 📱 Fountaine Mobile App

*Hydroponic Monitoring App — Flutter + Firebase + MQTT + Fuzzy Logic*

![Flutter](https://img.shields.io/badge/Flutter-3.38.1-02569B)
![Dart](https://img.shields.io/badge/Dart-3.10.0-0175C2)
![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28)
![MQTT](https://img.shields.io/badge/MQTT-10.11.1-660066)

---

## 📋 **Table of Contents**

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Fuzzy Logic](#fuzzy-logic)
- [Setup & Installation](#setup--installation)
- [Project Structure](#project-structure)
- [MQTT Integration](#mqtt-integration)
- [Build & Deployment](#build--deployment)
- [Code Quality](#code-quality)
- [Troubleshooting](#troubleshooting)

---

## 🎯 **Overview**

Fountaine is an intelligent hydroponic monitoring mobile application that provides real-time plant condition monitoring using IoT technology. Built with Flutter and Firebase, featuring MQTT communication and **fuzzy logic** for smart notifications.

**Key Information:**

| Property | Value |
|----------|-------|
| **Name** | Fountaine |
| **Category** | IoT Hydroponic Monitoring |
| **Platform** | Android & iOS |
| **Flutter SDK** | 3.35.0 – 4.x |
| **Min Android** | API 21 (Lollipop) |
| **Min iOS** | iOS 12.0 |

---

## ✨ **Features**

### **🤖 Intelligent Monitoring**
- **Fuzzy Logic Notifications** - Smart severity determination (info/warning/urgent)
- **Real-time Telemetry** - Live sensor data via MQTT
- **Multi-device Support** - Monitor multiple hydroponic kits
- **Historical Charts** - Visualize sensor trends with fl_chart

### **🎛️ Control**
- **Manual Mode** - Direct actuator control
- **Auto Mode** - ML-powered automation (backend)
- **Remote Control** - Control from anywhere via MQTT

### **👤 User Management**
- **Firebase Authentication** - Secure login/register
- **Email Verification** - Account security
- **Password Reset** - Forgot password flow
- **Profile Management** - User settings

### **📊 Visualization**
- **Real-time Dashboard** - Live sensor readings
- **Historical Graphs** - Trend analysis
- **Notification Center** - Smart alerts
- **Kit Management** - Add/remove devices

---

## 🛠️ **Tech Stack**

### **Core**

| Layer | Technology |
|-------|------------|
| **Framework** | Flutter 3.38.1 |
| **Language** | Dart 3.10.0 |
| **Backend** | Firebase + FastAPI |
| **Auth** | Firebase Auth |
| **Realtime** | MQTT (HiveMQ) |
| **State** | Riverpod 3.0.3 |
| **Storage** | SharedPreferences |
| **Charts** | fl_chart 1.1.1 |

### **Key Dependencies**

| Package | Version | Purpose |
|---------|---------|---------|
| `firebase_core` | ^4.1.0 | Firebase initialization |
| `firebase_auth` | ^6.0.2 | Authentication |
| `mqtt_client` | ^10.11.1 | MQTT communication |
| `flutter_riverpod` | ^3.0.3 | State management |
| `fl_chart` | ^1.1.1 | Charts & graphs |
| `http` | ^1.5.0 | HTTP requests |
| `shared_preferences` | ^2.5.3 | Local storage |
| `intl` | ^0.20.2 | Date formatting |

---

## 🏗️ **Architecture**

### **Pattern: Clean-ish Architecture**

```
┌─────────────────────────────────────┐
│     Presentation Layer (UI)         │
│  features/home, monitor, etc.       │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│     State Management (Riverpod)     │
│  providers/mqtt, api, auth          │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│     Domain Layer (Logic)            │
│  core/fuzzy.dart, constants         │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│     Services Layer                  │
│  MQTT, Firebase, HTTP               │
└─────────────────────────────────────┘
```

### **Layers**

1. **Presentation** - UI widgets and screens (`features/`)
2. **State** - Riverpod providers (`providers/`)
3. **Domain** - Business logic and fuzzy logic (`core/`)
4. **Services** - External integrations (`services/`)

---

## 🧠 **Fuzzy Logic**

### **Notification Severity System**

The app uses **fuzzy logic** to determine notification severity based on sensor deviations:

```dart
// Fuzzy membership functions
low:    0-20% deviation  → info
medium: 15-50% deviation → warning
high:   45%+ deviation   → urgent
```

### **Decision Rules**

1. **Any parameter highly deviated** (>45%) → **Urgent**
2. **2+ parameters medium deviated** (20-50%) → **Urgent**
3. **Any parameter medium deviated** → **Warning**
4. **All parameters stable** → **Info**

### **Ideal Ranges**

| Parameter | Min | Max | Ideal |
|-----------|-----|-----|-------|
| **pH** | 5.5 | 6.5 | 5.5-6.5 |
| **PPM** | 560 | 840 | 560-840 |
| **Temperature** | 18°C | 24°C | 18-24°C |
| **Water Level** | 1.2 | 2.5 | 1.2-2.5 |

**Implementation:** `lib/core/fuzzy.dart`

---

## 🚀 **Setup & Installation**

### **Prerequisites**
- Flutter SDK 3.35.0+
- Dart 3.10.0+
- Android Studio / Xcode
- Firebase project

### **Installation Steps**

```bash
# 1. Clone repository
git clone <your-repo>
cd flutter-cea-system/apps/mobile

# 2. Install dependencies
flutter pub get

# 3. Configure Firebase
# - Add google-services.json (Android)
# - Add GoogleService-Info.plist (iOS)

# 4. Run app
flutter run
```

### **Environment Setup**

Create `.env` file (if needed):
```env
API_BASE_URL=http://your-backend-url:8000
MQTT_BROKER=your-mqtt-broker
```

---

## 📁 **Project Structure**

```
lib/
├── app/                    # App routing & navigation
├── core/                   # Core utilities
│   ├── constants.dart      # App constants
│   └── fuzzy.dart          # Fuzzy logic system ⭐
├── domain/                 # Business logic
├── features/               # Feature modules
│   ├── auth/               # Login, register, verify
│   ├── home/               # Home dashboard
│   ├── monitor/            # Real-time monitoring ⭐
│   ├── history/            # Historical data
│   ├── notifications/      # Notification center ⭐
│   ├── profile/            # User profile
│   ├── settings/           # App settings
│   ├── splash/             # Splash screen
│   └── add_kit/            # Add new kit
├── models/                 # Data models
├── providers/              # Riverpod providers
│   ├── api_provider.dart   # HTTP API
│   ├── auth_provider.dart  # Authentication
│   ├── mqtt_provider.dart  # MQTT connection ⭐
│   ├── monitor_provider.dart # Monitor state
│   └── notification_provider.dart # Fuzzy notifications ⭐
├── services/               # External services
│   ├── api_service.dart    # HTTP client
│   ├── mqtt_service.dart   # MQTT client
│   └── storage_service.dart # Local storage
├── utils/                  # Utilities
└── main.dart               # App entry point
```

**⭐ = Key files for ML/IoT integration**

---

## 📡 **MQTT Integration**

### **Data Flow**

```
┌─────────────┐
│  IoT Kit    │ Publish telemetry
│  (ESP32)    │ every 5 seconds
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ MQTT Broker │ HiveMQ Cloud
│  (TLS 8883) │ QoS 1
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Flutter App │ Subscribe
│ mqtt_client │ Update UI
└─────────────┘
```

### **Topics**

| Topic | Direction | Purpose |
|-------|-----------|---------|
| `kit/{kitId}/telemetry` | Kit → App | Sensor data |
| `kit/{kitId}/status` | Kit ↔ App | Online/offline |
| `kit/{kitId}/control` | App → Kit | Commands |

### **Payload Example**

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

**See:** [ICD Documentation](../../docs/icd.md)

---

## 📦 **Build & Deployment**

### **Android**

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release
```

### **iOS**

```bash
# Install pods
cd ios && pod install && cd ..

# Build
flutter build ios --release

# Note: Requires macOS and Xcode
```

### **Release Checklist**

- [ ] Update version in `pubspec.yaml`
- [ ] Add Firebase config files
- [ ] Configure signing certificates
- [ ] Test on physical devices
- [ ] Run `flutter analyze`
- [ ] Run `flutter test`

---

## ✅ **Code Quality**

### **Analysis Results**

```
Total Issues: 83
Errors: 0
Warnings: 0
Info: 83 (code quality suggestions)
```

**Status:** ✅ **Production Ready**

### **Main Issues**

1. 🔵 BuildContext async gaps (~40) - Add `if (!mounted) return;`
2. 🔵 Print statements (~20) - Replace with logger
3. 🔵 Deprecated APIs (~10) - Update to new APIs

**See:** [Flutter App Audit](../../docs/flutter_app_audit.md)

---

## 🐛 **Troubleshooting**

| Issue | Cause | Fix |
|-------|-------|-----|
| **MQTT not connecting** | Wrong broker URL | Check `.env` or hardcoded URL |
| **No data received** | Topic mismatch | Verify publish/subscribe topics |
| **Firebase error** | Missing SHA fingerprint | Add SHA-1 & SHA-256 to Firebase |
| **Build fails** | Dependency conflict | Run `flutter clean && flutter pub get` |
| **Fuzzy logic not working** | Missing imports | Check `core/fuzzy.dart` imports |
| **Notifications not showing** | Provider not listening | Verify Riverpod setup |

---

## 📚 **Documentation**

- [Main README](../../README.md) - Project overview
- [ICD](../../docs/icd.md) - MQTT communication protocol
- [ML Algorithm](../../docs/ml_algorithm_explanation.md) - Backend ML system
- [App Audit](../../docs/flutter_app_audit.md) - Code quality report

---

## 🧪 **Testing**

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

---

## 🎨 **UI/UX**

### **Design System**
- **Primary Color:** Blue (#2196F3)
- **Accent Color:** Green (#4CAF50)
- **Typography:** Roboto
- **Icons:** Material Icons

### **Screens**
- Splash Screen
- Login/Register
- Home Dashboard
- Monitor (Real-time)
- History Charts
- Notifications
- Profile
- Settings

---

## 📄 **License**

© **Wisnu Darmawan 2025** — MIT License

---

**Built with ❤️ for sustainable agriculture** 🌱