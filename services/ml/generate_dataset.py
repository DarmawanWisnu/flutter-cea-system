import csv
import os
import time
import random

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
INPUT_CSV = os.path.join(os.path.dirname(__file__), "dataset", "cleaned_data_IsDefault_Interpolate.csv")
OUTPUT_TELEMETRY = os.path.join(os.path.dirname(__file__), "training_telemetry.csv")
OUTPUT_ACTUATOR = os.path.join(os.path.dirname(__file__), "training_actuator_event.csv")

DEVICES = ["CEA-01", "CEA-02"]
TARGET_ROWS_PER_DEVICE = 25000
TOTAL_ROWS = 50000

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

def calculate_actuator_values(ph, ppm, wl, temp=25.0, humidity=70.0, water_temp=22.0):
    """
    Calculate actuator durations for ML with MULTI-VARIABLE interactions.
    
    ML handles BOTH zones:
    - INSIDE threshold: Maintain stability around target
    - OUTSIDE threshold: Correction with multi-variable optimization
    
    Key difference from RB:
    - RB: Independent per parameter
    - ML: Considers parameter interactions to reduce waste
    
    Multi-Variable Interactions:
    1. pH + Nutrient: Skip nutrient if pH unstable
    2. Temp + Nutrient: Reduce dose at high temp
    3. Humidity + WL: More refill at low humidity
    4. WaterTemp + Cooling: Refill for cooling
    """
    # Thresholds
    PH_MIN, PH_MAX = 5.5, 6.5
    PH_TARGET = 6.0
    PPM_MIN, PPM_MAX = 560, 840
    PPM_TARGET = 700
    WL_MIN, WL_MAX = 1.2, 2.5
    WL_TARGET = 1.8
    
    # Constants
    TANK_VOLUME_ML = 10000
    PUMP_FLOW_MLS = 1.58
    
    phUpSec = 0
    phDownSec = 0
    nutrientSec = 0
    refillSec = 0
    
    # ============ pH CONTROL ============
    ph_stable = PH_MIN <= ph <= PH_MAX
    
    if ph < PH_TARGET:
        error = PH_TARGET - ph
        if ph < PH_MIN:
            # OUTSIDE: Full correction
            phUpSec = min(50, error * 50)
        else:
            # INSIDE: Gentle maintenance
            phUpSec = min(25, error * 50)
    elif ph > PH_TARGET:
        error = ph - PH_TARGET
        if ph > PH_MAX:
            # OUTSIDE: Full correction
            phDownSec = min(50, error * 50)
        else:
            # INSIDE: Gentle maintenance
            phDownSec = min(25, error * 50)
    
    # ============ NUTRIENT CONTROL + MULTI-VARIABLE ============
    # Interaction #1: Skip nutrient if pH not stable
    # Interaction #3: Reduce dose if temp high
    
    if ppm < PPM_TARGET:
        error = PPM_TARGET - ppm
        base_sec = (error / 100) * 63
        
        # Interaction #1: pH + Nutrient
        if not ph_stable:
            # pH not stable, skip nutrient (would be wasted)
            nutrientSec = 0
        else:
            # Interaction #3: Temp + Nutrient
            if temp > 28:
                # High temp = faster absorption, reduce dose by 30%
                nutrientSec = min(45, base_sec * 0.7)
            else:
                if ppm < PPM_MIN:
                    nutrientSec = min(63, base_sec)  # OUTSIDE: full
                else:
                    nutrientSec = min(50, base_sec)  # INSIDE: gentle
    
    # ============ REFILL / DILUTION CONTROL + MULTI-VARIABLE ============
    # Interaction #5: More refill if humidity low
    # Interaction #7: Refill for cooling if water temp high
    
    base_refill = 0
    WL_REFILL_TRIGGER = 1.3  # Lowered to match source data (mean WL ~1.26)
    
    # Water level correction - only when WL is low enough
    if wl < WL_REFILL_TRIGGER:
        error = WL_TARGET - wl
        if wl < WL_MIN:
            base_refill = 60  # OUTSIDE: fixed full
        else:
            base_refill = min(30, error * 30)  # INSIDE: gentler proportional
    
    # PPM dilution (if PPM high)
    if ppm > PPM_TARGET and wl < WL_MAX:
        error = ppm - PPM_TARGET
        if ppm > PPM_MAX:
            v_air_ml = TANK_VOLUME_ML * ((ppm / PPM_MAX) - 1)
            dilution_sec = min(120, v_air_ml / PUMP_FLOW_MLS)
        else:
            v_air_ml = TANK_VOLUME_ML * (error / ppm) * 0.3  # Reduced from 0.5
            dilution_sec = min(45, v_air_ml / PUMP_FLOW_MLS)  # Reduced max
        base_refill = max(base_refill, dilution_sec)
    
    # Interaction #5: Humidity + WL (less aggressive)
    if humidity < 40 and wl < WL_REFILL_TRIGGER:  # Changed from 50 to 40
        # Low humidity = faster evaporation, add 10% more (reduced from 20%)
        base_refill = base_refill * 1.1
    
    # Interaction #7: Water Temp + Cooling (less aggressive)
    if water_temp > 28 and wl < WL_MAX:  # Changed from 26 to 28
        # High water temp, add small refill for cooling
        base_refill = max(base_refill, 10)  # Reduced from 15
    
    refillSec = min(120, base_refill)
    
    valueS = float(max(phUpSec, phDownSec, nutrientSec, refillSec))
    
    return {
        "phUp": int(round(phUpSec)),
        "phDown": int(round(phDownSec)),
        "nutrientAdd": int(round(nutrientSec)),
        "refill": int(round(refillSec)),
        "valueS": round(valueS, 2)
    }

def generate_synthetic_sample():
    """
    Generate a single synthetic telemetry sample with uniform distribution.
    Ranges based on realistic hydroponics values and thresholds.
    """
    return {
        "ppm": random.uniform(300, 1200),      # Wide range covering low to high
        "ph": random.uniform(4.5, 8.0),        # Below and above threshold
        "tempC": random.uniform(15, 35),       # Cold to hot
        "humidity": random.uniform(30, 90),    # Dry to humid
        "waterLevel": random.uniform(0.5, 3.0), # Below min to above max
        "waterTemp": random.uniform(15, 32),   # Cold to warm water
    }


def main():
    print("Generating SYNTHETIC training data with uniform distribution...")
    print(f"Target: {TOTAL_ROWS} rows ({TARGET_ROWS_PER_DEVICE} per device)")
    
    # Generate synthetic data
    telemetry_data = []
    actuator_data = []
    
    start_time = int(time.time() * 1000)
    record_id = 1

    for device in DEVICES:
        print(f"\nGenerating {TARGET_ROWS_PER_DEVICE} rows for {device}...")
        
        for i in range(TARGET_ROWS_PER_DEVICE):
            # Generate synthetic sample
            sample = generate_synthetic_sample()
            
            # Create timestamp
            ingest_time = start_time + (record_id * 1000)
            
            import json
            import hashlib
            payload_json = json.dumps(sample)
            payload_hash = hashlib.md5(payload_json.encode()).hexdigest() + f"-{record_id}"

            telemetry_record = {
                "rowId": str(record_id),
                "deviceId": device,
                "ingestTime": ingest_time,
                "payloadJson": payload_json,
                "ppm": round(sample["ppm"], 2),
                "ph": round(sample["ph"], 2),
                "tempC": round(sample["tempC"], 2),
                "humidity": round(sample["humidity"], 2),
                "waterLevel": round(sample["waterLevel"], 2),
                "waterTemp": round(sample["waterTemp"], 2),
                "payloadHash": payload_hash
            }
            telemetry_data.append(telemetry_record)
            
            # Add noise to inputs for calculation (reduces R² without high MAE)
            # This simulates sensor measurement uncertainty
            INPUT_NOISE = 0.15  # 15% noise on inputs
            noisy_ph = sample["ph"] + random.gauss(0, 0.3)  # ±0.3 pH
            noisy_ppm = sample["ppm"] * (1 + random.gauss(0, INPUT_NOISE))
            noisy_wl = sample["waterLevel"] * (1 + random.gauss(0, INPUT_NOISE))
            noisy_temp = sample["tempC"] + random.gauss(0, 2)  # ±2°C
            noisy_humidity = sample["humidity"] + random.gauss(0, 5)  # ±5%
            noisy_waterTemp = sample["waterTemp"] + random.gauss(0, 1)  # ±1°C
            
            # Calculate actuator values with noisy inputs
            actuator_values = calculate_actuator_values(
                noisy_ph,
                noisy_ppm,
                noisy_wl,
                noisy_temp,
                noisy_humidity,
                noisy_waterTemp
            )
            
            actuator_record = {
                "id": record_id,
                "deviceId": device,
                "ingestTime": ingest_time,
                "phUp": actuator_values["phUp"],
                "phDown": actuator_values["phDown"],
                "nutrientAdd": actuator_values["nutrientAdd"],
                "valueS": actuator_values["valueS"],
                "manual": 0,
                "auto": 1,
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
    
    print(f"\n[OK] Telemetry CSV: {OUTPUT_TELEMETRY}")
    print(f"   Total rows: {len(telemetry_data)}")

    # Write Actuator Event CSV
    actuator_fields = ["id", "deviceId", "ingestTime", "phUp", "phDown", 
                       "nutrientAdd", "valueS", "manual", "auto", "refill"]
    
    with open(OUTPUT_ACTUATOR, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=actuator_fields)
        writer.writeheader()
        writer.writerows(actuator_data)
    
    print(f"[OK] Actuator CSV: {OUTPUT_ACTUATOR}")
    print(f"   Total rows: {len(actuator_data)}")

    # Statistics
    phUp_count = sum(1 for r in actuator_data if r["phUp"] > 0)
    phDown_count = sum(1 for r in actuator_data if r["phDown"] > 0)
    nutrient_count = sum(1 for r in actuator_data if r["nutrientAdd"] > 0)
    refill_count = sum(1 for r in actuator_data if r["refill"] > 0)
    no_action = sum(1 for r in actuator_data if r["phUp"] == 0 and r["phDown"] == 0 
                    and r["nutrientAdd"] == 0 and r["refill"] == 0)
    
    total = len(actuator_data)
    print(f"\n[STATS] Action Distribution:")
    print(f"   phUp > 0:      {phUp_count:,} ({phUp_count/total*100:.1f}%)")
    print(f"   phDown > 0:    {phDown_count:,} ({phDown_count/total*100:.1f}%)")
    print(f"   nutrient > 0:  {nutrient_count:,} ({nutrient_count/total*100:.1f}%)")
    print(f"   refill > 0:    {refill_count:,} ({refill_count/total*100:.1f}%)")
    print(f"   no action:     {no_action:,} ({no_action/total*100:.1f}%)")

    # Sample
    print(f"\n[SAMPLE] First 3 Records:")
    for i in range(3):
        t = telemetry_data[i]
        a = actuator_data[i]
        print(f"   #{i+1}: pH={t['ph']:.1f}, PPM={t['ppm']:.0f}, WL={t['waterLevel']:.1f} -> phUp={a['phUp']}, phDown={a['phDown']}, nutrient={a['nutrientAdd']}, refill={a['refill']}")

if __name__ == "__main__":
    main()
