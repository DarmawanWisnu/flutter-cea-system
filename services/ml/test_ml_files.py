"""
Test script to verify ML files work with synthetic CSV data.
Run this to test the updated dataset_loader and trainer.
"""

import os
import sys

# Add parent directory to path
sys.path.append(os.path.dirname(__file__))

from dataset_loader import load_from_csv
from preprocessing import prepare_xy
from trainer import train_from_csv

def test_dataset_loader():
    """Test loading and merging CSV files."""
    print("=" * 60)
    print("TEST 1: Dataset Loader")
    print("=" * 60)
    
    telemetry_csv = "synthetic_telemetry.csv"
    actuator_csv = "synthetic_actuator_event.csv"
    
    if not os.path.exists(telemetry_csv):
        print(f"❌ {telemetry_csv} not found!")
        return False
    
    if not os.path.exists(actuator_csv):
        print(f"❌ {actuator_csv} not found!")
        return False
    
    try:
        df = load_from_csv(telemetry_csv, actuator_csv)
        print(f"\n✅ Successfully loaded and merged data")
        print(f"   Shape: {df.shape}")
        print(f"   Columns: {list(df.columns)[:10]}...")
        
        # Check for required columns
        required = ["ppm", "ph", "tempC", "humidity", "waterTemp", "waterLevel",
                   "phUp", "phDown", "nutrientAdd", "refill"]
        missing = [col for col in required if col not in df.columns]
        
        if missing:
            print(f"❌ Missing columns: {missing}")
            return False
        
        print(f"✅ All required columns present")
        return True
        
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_preprocessing():
    """Test data preprocessing."""
    print("\n" + "=" * 60)
    print("TEST 2: Preprocessing")
    print("=" * 60)
    
    try:
        df = load_from_csv("synthetic_telemetry.csv", "synthetic_actuator_event.csv")
        X, y = prepare_xy(df)
        
        print(f"\n✅ Successfully prepared X and y")
        print(f"   X shape: {X.shape}")
        print(f"   y shape: {y.shape}")
        print(f"   Features: {list(X.columns)}")
        print(f"   Targets: {list(y.columns)}")
        
        return True
        
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_training():
    """Test model training."""
    print("\n" + "=" * 60)
    print("TEST 3: Training (Quick Test with 10 trees)")
    print("=" * 60)
    
    try:
        version_dir, metadata = train_from_csv(
            "synthetic_telemetry.csv",
            "synthetic_actuator_event.csv",
            n_estimators=10,  # Quick test
            max_depth=10
        )
        
        print(f"\n✅ Training completed successfully!")
        print(f"   Model saved to: {version_dir}")
        print(f"\n📊 Metrics:")
        for target, metrics in metadata['metrics'].items():
            print(f"   {target}: Test R² = {metrics['test_r2']:.3f}, MAE = {metrics['test_mae']:.3f}")
        
        return True
        
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return False


if __name__ == "__main__":
    print("\n🧪 Testing Updated ML Files\n")
    
    results = []
    
    # Test 1: Dataset Loader
    results.append(("Dataset Loader", test_dataset_loader()))
    
    # Test 2: Preprocessing
    results.append(("Preprocessing", test_preprocessing()))
    
    # Test 3: Training (optional, comment out if you want to skip)
    print("\n⚠️  Training test will take a few minutes...")
    user_input = input("Run training test? (y/n): ").strip().lower()
    if user_input == 'y':
        results.append(("Training", test_training()))
    
    # Summary
    print("\n" + "=" * 60)
    print("TEST SUMMARY")
    print("=" * 60)
    
    for name, passed in results:
        status = "✅ PASS" if passed else "❌ FAIL"
        print(f"{status} - {name}")
    
    all_passed = all(result[1] for result in results)
    
    if all_passed:
        print("\n🎉 All tests passed! ML files are working correctly.")
    else:
        print("\n⚠️  Some tests failed. Check the output above.")
