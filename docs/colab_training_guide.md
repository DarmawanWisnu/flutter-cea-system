# Google Colab Training Guide

## 📁 **Updated Features**

The `colab_training.ipynb` now includes:

### ✅ **1. Load 2 CSV Files**
- Upload `synthetic_telemetry.csv`
- Upload `synthetic_actuator_event.csv`
- Automatically merges them by `id`, `deviceId`, and `ingestTime`

### 📊 **2. Comprehensive Visualizations**

#### **Data Analysis:**
- Action vs No-Action pie chart
- Actuator activation frequency
- Feature distribution histograms

#### **Training Metrics:**
- MAE (Mean Absolute Error) comparison
- RMSE (Root Mean Square Error)
- R² Score (model accuracy)
- Feature importance ranking

#### **Prediction Quality:**
- Predicted vs Actual scatter plots for each actuator
- Visual assessment of model performance

---

## 🚀 **How to Use**

### **Step 1: Open in Google Colab**

1. Go to [colab.research.google.com](https://colab.research.google.com/)
2. Click **File > Upload notebook**
3. Upload `services/ml/colab_training.ipynb`

### **Step 2: Run All Cells**

1. Click **Runtime > Run all**
2. When prompted, upload **BOTH CSV files**:
   - `synthetic_telemetry.csv`
   - `synthetic_actuator_event.csv`

### **Step 3: Review Visualizations**

The notebook will automatically display:

#### 📊 **Cell 4: Dataset Analysis**
- Shows action distribution
- Feature distributions
- Data quality check

#### 📈 **Cell 8: Performance Metrics**
- MAE, RMSE, R² for each actuator
- Train vs Test comparison
- Feature importance

#### 🎯 **Cell 9: Prediction Accuracy**
- Scatter plots showing predicted vs actual
- Visual assessment of model fit

---

## 📈 **Understanding the Graphs**

### **1. Action Distribution Pie Chart**
- Should show ~85% Action, ~15% No Action
- Confirms dataset diversity

### **2. Actuator Frequency Bar Chart**
- **Refill** should be highest (~84%)
- **phUp** moderate (~33%)
- **phDown** low (~2%)
- **nutrientAdd** very low (~0.2%)

### **3. MAE/RMSE Bar Charts**
**Lower is better!**
- Good: MAE < 2.0
- Excellent: MAE < 1.0
- Check that Train ≈ Test (no overfitting)

### **4. R² Score**
**Higher is better!** (0 to 1)
- **R² > 0.8:** Excellent
- **R² > 0.6:** Good
- **R² > 0.4:** Acceptable
- **R² < 0.4:** Poor (retrain needed)

### **5. Feature Importance**
Shows which sensors matter most:
- High importance: Model relies heavily
- Low importance: Could remove to speed up

### **6. Predicted vs Actual Scatter**
- Points close to red line = good predictions
- Wide scatter = poor predictions
- Check for systematic bias (all above/below line)

---

## ✅ **What to Look For**

### **Good Training:**
- ✅ R² > 0.7 for all actuators
- ✅ Test MAE similar to Train MAE
- ✅ Scatter points close to diagonal line
- ✅ No extreme outliers

### **Bad Training (Retrain!):**
- ❌ R² < 0.5
- ❌ Test MAE >> Train MAE (overfitting)
- ❌ Wide scatter on prediction plots
- ❌ Systematic prediction bias

---

## 📦 **Download Trained Model**

After training completes, the notebook will:
1. Create a timestamped version folder (e.g., `v20251202T054500Z`)
2. Save:
   - `model.pkl` (trained model)
   - `scaler.pkl` (feature scaler)
   - `metadata.json` (metrics and info)
3. Zip and auto-download

---

## 🔄 **Deploy to Your System**

1. Extract the downloaded zip
2. Copy the version folder to:
   ```
   services/ml/model_registry/v20251202T054500Z/
   ```
3. Update `services/ml/predictor.py` to use the new version
4. Re-enable ML in `actuator.py` by uncommenting the ML code

---

## 💡 **Tips**

- **First run:** Review all graphs to ensure data quality
- **Iterative training:** Adjust hyperparameters if R² is low
- **Compare versions:** Keep old models to compare performance
- **Production deployment:** Only deploy if R² > 0.7

**Good luck training!** 🚀
