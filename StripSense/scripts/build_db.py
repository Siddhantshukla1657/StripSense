#!/usr/bin/env python3
"""
StripSense — Drug Database Builder
Builds the SQLite drug database with FTS5 search index and static update manifest.
"""

import sqlite3
import json
import hashlib
import os

DRUGS_DATA = [
    {
        "id": 101,
        "brand": "Dolo 650",
        "manufacturer": "Micro Labs Ltd",
        "dosage_form": "Tablet",
        "pack_size": "15 Tablets",
        "mrp": 34.15,
        "source": "NPPA / NLEM Price List 2024",
        "license": "Open Government Data (OGD) Platform India",
        "barcode": "8901043001234",
        "is_jan_aushadhi": 0,
        "salts": [{"name": "Paracetamol", "strength": "650 mg"}],
        "safety_flag": None
    },
    {
        "id": 102,
        "brand": "Calpol 650",
        "manufacturer": "GlaxoSmithKline Pharmaceuticals Ltd",
        "dosage_form": "Tablet",
        "pack_size": "15 Tablets",
        "mrp": 33.80,
        "source": "NPPA / NLEM Price List 2024",
        "license": "Open Government Data (OGD) Platform India",
        "barcode": None,
        "is_jan_aushadhi": 0,
        "salts": [{"name": "Paracetamol", "strength": "650 mg"}],
        "safety_flag": None
    },
    {
        "id": 103,
        "brand": "Crocin 650",
        "manufacturer": "Haleon India",
        "dosage_form": "Tablet",
        "pack_size": "15 Tablets",
        "mrp": 33.50,
        "source": "NPPA / NLEM Price List 2024",
        "license": "Open Government Data (OGD) Platform India",
        "barcode": "8901043001111",
        "is_jan_aushadhi": 0,
        "salts": [{"name": "Paracetamol", "strength": "650 mg"}],
        "safety_flag": None
    },
    {
        "id": 104,
        "brand": "Jan Aushadhi Paracetamol 650",
        "manufacturer": "PMBJP",
        "dosage_form": "Tablet",
        "pack_size": "10 Tablets",
        "mrp": 9.50,
        "source": "PMBJP Product List 2024",
        "license": "Open Government Data (OGD) Platform India",
        "barcode": None,
        "is_jan_aushadhi": 1,
        "salts": [{"name": "Paracetamol", "strength": "650 mg"}],
        "safety_flag": None
    },
    {
        "id": 201,
        "brand": "Augmentin 625 Duo",
        "manufacturer": "GlaxoSmithKline Pharmaceuticals Ltd",
        "dosage_form": "Tablet",
        "pack_size": "10 Tablets",
        "mrp": 204.50,
        "source": "NPPA Price Schedule 2024",
        "license": "Open Government Data (OGD) Platform India",
        "barcode": "8901043004567",
        "is_jan_aushadhi": 0,
        "salts": [
            {"name": "Amoxycillin", "strength": "500 mg"},
            {"name": "Clavulanic Acid", "strength": "125 mg"}
        ],
        "safety_flag": None
    },
    {
        "id": 204,
        "brand": "Jan Aushadhi Amoxycillin + Clavulanate 625",
        "manufacturer": "PMBJP",
        "dosage_form": "Tablet",
        "pack_size": "10 Tablets",
        "mrp": 58.00,
        "source": "PMBJP Product List 2024",
        "license": "Open Government Data (OGD) Platform India",
        "barcode": None,
        "is_jan_aushadhi": 1,
        "salts": [
            {"name": "Amoxycillin", "strength": "500 mg"},
            {"name": "Clavulanic Acid", "strength": "125 mg"}
        ],
        "safety_flag": None
    },
    {
        "id": 2001,
        "brand": "Thyronorm 50 mcg",
        "manufacturer": "Abbott Healthcare Pvt Ltd",
        "dosage_form": "Tablet",
        "pack_size": "120 Tablets",
        "mrp": 182.00,
        "source": "NPPA Schedule",
        "license": "Open Government Data (OGD) Platform India",
        "barcode": "8901043009999",
        "is_jan_aushadhi": 0,
        "salts": [{"name": "Levothyroxine Sodium", "strength": "50 mcg"}],
        "safety_flag": "Narrow Therapeutic Index medicine: Brand substitution without doctor supervision is strongly discouraged."
    }
]

def build_database(output_path="drugs.sqlite"):
    if os.path.exists(output_path):
        os.remove(output_path)
        
    conn = sqlite3.connect(output_path)
    cur = conn.cursor()
    
    # 1. Schema
    cur.execute("""
    CREATE TABLE drugs (
        id INTEGER PRIMARY KEY,
        brand TEXT NOT NULL,
        manufacturer TEXT NOT NULL,
        dosage_form TEXT NOT NULL,
        pack_size TEXT NOT NULL,
        mrp REAL NOT NULL,
        source TEXT NOT NULL,
        license TEXT NOT NULL,
        barcode TEXT,
        is_jan_aushadhi INTEGER DEFAULT 0,
        safety_flag TEXT
    );
    """)
    
    cur.execute("""
    CREATE TABLE drug_salts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        drug_id INTEGER NOT NULL,
        salt_name TEXT NOT NULL,
        strength TEXT NOT NULL,
        FOREIGN KEY (drug_id) REFERENCES drugs (id)
    );
    """)
    
    # FTS5 virtual table for fast full-text fuzzy lookup
    cur.execute("""
    CREATE VIRTUAL TABLE drugs_fts USING fts5(
        brand,
        salts,
        manufacturer,
        content=''
    );
    """)
    
    # 2. Insert records
    for d in DRUGS_DATA:
        cur.execute("""
        INSERT INTO drugs (id, brand, manufacturer, dosage_form, pack_size, mrp, source, license, barcode, is_jan_aushadhi, safety_flag)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            d["id"], d["brand"], d["manufacturer"], d["dosage_form"],
            d["pack_size"], d["mrp"], d["source"], d["license"],
            d.get("barcode"), d.get("is_jan_aushadhi", 0), d.get("safety_flag")
        ))
        
        salts_str_list = []
        for s in d["salts"]:
            cur.execute("""
            INSERT INTO drug_salts (drug_id, salt_name, strength)
            VALUES (?, ?, ?)
            """, (d["id"], s["name"], s["strength"]))
            salts_str_list.append(f"{s['name']} {s['strength']}")
            
        cur.execute("""
        INSERT INTO drugs_fts (brand, salts, manufacturer)
        VALUES (?, ?, ?)
        """, (d["brand"], " ".join(salts_str_list), d["manufacturer"]))
        
    conn.commit()
    conn.close()
    print(f"Successfully generated SQLite database at: {output_path}")
    
    # Generate SHA-256 Checksum
    with open(output_path, "rb") as f:
        checksum = hashlib.sha256(f.read()).hexdigest()
        
    manifest = {
        "version": "v1.2.0 (2026.1)",
        "release_date": "2026-10-13",
        "checksum_sha256": checksum,
        "drug_count": len(DRUGS_DATA),
        "notes": "StripSense offline database with NPPA and PMBJP generic drug schedules"
    }
    
    manifest_path = "manifest.json"
    with open(manifest_path, "w") as f:
        json.dump(manifest, f, indent=2)
    print(f"Generated update manifest at: {manifest_path} (SHA-256: {checksum[:12]}...)")

if __name__ == "__main__":
    build_database()
