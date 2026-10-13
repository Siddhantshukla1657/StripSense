//
//  InitialDrugData.swift
//  StripSense
//

import Foundation

public struct InitialDrugData {
    public static let ntiWarning = SafetyFlag(
        reason: "Narrow Therapeutic Index medicine: Small differences in dose or blood concentration may lead to serious therapeutic failures or adverse reactions. Brand substitution without doctor supervision is strongly discouraged.",
        source: "CDSCO / WHO Essential Medicines Safety Guideline",
        requiresDoctorConsultation: true
    )
    
    public static let sampleStrips: [SampleStrip] = [
        SampleStrip(
            id: "sample_dolo_650",
            title: "Dolo 650 Strip (Paracetamol)",
            subtitle: "Micro Labs • EXP 10/2027 • B.No. DL290",
            text: """
            Dolo 650
            Paracetamol Tablets IP 650 mg
            Mfg Lic No: 25/UA/2018
            Batch No: DL290
            Mfg Date: 11/2024
            Exp Date: 10/2027
            M.R.P. Rs. 34.15 (INCL. OF ALL TAXES)
            Manufactured in India by: Micro Labs Limited
            """,
            barcode: "8901043001234"
        ),
        SampleStrip(
            id: "sample_augmentin_625",
            title: "Augmentin 625 Duo",
            subtitle: "GSK • EXP 06/2026 • B.No. AG901",
            text: """
            AUGMENTIN 625 Duo
            Amoxycillin and Potassium Clavulanate Tablets IP
            Each film coated tablet contains:
            Amoxycillin Trihydrate IP eq. to Amoxycillin 500 mg
            Potassium Clavulanate Diluted IP eq. to Clavulanic Acid 125 mg
            B.No: AG901
            EXP: 06/2026
            MRP: Rs. 204.50 per 10 tabs
            GlaxoSmithKline Pharmaceuticals Ltd
            """,
            barcode: "8901043004567"
        ),
        SampleStrip(
            id: "sample_pan_40",
            title: "Pan 40 Gastro-Resistant",
            subtitle: "Alkem • EXP 08/2027 • B.No. PN4402",
            text: """
            PAN 40
            Pantoprazole Gastro-resistant Tablets IP 40 mg
            Each enteric coated tablet contains Pantoprazole Sodium IP eq. to Pantoprazole 40 mg
            Batch No. PN4402
            MFG. 09/2024
            EXPIRY 08/2027
            M.R.P. Rs. 155.00 for 15 Tablets
            Alkem Laboratories Ltd.
            """,
            barcode: "8901043007890"
        ),
        SampleStrip(
            id: "sample_thyronorm_50",
            title: "Thyronorm 50 mcg (NTI Flagged)",
            subtitle: "Abbott • EXP 12/2026 • B.No. TN812",
            text: """
            Thyronorm 50 mcg
            Levothyroxine Sodium Tablets IP
            Each uncoated tablet contains:
            Levothyroxine Sodium IP 50 mcg
            B.No. TN812
            Mfg Date: 01/2025
            EXP: 12/2026
            M.R.P. Rs. 182.00 / 120 Tablets
            Abbott Healthcare Pvt Ltd
            """,
            barcode: "8901043009999"
        ),
        SampleStrip(
            id: "sample_glycomet_500",
            title: "Glycomet 500 SR",
            subtitle: "USV • EXP 04/2027 • B.No. GL771",
            text: """
            Glycomet 500 SR
            Metformin Hydrochloride Prolonged Release Tablets IP
            Each tablet contains: Metformin Hydrochloride IP 500 mg
            Batch: GL771
            EXP: 04/2027
            MRP: Rs. 48.00 per 20 Tablets
            USV Private Limited
            """,
            barcode: "8901043003322"
        ),
        SampleStrip(
            id: "sample_expired_crocin",
            title: "Expired Crocin 650 (Test Warning)",
            subtitle: "Haleon • EXP 01/2024 • Expired strip",
            text: """
            Crocin 650
            Fast Action Paracetamol Tablets IP 650 mg
            B.No. CR102
            MFG: 02/2022
            EXP: 01/2024
            MRP: Rs. 33.50
            Haleon India
            """,
            barcode: "8901043001111"
        )
    ]
    
    public static let allDrugs: [Drug] = [
        // --- PARACETAMOL 650 MG ---
        Drug(
            id: 101,
            brand: "Dolo 650",
            manufacturer: "Micro Labs Ltd",
            dosageForm: "Tablet",
            packSize: "15 Tablets",
            mrp: 34.15,
            source: "NPPA / NLEM Price List 2024",
            barcode: "8901043001234",
            salts: [DrugSalt(name: "Paracetamol", strength: "650 mg")]
        ),
        Drug(
            id: 102,
            brand: "Calpol 650",
            manufacturer: "GlaxoSmithKline Pharmaceuticals Ltd",
            dosageForm: "Tablet",
            packSize: "15 Tablets",
            mrp: 33.80,
            source: "NPPA / NLEM Price List 2024",
            salts: [DrugSalt(name: "Paracetamol", strength: "650 mg")]
        ),
        Drug(
            id: 103,
            brand: "Crocin 650",
            manufacturer: "Haleon India",
            dosageForm: "Tablet",
            packSize: "15 Tablets",
            mrp: 33.50,
            source: "NPPA / NLEM Price List 2024",
            barcode: "8901043001111",
            salts: [DrugSalt(name: "Paracetamol", strength: "650 mg")]
        ),
        Drug(
            id: 104,
            brand: "Jan Aushadhi Paracetamol 650",
            manufacturer: "PMBJP (Pradhan Mantri Bhartiya Janaushadhi Pariyojana)",
            dosageForm: "Tablet",
            packSize: "10 Tablets",
            mrp: 9.50,
            source: "PMBJP Product List 2024",
            salts: [DrugSalt(name: "Paracetamol", strength: "650 mg")],
            isJanAushadhi: true
        ),
        Drug(
            id: 105,
            brand: "Pacimol 650",
            manufacturer: "Ipca Laboratories Ltd",
            dosageForm: "Tablet",
            packSize: "15 Tablets",
            mrp: 31.00,
            source: "NPPA Price Schedule",
            salts: [DrugSalt(name: "Paracetamol", strength: "650 mg")]
        ),
        
        // --- AMOXICILLIN + CLAVULANIC ACID 500MG + 125MG (625MG) ---
        Drug(
            id: 201,
            brand: "Augmentin 625 Duo",
            manufacturer: "GlaxoSmithKline Pharmaceuticals Ltd",
            dosageForm: "Tablet",
            packSize: "10 Tablets",
            mrp: 204.50,
            source: "NPPA Price Schedule 2024",
            barcode: "8901043004567",
            salts: [
                DrugSalt(name: "Amoxycillin", strength: "500 mg"),
                DrugSalt(name: "Clavulanic Acid", strength: "125 mg")
            ]
        ),
        Drug(
            id: 202,
            brand: "Clavam 625",
            manufacturer: "Alkem Laboratories Ltd",
            dosageForm: "Tablet",
            packSize: "10 Tablets",
            mrp: 185.00,
            source: "NPPA Price Schedule 2024",
            salts: [
                DrugSalt(name: "Amoxycillin", strength: "500 mg"),
                DrugSalt(name: "Clavulanic Acid", strength: "125 mg")
            ]
        ),
        Drug(
            id: 203,
            brand: "Moxikind-CV 625",
            manufacturer: "Mankind Pharma Ltd",
            dosageForm: "Tablet",
            packSize: "10 Tablets",
            mrp: 172.00,
            source: "NPPA Price Schedule 2024",
            salts: [
                DrugSalt(name: "Amoxycillin", strength: "500 mg"),
                DrugSalt(name: "Clavulanic Acid", strength: "125 mg")
            ]
        ),
        Drug(
            id: 204,
            brand: "Jan Aushadhi Amoxycillin + Clavulanate 625",
            manufacturer: "PMBJP",
            dosageForm: "Tablet",
            packSize: "10 Tablets",
            mrp: 58.00,
            source: "PMBJP Product List 2024",
            salts: [
                DrugSalt(name: "Amoxycillin", strength: "500 mg"),
                DrugSalt(name: "Clavulanic Acid", strength: "125 mg")
            ],
            isJanAushadhi: true
        ),
        
        // --- PANTOPRAZOLE 40 MG ---
        Drug(
            id: 301,
            brand: "Pan 40",
            manufacturer: "Alkem Laboratories Ltd",
            dosageForm: "Tablet",
            packSize: "15 Tablets",
            mrp: 155.00,
            source: "NPPA / NLEM 2024",
            barcode: "8901043007890",
            salts: [DrugSalt(name: "Pantoprazole", strength: "40 mg")]
        ),
        Drug(
            id: 302,
            brand: "Pantocid 40",
            manufacturer: "Sun Pharma Laboratories Ltd",
            dosageForm: "Tablet",
            packSize: "15 Tablets",
            mrp: 148.50,
            source: "NPPA / NLEM 2024",
            salts: [DrugSalt(name: "Pantoprazole", strength: "40 mg")]
        ),
        Drug(
            id: 303,
            brand: "Pantodac 40",
            manufacturer: "Zydus Cadila",
            dosageForm: "Tablet",
            packSize: "15 Tablets",
            mrp: 142.00,
            source: "NPPA / NLEM 2024",
            salts: [DrugSalt(name: "Pantoprazole", strength: "40 mg")]
        ),
        Drug(
            id: 304,
            brand: "Jan Aushadhi Pantoprazole 40",
            manufacturer: "PMBJP",
            dosageForm: "Tablet",
            packSize: "10 Tablets",
            mrp: 14.00,
            source: "PMBJP Product List 2024",
            salts: [DrugSalt(name: "Pantoprazole", strength: "40 mg")],
            isJanAushadhi: true
        ),
        
        // --- METFORMIN 500 MG ---
        Drug(
            id: 401,
            brand: "Glycomet 500 SR",
            manufacturer: "USV Private Ltd",
            dosageForm: "Tablet",
            packSize: "20 Tablets",
            mrp: 48.00,
            source: "NPPA Price Schedule 2024",
            barcode: "8901043003322",
            salts: [DrugSalt(name: "Metformin Hydrochloride", strength: "500 mg")]
        ),
        Drug(
            id: 402,
            brand: "Glucophage 500",
            manufacturer: "Procter & Gamble Health Ltd",
            dosageForm: "Tablet",
            packSize: "20 Tablets",
            mrp: 52.00,
            source: "NPPA Price Schedule 2024",
            salts: [DrugSalt(name: "Metformin Hydrochloride", strength: "500 mg")]
        ),
        Drug(
            id: 403,
            brand: "Jan Aushadhi Metformin 500",
            manufacturer: "PMBJP",
            dosageForm: "Tablet",
            packSize: "10 Tablets",
            mrp: 6.80,
            source: "PMBJP Product List 2024",
            salts: [DrugSalt(name: "Metformin Hydrochloride", strength: "500 mg")],
            isJanAushadhi: true
        ),
        
        // --- AZITHROMYCIN 500 MG ---
        Drug(
            id: 501,
            brand: "Azithral 500",
            manufacturer: "Alembic Pharmaceuticals Ltd",
            dosageForm: "Tablet",
            packSize: "5 Tablets",
            mrp: 121.50,
            source: "NPPA Price Schedule 2024",
            salts: [DrugSalt(name: "Azithromycin", strength: "500 mg")]
        ),
        Drug(
            id: 502,
            brand: "Azee 500",
            manufacturer: "Cipla Ltd",
            dosageForm: "Tablet",
            packSize: "5 Tablets",
            mrp: 119.00,
            source: "NPPA Price Schedule 2024",
            salts: [DrugSalt(name: "Azithromycin", strength: "500 mg")]
        ),
        Drug(
            id: 503,
            brand: "Jan Aushadhi Azithromycin 500",
            manufacturer: "PMBJP",
            dosageForm: "Tablet",
            packSize: "3 Tablets",
            mrp: 29.00,
            source: "PMBJP Product List 2024",
            salts: [DrugSalt(name: "Azithromycin", strength: "500 mg")],
            isJanAushadhi: true
        ),
        
        // --- TELMISARTAN 40 MG ---
        Drug(
            id: 601,
            brand: "Telma 40",
            manufacturer: "Glenmark Pharmaceuticals Ltd",
            dosageForm: "Tablet",
            packSize: "15 Tablets",
            mrp: 215.00,
            source: "NPPA / NLEM 2024",
            salts: [DrugSalt(name: "Telmisartan", strength: "40 mg")]
        ),
        Drug(
            id: 602,
            brand: "Telmikind 40",
            manufacturer: "Mankind Pharma Ltd",
            dosageForm: "Tablet",
            packSize: "15 Tablets",
            mrp: 140.00,
            source: "NPPA / NLEM 2024",
            salts: [DrugSalt(name: "Telmisartan", strength: "40 mg")]
        ),
        Drug(
            id: 603,
            brand: "Jan Aushadhi Telmisartan 40",
            manufacturer: "PMBJP",
            dosageForm: "Tablet",
            packSize: "10 Tablets",
            mrp: 18.50,
            source: "PMBJP Product List 2024",
            salts: [DrugSalt(name: "Telmisartan", strength: "40 mg")],
            isJanAushadhi: true
        ),
        
        // --- ATORVASTATIN 10 MG ---
        Drug(
            id: 701,
            brand: "Atorva 10",
            manufacturer: "Zydus Cadila",
            dosageForm: "Tablet",
            packSize: "15 Tablets",
            mrp: 112.00,
            source: "NPPA Price Schedule 2024",
            salts: [DrugSalt(name: "Atorvastatin", strength: "10 mg")]
        ),
        Drug(
            id: 702,
            brand: "Storvas 10",
            manufacturer: "Sun Pharma Laboratories Ltd",
            dosageForm: "Tablet",
            packSize: "15 Tablets",
            mrp: 108.00,
            source: "NPPA Price Schedule 2024",
            salts: [DrugSalt(name: "Atorvastatin", strength: "10 mg")]
        ),
        Drug(
            id: 703,
            brand: "Jan Aushadhi Atorvastatin 10",
            manufacturer: "PMBJP",
            dosageForm: "Tablet",
            packSize: "10 Tablets",
            mrp: 11.20,
            source: "PMBJP Product List 2024",
            salts: [DrugSalt(name: "Atorvastatin", strength: "10 mg")],
            isJanAushadhi: true
        ),
        
        // --- MONTELUKAST 10MG + LEVOCETIRIZINE 5MG ---
        Drug(
            id: 801,
            brand: "Montair-LC",
            manufacturer: "Cipla Ltd",
            dosageForm: "Tablet",
            packSize: "15 Tablets",
            mrp: 302.00,
            source: "NPPA Price Schedule 2024",
            salts: [
                DrugSalt(name: "Montelukast", strength: "10 mg"),
                DrugSalt(name: "Levocetirizine", strength: "5 mg")
            ]
        ),
        Drug(
            id: 802,
            brand: "Montek-LC",
            manufacturer: "Sun Pharma Laboratories Ltd",
            dosageForm: "Tablet",
            packSize: "15 Tablets",
            mrp: 298.00,
            source: "NPPA Price Schedule 2024",
            salts: [
                DrugSalt(name: "Montelukast", strength: "10 mg"),
                DrugSalt(name: "Levocetirizine", strength: "5 mg")
            ]
        ),
        Drug(
            id: 803,
            brand: "Jan Aushadhi Montelukast + Levocetirizine",
            manufacturer: "PMBJP",
            dosageForm: "Tablet",
            packSize: "10 Tablets",
            mrp: 28.00,
            source: "PMBJP Product List 2024",
            salts: [
                DrugSalt(name: "Montelukast", strength: "10 mg"),
                DrugSalt(name: "Levocetirizine", strength: "5 mg")
            ],
            isJanAushadhi: true
        ),
        
        // --- CETIRIZINE 10 MG ---
        Drug(
            id: 901,
            brand: "Cetzine 10",
            manufacturer: "Dr. Reddy's Laboratories",
            dosageForm: "Tablet",
            packSize: "15 Tablets",
            mrp: 24.50,
            source: "NPPA / NLEM 2024",
            salts: [DrugSalt(name: "Cetirizine", strength: "10 mg")]
        ),
        Drug(
            id: 902,
            brand: "Okacet 10",
            manufacturer: "Cipla Ltd",
            dosageForm: "Tablet",
            packSize: "10 Tablets",
            mrp: 18.00,
            source: "NPPA / NLEM 2024",
            salts: [DrugSalt(name: "Cetirizine", strength: "10 mg")]
        ),
        Drug(
            id: 903,
            brand: "Jan Aushadhi Cetirizine 10",
            manufacturer: "PMBJP",
            dosageForm: "Tablet",
            packSize: "10 Tablets",
            mrp: 4.50,
            source: "PMBJP Product List 2024",
            salts: [DrugSalt(name: "Cetirizine", strength: "10 mg")],
            isJanAushadhi: true
        ),
        
        // --- AMLODIPINE 5 MG ---
        Drug(
            id: 1001,
            brand: "Stamlo 5",
            manufacturer: "Dr. Reddy's Laboratories",
            dosageForm: "Tablet",
            packSize: "15 Tablets",
            mrp: 85.00,
            source: "NPPA / NLEM 2024",
            salts: [DrugSalt(name: "Amlodipine", strength: "5 mg")]
        ),
        Drug(
            id: 1002,
            brand: "Amlopres 5",
            manufacturer: "Cipla Ltd",
            dosageForm: "Tablet",
            packSize: "15 Tablets",
            mrp: 78.00,
            source: "NPPA / NLEM 2024",
            salts: [DrugSalt(name: "Amlodipine", strength: "5 mg")]
        ),
        Drug(
            id: 1003,
            brand: "Jan Aushadhi Amlodipine 5",
            manufacturer: "PMBJP",
            dosageForm: "Tablet",
            packSize: "10 Tablets",
            mrp: 5.60,
            source: "PMBJP Product List 2024",
            salts: [DrugSalt(name: "Amlodipine", strength: "5 mg")],
            isJanAushadhi: true
        ),
        
        // ==========================================
        // --- NARROW THERAPEUTIC INDEX (NTI) DRUGS ---
        // Brand switching without doctor oversight is prohibited
        // ==========================================
        Drug(
            id: 2001,
            brand: "Thyronorm 50 mcg",
            manufacturer: "Abbott Healthcare Pvt Ltd",
            dosageForm: "Tablet",
            packSize: "120 Tablets",
            mrp: 182.00,
            source: "NPPA Schedule",
            barcode: "8901043009999",
            salts: [DrugSalt(name: "Levothyroxine Sodium", strength: "50 mcg")],
            safetyFlag: ntiWarning
        ),
        Drug(
            id: 2002,
            brand: "Eltroxin 50 mcg",
            manufacturer: "GlaxoSmithKline Pharmaceuticals Ltd",
            dosageForm: "Tablet",
            packSize: "120 Tablets",
            mrp: 175.00,
            source: "NPPA Schedule",
            salts: [DrugSalt(name: "Levothyroxine Sodium", strength: "50 mcg")],
            safetyFlag: ntiWarning
        ),
        Drug(
            id: 2003,
            brand: "Warf 5",
            manufacturer: "Cipla Ltd",
            dosageForm: "Tablet",
            packSize: "10 Tablets",
            mrp: 67.50,
            source: "NPPA Schedule",
            salts: [DrugSalt(name: "Warfarin Sodium", strength: "5 mg")],
            safetyFlag: ntiWarning
        ),
        Drug(
            id: 2004,
            brand: "Lanoxin 0.25",
            manufacturer: "GlaxoSmithKline Pharmaceuticals Ltd",
            dosageForm: "Tablet",
            packSize: "10 Tablets",
            mrp: 19.80,
            source: "NPPA Schedule",
            salts: [DrugSalt(name: "Digoxin", strength: "0.25 mg")],
            safetyFlag: ntiWarning
        ),
        Drug(
            id: 2005,
            brand: "Tegretol 200",
            manufacturer: "Novartis India Ltd",
            dosageForm: "Tablet",
            packSize: "10 Tablets",
            mrp: 29.50,
            source: "NPPA Schedule",
            salts: [DrugSalt(name: "Carbamazepine", strength: "200 mg")],
            safetyFlag: ntiWarning
        ),
        Drug(
            id: 2006,
            brand: "Dilantin 100",
            manufacturer: "Pfizer Ltd",
            dosageForm: "Capsule",
            packSize: "100 Capsules",
            mrp: 240.00,
            source: "NPPA Schedule",
            salts: [DrugSalt(name: "Phenytoin Sodium", strength: "100 mg")],
            safetyFlag: ntiWarning
        ),
        Drug(
            id: 2007,
            brand: "Lithosun 300",
            manufacturer: "Sun Pharma Laboratories Ltd",
            dosageForm: "Tablet",
            packSize: "10 Tablets",
            mrp: 42.00,
            source: "NPPA Schedule",
            salts: [DrugSalt(name: "Lithium Carbonate", strength: "300 mg")],
            safetyFlag: ntiWarning
        )
    ]
}
