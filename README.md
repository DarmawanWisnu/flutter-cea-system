# 🌱 CEA Hydroponic System - ML-Powered Control

An intelligent hydroponic monitoring and control system with machine learning-based automation, fuzzy logic notifications, and real-time MQTT telemetry.

![System Status](https://img.shields.io/badge/Status-Production%20Ready-green)
![ML Model](https://img.shields.io/badge/ML-Random%20Forest-blue)
![Flutter](https://img.shields.io/badge/Flutter-Mobile%20App-02569B)
![Python](https://img.shields.io/badge/Python-Backend-3776AB)

---

## 📋 **Table of Contents**

- [Overview](#overview)
- [System Architecture](#system-architecture)
- [Features](#features)
- [ML Algorithm](#ml-algorithm)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Documentation](#documentation)
- [Contributing](#contributing)

---

## 🎯 **Overview**

This system provides **automated control** for hydroponic farms using:
- **Machine Learning** (Random Forest Regression) for intelligent actuator control
- **Priority-based rule logic** as fallback and for training data generation
- **Fuzzy logic** for notification severity determination
- **Real-time MQTT** telemetry streaming
- **Flutter mobile app** for monitoring and manual control

### **Key Metrics**
- ✅ ML Model Accuracy: R² > 0.8
- ✅ Prediction Speed: <1ms
- ✅ Zero Conflicting Actions
- ✅ 25,000 training samples

---

## 🏗️ **System Architecture**

```
┌─────────────────┐
│  Flutter App    │ ← User Interface
│  (Mobile)       │
└────────┬────────┘
         │ HTTP/MQTT
┌────────▼────────┐
│  FastAPI        │ ← Backend Services
│  (Python)       │   - Actuator Control
│                 │   - ML Predictions
│                 │   - Rule-based Logic
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
┌───▼──┐  ┌──▼────┐
│ MQTT │  │  ML   │
│ Pub  │  │ Model │
└──────┘  └───────┘
```

---

## ✨ **Features**

### **🤖 Machine Learning Control**
- **Random Forest Regression** (100 trees)
- Multi-output prediction (4 actuators)
- Priority-based action system
- Real-time inference (<1ms)

### **📊 Intelligent Monitoring**
- **Fuzzy logic** notification severity
- Real-time telemetry streaming
- Historical data analysis
- Multi-device support

### **🎛️ Control Modes**
1. **Auto Mode** - ML-powered automation
2. **Manual Mode** - Direct actuator control
3. **Rule-based Fallback** - When ML unavailable

### **📱 Mobile App**
- Real-time monitoring dashboard
- Manual actuator control
- Notification system
- Historical charts

---

## 🧠 **ML Algorithm**

### **Why Random Forest Regression?**

**Algorithm:** Random Forest (Ensemble of 100 Decision Trees)  
**Type:** Supervised Learning → Multi-Output Regression

**Advantages:**
1. ✅ **Perfect for tabular data** (6 sensor inputs)
2. ✅ **Handles non-linear patterns** (priority-based logic)
3. ✅ **Robust to noise** (sensor fluctuations)
4. ✅ **Fast prediction** (<1ms for real-time control)
5. ✅ **Interpretable** (feature importance)
6. ✅ **No overfitting** (train R² ≈ test R²)

**Why NOT Neural Networks?**
- ❌ Need 100k+ samples (we have 25k)
- ❌ Longer training time (60min vs 3min)
- ❌ Black box (hard to explain)
- ❌ Overkill for structured data

**Performance:**
```
R² Score:  > 0.8 (Excellent)
MAE:       < 2.0 (High accuracy)
Conflicts: 0    (Priority system working)
Speed:     <1ms (Real-time ready)
```

---

## 🚀 **Quick Start**

### **Prerequisites**
- Python 3.9+
- Flutter 3.0+
- PostgreSQL 13+
- MQTT Broker (Mosquitto)

### **1. Backend Setup**
```bash
cd services/api
pip install -r requirements.txt
python main.py
```

### **2. MQTT Publisher (Data Simulation)**
```bash
cd services/mqtt
python publisher.py
```

### **3. Mobile App**
```bash
cd apps/mobile
flutter pub get
flutter run
```

### **4. Train ML Model**
```bash
# Generate synthetic dataset
cd services/ml
python generate_dataset.py

# Train locally
python trainer.py

# OR train in Google Colab
# Upload colab_training.ipynb to Colab
# Upload synthetic_telemetry.csv and synthetic_actuator_event.csv
```

---

## 📁 **Project Structure**

```
flutter-cea-system/
├── apps/
│   └── mobile/              # Flutter mobile app
│       ├── lib/
│       │   ├── core/        # Fuzzy logic, constants
│       │   ├── features/    # Screens (home, monitor, etc.)
│       │   ├── providers/   # State management
│       │   └── services/    # API, MQTT clients
│       └── pubspec.yaml
│
├── services/
│   ├── api/                 # FastAPI backend
│   │   ├── main.py          # API server (26 endpoints)
│   │   ├── actuator.py      # Control logic (ML + rules)
│   │   ├── database.py      # PostgreSQL connection
│   │   └── ml_service.py    # ML prediction service
│   │
│   ├── mqtt/                # MQTT services
│   │   ├── publisher.py     # Telemetry simulator
│   │   ├── subscriber.py    # Telemetry listener
│   │   └── data.csv         # Source data
│   │
│   └── ml/                  # Machine Learning
│       ├── generate_dataset.py      # Create training data
│       ├── predictor.py             # Inference
│       ├── ML_RandomForest.ipynb    # Training notebook
│       └── model_registry/          # Trained models (.joblib)
│
├── docs/                    # Documentation
├── run_services.py          # Service runner script
├── config.yaml              # System configuration
└── README.md                # This file
```

---

## 📚 **Documentation**

### **Technical**
- [Control Systems](docs/control-systems.md) - Rule-based, ML, priority system, formulas
- [Interface Control Document](docs/icd.md) - MQTT protocol, REST API (26 endpoints)
- [Flow Analysis](docs/flow_analysis.md) - System architecture & data flow
- [ML vs Rule-Based Analysis](docs/ML_VS_RB_COMPARATIVE_ANALYSIS.md) - Comparative study

### **Testing & Setup**
- [Black Box Testing](docs/BLACK_BOX_TESTING.md) - 15 functional test cases (100% passed)
- [Mobile Setup Guide](docs/setup-hp-guide.md) - Physical device & emulator setup
- [Future Improvements](docs/future_improvement.md) - Planned enhancements

### **UML Diagrams**
Diagrams are available in `docs/diagrams/`:
- Activity diagrams (6 workflows)
- Sequence diagrams (6 interactions)
- Class diagram (5-layer architecture)
- Database ERD (9 tables)
- Use case diagrams

### **API Endpoints**
```
POST /actuator/event        # Trigger actuator action
GET  /telemetry/latest      # Get latest sensor readings
POST /ml/predict            # ML prediction endpoint
```

### **MQTT Topics**
```
telemetry/{deviceId}        # Sensor data
actuator/{deviceId}         # Actuator commands
```

---

## 🔧 **Configuration**

### **Priority-Based Control Logic**

The system uses a **priority system** to prevent conflicting actions:

1. **Priority 1:** Critical water level (< 1.2) → Refill ONLY
2. **Priority 2:** High PPM (> 840) → Dilute (if water < 2.5)
3. **Priority 3:** pH out of range → Adjust pH
4. **Priority 4:** Low PPM (< 560) → Add nutrient
5. **Priority 5:** Micro-adjustments → Fine-tuning

**Why?** Prevents chemical waste (e.g., adding pH Up while diluting).

---

## 🧪 **Testing**

### **ML Files Test**
```bash
cd services/ml
python test_ml_files.py
```

### **Dataset Analysis**
```bash
cd services/ml
python analyze_dataset.py
```

### **Flutter Tests**
```bash
cd apps/mobile
flutter test
flutter analyze
```

---

## 📊 **Performance**

### **ML Model**
- Training Time: 2-3 minutes
- Prediction Time: <1ms
- Model Size: ~50MB
- Accuracy: R² > 0.8

### **System**
- API Response: <100ms
- MQTT Latency: <50ms
- Mobile App: 60 FPS

---

## 🤝 **Contributing**

### **Development Workflow**
1. Create feature branch
2. Make changes
3. Run tests
4. Submit pull request

### **Code Style**
- Python: PEP 8
- Dart: Effective Dart
- Commits: Conventional Commits

---

## 📄 **License**

This project is licensed under the MIT License.

---

## 👥 **Authors**

- **Wisnu Darmawan** - Initial work

---

## 🙏 **Acknowledgments**

- Random Forest algorithm by Leo Breiman
- Flutter framework by Google
- FastAPI by Sebastián Ramírez
- scikit-learn community

---

## 📞 **Support**

For questions or issues:
- Open an issue on GitHub
- Contact: [your-email@example.com]

---

**Built with ❤️ for sustainable agriculture** 🌱
