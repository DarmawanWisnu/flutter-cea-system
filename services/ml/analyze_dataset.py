import csv

# Read the actuator event data
with open('services/ml/training_actuator_event.csv', 'r') as f:
    data = list(csv.DictReader(f))

total = len(data)
actions = sum(1 for r in data if int(r['phUp']) > 0 or int(r['phDown']) > 0 
              or int(r['nutrientAdd']) > 0 or int(r['refill']) > 0)

print(f"📊 Dataset Violation Analysis")
print(f"=" * 50)
print(f"\nTotal Events: {total:,}")
print(f"Action Events: {actions:,} ({actions/total*100:.1f}%)")
print(f"No Action: {total-actions:,} ({(total-actions)/total*100:.1f}%)")

print(f"\n🔧 Actuator Breakdown:")
print(f"  phUp activated:      {sum(1 for r in data if int(r['phUp']) > 0):,} events")
print(f"  phDown activated:    {sum(1 for r in data if int(r['phDown']) > 0):,} events")
print(f"  nutrientAdd activated: {sum(1 for r in data if int(r['nutrientAdd']) > 0):,} events")
print(f"  refill activated:    {sum(1 for r in data if int(r['refill']) > 0):,} events")

# Check multiple actions
multiple = sum(1 for r in data if 
               (1 if int(r['phUp']) > 0 else 0) + 
               (1 if int(r['phDown']) > 0 else 0) + 
               (1 if int(r['nutrientAdd']) > 0 else 0) + 
               (1 if int(r['refill']) > 0 else 0) > 1)

print(f"\n🎯 Multi-Action Events: {multiple:,} ({multiple/total*100:.1f}%)")

# Sample events
print(f"\n📝 Sample Action Events:")
action_samples = [r for r in data if int(r['phUp']) > 0 or int(r['phDown']) > 0 
                  or int(r['nutrientAdd']) > 0 or int(r['refill']) > 0][:3]
for i, r in enumerate(action_samples, 1):
    print(f"\n  #{i}: Device={r['deviceId']}, phUp={r['phUp']}, phDown={r['phDown']}, "
          f"nutrient={r['nutrientAdd']}, refill={r['refill']}")
