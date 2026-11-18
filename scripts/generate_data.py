"""Generate fictional supplier data, with realistic data-quality issues on purpose.

Issues injected (handled in staging):
- mixed date formats (YYYY-MM-DD and DD/MM/YYYY)
- duplicated delivery rows
- supplier names with extra spaces / different casing
- a few deliveries with null quantity
"""
import csv, random
from datetime import date, timedelta
from pathlib import Path

random.seed(42)
OUT = Path(__file__).resolve().parent.parent / "seeds"
OUT.mkdir(exist_ok=True)

CATEGORIES = ["resins", "pigments", "packaging", "metal_parts", "molds_services"]
REGIONS = ["south", "southeast", "international"]
START = date(2025, 1, 1)
ONBOARDING_START = date(2025, 7, 1)  # new onboarding program starts here

def fmt(d):
    return d.strftime("%d/%m/%Y") if random.random() < 0.15 else d.isoformat()

suppliers = []
for i in range(1, 41):
    onboarded = START + timedelta(days=random.randint(0, 540))
    name = f"Supplier {i:03d}"
    if random.random() < 0.1:
        name = "  " + name.lower() + " "
    suppliers.append({
        "supplier_id": f"S{i:03d}",
        "supplier_name": name,
        "category": random.choice(CATEGORIES),
        "region": random.choice(REGIONS),
        "onboarded_at": fmt(onboarded),
        "onboarding_program": "new" if onboarded >= ONBOARDING_START and random.random() < 0.5 else "legacy",
        "status": random.choice(["active"] * 8 + ["under_review", "inactive"]),
    })

orders, deliveries, inspections = [], [], []
po_n = 0
for s in suppliers:
    reliability = random.uniform(0.70, 0.98) + (0.04 if s["onboarding_program"] == "new" else 0)
    for _ in range(random.randint(15, 45)):
        po_n += 1
        po_id = f"PO{po_n:05d}"
        ordered = START + timedelta(days=random.randint(0, 600))
        promised = ordered + timedelta(days=random.randint(7, 45))
        qty = random.choice([100, 250, 500, 1000, 2000, 5000])
        orders.append({"po_id": po_id, "supplier_id": s["supplier_id"], "ordered_at": fmt(ordered),
                       "promised_date": fmt(promised), "quantity_ordered": qty,
                       "unit_price": round(random.uniform(0.5, 80), 2)})
        on_time = random.random() < reliability
        delivered = promised - timedelta(days=random.randint(0, 3)) if on_time else promised + timedelta(days=random.randint(1, 20))
        full = random.random() < min(reliability + 0.05, 0.99)
        dq = qty if full else int(qty * random.uniform(0.6, 0.98))
        row = {"delivery_id": f"D{po_n:05d}", "po_id": po_id, "delivered_at": fmt(delivered),
               "quantity_delivered": "" if random.random() < 0.01 else dq}
        deliveries.append(row)
        if random.random() < 0.03:
            deliveries.append(dict(row))  # duplicate on purpose
        rejected = int(dq * random.uniform(0, 0.03)) if random.random() < 0.2 else 0
        inspections.append({"inspection_id": f"I{po_n:05d}", "delivery_id": row["delivery_id"],
                            "quantity_rejected": rejected, "inspected_at": fmt(delivered + timedelta(days=1))})

def write(name, rows):
    with open(OUT / f"{name}.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        w.writeheader(); w.writerows(rows)
    print(f"{name}: {len(rows)} rows")

write("raw_suppliers", suppliers)
write("raw_purchase_orders", orders)
write("raw_deliveries", deliveries)
write("raw_inspections", inspections)
