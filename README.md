# StripSense 💊

> **Identify any medicine strip. Compare generics. Never miss an expiry.**

StripSense is a fully **on-device iOS app** (India-first) that scans a medicine strip or box with the camera, identifies the drug by salt and strength, shows cheaper same-salt alternatives, finds nearby pharmacies you can call in one tap, and keeps a private shelf of medicines you own — with expiry reminders.

It runs **completely offline** (except the map), requires **no account**, collects **no analytics**, and costs **nothing** to build or run.

---

## Screenshots / Demo

Use the **"Demo & Simulator Samples"** cards on the Home screen to simulate scanning any of the 6 pre-labelled strips instantly — no physical camera required.

---

## Features

| Phase | Features |
|---|---|
| ✅ Phase 1 | Drug database builder (`build_db.py`), OCR evaluation script (`evaluate_ocr.py`) |
| ✅ Phase 2 | VisionKit live scanner, barcode/QR exact matching, field extraction, top-3 candidate confirmation, manual search, drug detail, MapKit pharmacy map with call & message |
| ✅ Phase 3 | Same-salt generic alternatives (strict match), NTI safety guardrails, My Medicines shelf, expiry reminders (local notifications), Jan Aushadhi store layer |
| ✅ Phase 4 | AVSpeechSynthesizer read-aloud, large text / Dynamic Type, offline data updates (SHA-256 verified, atomic swap, rollback) |

---

## Architecture

```
StripSense/
├── Models/                  # Drug, ShelfItem, Pharmacy, ScanModels, AppSettings
├── Services/                # DrugDatabase, FieldExtractor, Matching, Alternatives,
│                            #   Shelf, Notification, Pharmacy, Speech, DataUpdate
├── Utilities/               # StringSimilarity, ExpiryDateParser, Formatters
├── Resources/               # InitialDrugData.swift (bundled NPPA/PMBJP database)
│                            #   JanAushadhiData.swift (sample Jan Aushadhi stores)
├── Views/
│   ├── Home/                # HomeView, SearchBarView
│   ├── Scan/                # ScanView, CameraScannerRepresentable, ConfirmCandidatesView
│   ├── Detail/              # DrugDetailView
│   ├── Alternatives/        # AlternativesView
│   ├── Pharmacies/          # PharmaciesView, PharmacyRowView
│   ├── Shelf/               # ShelfView, ShelfItemRowView, AddEditShelfItemView
│   ├── Settings/            # SettingsView
│   └── Components/          # StatusBadgeView, DisclaimerBanner, StatCard
└── scripts/
    ├── build_db.py          # SQLite + FTS5 database builder with SHA-256 manifest
    └── evaluate_ocr.py      # Phase 1 OCR field accuracy evaluation
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | SwiftUI (iOS 17+ / iOS 26) |
| Scanning | VisionKit DataScannerViewController + Vision barcode |
| Field Parsing | Rules + regex (brand, salt, strength, expiry, batch) |
| Database | Bundled Swift data model (SQLite builder in `scripts/`) |
| Shelf | UserDefaults + Codable (SwiftData-ready) |
| Maps | MapKit native local search — no API key |
| Notifications | UserNotifications (local, no server) |
| Speech | AVSpeechSynthesizer (en-IN locale) |
| Updates | Static manifest + SHA-256 checksum verification |

---

## Running on Device / Simulator

1. Open **`StripSense.xcodeproj`** in Xcode 16+
2. Select your iPhone target (or Simulator)
3. Hit **Run (⌘R)**
4. On Simulator: use the **"Demo & Simulator Samples"** strip cards on the Home screen — they immediately simulate the full OCR → Match → Detail flow without needing a camera

> **Camera scanning** requires a physical iPhone. The simulator shows an explanatory fallback screen with the same sample strip runner.

---

## Rebuilding the Drug Database

```bash
cd StripSense/scripts
python build_db.py
# Outputs: drugs.sqlite + manifest.json (SHA-256 checksummed)
```

## Running OCR Evaluation

```bash
cd StripSense/scripts
python evaluate_ocr.py
# Outputs field-level accuracy report for all test strips
```

---

## Privacy

- All scans processed **on device** — images never leave the phone
- Shelf data stored in **UserDefaults** (private, not backed up to iCloud by default)
- **No accounts**, no analytics on medicine data, no server backend
- Location used only for MapKit pharmacy search; not stored

---

## Data Sources

| Source | Usage | License |
|---|---|---|
| NPPA / NLEM 2024 Price Schedule | Drug prices, ceiling prices | Open Government Data (OGD) India |
| PMBJP Jan Aushadhi Product List | Generic store products & prices | Open Government Data (OGD) India |

---

## Medical Disclaimer

StripSense is an **informational tool only**. It does not provide medical advice, dosing guidance, or drug interaction checking. Always verify identified medicines and any brand substitution with your doctor or licensed pharmacist.

---

## Distribution

- **Free path:** Install directly from Xcode to your iPhone using a free Apple ID (re-sign every 7 days)
- **Paid path:** Apple Developer Program (USD 99/year) for TestFlight and App Store distribution

---

## License

Source: MIT. Drug data: Open Government Data (OGD) Platform India (see individual data source attributions in the app's Settings screen).
