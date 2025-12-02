# Synthetic Dataset Generation - Summary

## ✅ Generated Files

Two CSV files have been created in `services/ml/`:

### 1. `synthetic_telemetry.csv`
Matches the `telemetry` database table structure:
- **Columns:** `rowId`, `deviceId`, `ingestTime`, `payloadJson`, `ppm`, `ph`, `tempC`, `humidity`, `waterTemp`, `waterLevel`, `payloadHash`
- **Rows:** 25,000 total
  - 12,500 for CEA-01
  - 12,500 for CEA-02

### 2. `synthetic_actuator_event.csv`
Matches the `actuator_event` database table structure:
- **Columns:** `id`, `deviceId`, `ingestTime`, `phUp`, `phDown`, `nutrientAdd`, `valueS`, `manual`, `auto`, `refill`
- **Rows:** 25,000 total
  - 12,500 for CEA-01
  - 12,500 for CEA-02

---

## 🔗 Data Relationship

Both files are **perfectly linked**:
- **Same `id`** for matching telemetry and actuator records
- **Same `deviceId`** 
- **Same `ingestTime`** timestamp
- For every telemetry row, there's a corresponding actuator row

Example:
```csv
# synthetic_telemetry.csv row #1:
id=1, deviceId=CEA-01, ingestTime=1764628843851, ppm=782.54, ph=5.41, ...

# synthetic_actuator_event.csv row #1:
id=1, deviceId=CEA-01, ingestTime=1764628843851, phUp=0, phDown=0, nutrientAdd=0, refill=15
```

---

## 🧠 Rule-Based Logic Applied

The actuator values follow the **corrected logic** from `actuator.py`:

### pH Control:
- **pH < 5.5** → `phUp` activated
- **pH > 6.5** → `phDown` activated
- Micro-adjustments for 5.5 ≤ pH ≤ 6.5

### Nutrient Control:
- **PPM < 560** → `nutrientAdd` activated
- Micro-adjustments for 560 ≤ PPM ≤ 840

### Refill Control:
- **Water Level < 1.2** → `refill` activated (low water)
- **PPM > 840** → `refill` activated (dilution) ✅ **This is the fix!**
- Micro-adjustments for 1.2 ≤ Water ≤ 2.5

---

## 📊 Expected Dataset Quality

Based on your source data analysis:
- **~85% of rows have High PPM (> 840)**
- With the corrected logic, you should see:
  - **~70-80% action events** (refill triggered for dilution)
  - **~20-30% no-action events** (everything normal)

This is **perfect for ML training**! 🎯

---

## 💾 Option 1: Import to Database

If you want to import this data into your PostgreSQL database:

```sql
-- Clear existing data (optional)
TRUNCATE TABLE telemetry, actuator_event;

-- Import telemetry
COPY telemetry ("rowId", "deviceId", "ingestTime", "payloadJson", ppm, ph, "tempC", 
                humidity, "waterTemp", "waterLevel", "payloadHash")
FROM 'C:\WisnuDarmawan\Coding\Project\flutter-cea-system\services\ml\synthetic_telemetry.csv' 
WITH CSV HEADER;

-- Import actuator events
COPY actuator_event (id, "deviceId", "ingestTime", "phUp", "phDown", 
                     "nutrientAdd", "valueS", manual, auto, refill)
FROM 'C:\WisnuDarmawan\Coding\Project\flutter-cea-system\services\ml\synthetic_actuator_event.csv' 
WITH CSV HEADER;
```

---

## 🤖 Option 2: Use Directly for ML Training

You **don't need** to import to the database! You can train the ML model directly from the CSV files.

Update your `services/ml/dataset_loader.py` or training script:

```python
import pandas as pd

# Load the synthetic datasets
telemetry_df = pd.read_csv('services/ml/synthetic_telemetry.csv')
actuator_df = pd.read_csv('services/ml/synthetic_actuator_event.csv')

# Merge on id, deviceId, ingestTime
training_data = pd.merge(
    telemetry_df,
    actuator_df,
    on=['id', 'deviceId', 'ingestTime'],
    suffixes=('_telemetry', '_actuator')
)

# Features (input to ML)
X = training_data[['ppm', 'ph', 'tempC', 'humidity', 'waterLevel']]

# Labels (output from ML)
y = training_data[['phUp', 'phDown', 'nutrientAdd', 'refill']]

# Train your model
# model.fit(X, y)
```

---

## ✅ Verification

Sample verification query (if you import to DB):

```sql
SELECT 
    COUNT(*) as total,
    COUNT(CASE WHEN "phUp" > 0 OR "phDown" > 0 OR "nutrientAdd" > 0 OR "refill" > 0 THEN 1 END) as with_action,
    COUNT(CASE WHEN "phUp" = 0 AND "phDown" = 0 AND "nutrientAdd" = 0 AND "refill" = 0 THEN 1 END) as all_zeros
FROM actuator_event
WHERE auto = 1;
```

Expected result:
- **Total:** 25,000
- **With action:** ~18,000-20,000 (70-80%)
- **All zeros:** ~5,000-7,000 (20-30%)

---

## 🎯 Next Steps

1. ✅ **Dataset Generated** (Done!)
2. **Option A:** Import to database using SQL COPY commands above
3. **Option B:** Use CSVs directly for ML training
4. **Train ML Model** using the new dataset
5. **Re-enable ML** in `actuator.py` by uncommenting the ML code

