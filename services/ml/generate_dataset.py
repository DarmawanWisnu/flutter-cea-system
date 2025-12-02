import csv
import os
import time
import random

# Define paths
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
INPUT_CSV = os.path.join(BASE_DIR, "mqtt", "data.csv")
OUTPUT_TELEMETRY = os.path.join(os.path.dirname(__file__), "synthetic_telemetry.csv")
OUTPUT_ACTUATOR = os.path.join(os.path.dirname(__file__), "synthetic_actuator_event.csv")

# Device IDs
DEVICES = ["CEA-01", "CEA-02"]
TARGET_ROWS_PER_DEVICE = 12500
TOTAL_ROWS = 25000

def parse_telemetry(row):
    """Extract telemetry values from CSV row."""
    try:
        return {
            "ppm": float(row.get("TDS") or row.get("tds") or row.get("ppm") or 0),
            "ph": float(row.get("pH") or row.get("ph") or 0),
            "tempC": float(row.get("DHT_temp") or row.get("dht_temp") or row.get("tempC") or 0),
            "humidity": float(row.get("DHT_humidity") or row.get("dht_humidity") or row.get("humidity") or 0),
            "waterLevel": float(row.get("water_level") or row.get("waterLevel") or 0),
            "waterTemp": float(row.get("water_temp") or row.get("waterTemp") or 0),
        }
    except (ValueError, TypeError):
        return None

def calculate_actuator_values(ph, ppm, wl):
    """
    Apply PRIORITY-BASED rule logic to calculate actuator values.
    Matches the FIXED logic in actuator.py (prevents conflicting actions).
    
    Priority Order:
    1. Critical water level (safety)
    2. High PPM dilution
    3. pH adjustment
    4. Nutrient addition
    5. Micro-adjustments
    """
    phUpSec = 0
    phDownSec = 0
    nutrientSec = 0
    refillSec = 0

    # PRIORITY 1: Critical Water Level (Safety First)
    if wl < 1.2:
        refillSec = max(0, min(25, (1.2 - wl) * 20))
    
    # PRIORITY 2: High PPM Dilution (only if water level allows)
    elif ppm > 840 and wl < 2.5:
        refillSec = max(0, min(15, (ppm - 840) / 20))
    
    # PRIORITY 3: pH Adjustment (only if water/PPM stable)
    elif ph < 5.5 or ph > 6.5:
        if ph < 5.5:
            phUpSec = max(0, min(12, (5.5 - ph) * 8))
        elif ph > 6.5:
            phDownSec = max(0, min(12, (ph - 6.5) * 8))
    
    # PRIORITY 4: Nutrient Addition (only if pH stable)
    elif ppm < 560:
        nutrientSec = max(0, min(20, (560 - ppm) / 20))
    
    # PRIORITY 5: Micro-adjustments (fine-tuning when all stable)
    else:
        if 5.5 <= ph < 5.7:
            phUpSec = 1
        elif 6.3 < ph <= 6.5:
            phDownSec = 1
        elif 560 <= ppm < 650:
            nutrientSec = 1
        elif 1.2 <= wl < 1.5:
            refillSec = 1

    valueS = float(max(phUpSec, phDownSec, nutrientSec, refillSec))

    return {
        "phUp": int(phUpSec),
        "phDown": int(phDownSec),
        "nutrientAdd": int(nutrientSec),
        "refill": int(refillSec),
        "valueS": valueS
    }


def main():
    print(f"Reading source data from: {INPUT_CSV}")
    
    if not os.path.exists(INPUT_CSV):
        print("❌ Error: Input CSV not found!")
        return

    # Read all source rows
    source_rows = []
    with open(INPUT_CSV, 'r', newline='', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            telemetry = parse_telemetry(row)
            if telemetry:
                source_rows.append(telemetry)

    print(f"✓ Loaded {len(source_rows)} source rows")

    # Generate synthetic data
    telemetry_data = []
    actuator_data = []
    
    start_time = int(time.time() * 1000)  # Current timestamp in ms
    record_id = 1

    for device in DEVICES:
        print(f"\nGenerating {TARGET_ROWS_PER_DEVICE} rows for {device}...")
        
        for i in range(TARGET_ROWS_PER_DEVICE):
            # Randomly pick a source row
            source = random.choice(source_rows)
            
            # Create timestamp (incrementing)
            ingest_time = start_time + (record_id * 1000)  # 1 second apart
            
            # Telemetry record
            # Schema: rowId, deviceId, ingestTime, payloadJson, ppm, ph, tempC, humidity, waterTemp, waterLevel, payloadHash
            
            row_uuid = f"{device}-{ingest_time}-{record_id}"
            payload_dict = {
                "ppm": source["ppm"],
                "ph": source["ph"],
                "tempC": source["tempC"],
                "humidity": source["humidity"],
                "waterLevel": source["waterLevel"],
                "waterTemp": source["waterTemp"]
            }
            import json
            import hashlib
            payload_json = json.dumps(payload_dict)
            payload_hash = hashlib.md5(payload_json.encode()).hexdigest() + f"-{record_id}"

            telemetry_record = {
                "rowId": str(record_id), # Using simple ID as rowId for simplicity
                "deviceId": device,
                "ingestTime": ingest_time,
                "payloadJson": payload_json,
                "ppm": source["ppm"],
                "ph": source["ph"],
                "tempC": source["tempC"],
                "humidity": source["humidity"],
                "waterLevel": source["waterLevel"],
                "waterTemp": source["waterTemp"],
                "payloadHash": payload_hash
            }
            telemetry_data.append(telemetry_record)
            
            # Calculate actuator values
            actuator_values = calculate_actuator_values(
                source["ph"],
                source["ppm"],
                source["waterLevel"]
            )
            
            # Actuator record
            actuator_record = {
                "id": record_id,
                "deviceId": device,
                "ingestTime": ingest_time,
                "phUp": actuator_values["phUp"],
                "phDown": actuator_values["phDown"],
                "nutrientAdd": actuator_values["nutrientAdd"],
                "valueS": actuator_values["valueS"],
                "manual": 0,
                "auto": 1,  # All from auto mode
                "refill": actuator_values["refill"]
            }
            actuator_data.append(actuator_record)
            
            record_id += 1

    # Write Telemetry CSV
    telemetry_fields = ["rowId", "deviceId", "ingestTime", "payloadJson", "ppm", "ph", "tempC", 
                        "humidity", "waterTemp", "waterLevel", "payloadHash"]
    
    with open(OUTPUT_TELEMETRY, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=telemetry_fields)
        writer.writeheader()
        writer.writerows(telemetry_data)
    
    print(f"\n✅ Telemetry CSV: {OUTPUT_TELEMETRY}")
    print(f"   Total rows: {len(telemetry_data)}")

    # Write Actuator Event CSV
    actuator_fields = ["id", "deviceId", "ingestTime", "phUp", "phDown", 
                       "nutrientAdd", "valueS", "manual", "auto", "refill"]
    
    with open(OUTPUT_ACTUATOR, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=actuator_fields)
        writer.writeheader()
        writer.writerows(actuator_data)
    
    print(f"✅ Actuator CSV: {OUTPUT_ACTUATOR}")
    print(f"   Total rows: {len(actuator_data)}")

    # Statistics
    actions_taken = sum(1 for r in actuator_data if r["phUp"] > 0 or r["phDown"] > 0 
                       or r["nutrientAdd"] > 0 or r["refill"] > 0)
    action_rate = (actions_taken / len(actuator_data)) * 100
    
    print(f"\n📊 Dataset Statistics:")
    print(f"   Total records: {len(actuator_data)}")
    print(f"   CEA-01: {len([r for r in actuator_data if r['deviceId'] == 'CEA-01'])}")
    print(f"   CEA-02: {len([r for r in actuator_data if r['deviceId'] == 'CEA-02'])}")
    print(f"   Action events: {actions_taken} ({action_rate:.1f}%)")
    print(f"   No-action events: {len(actuator_data) - actions_taken} ({100-action_rate:.1f}%)")

    # Sample data
    print(f"\n📝 Sample Records:")
    for i in range(min(3, len(telemetry_data))):
        print(f"\n   Telemetry #{i+1}: {telemetry_data[i]}")
        print(f"   Actuator  #{i+1}: {actuator_data[i]}")

if __name__ == "__main__":
    main()
