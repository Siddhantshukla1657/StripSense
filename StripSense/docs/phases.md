# StripSense — Phases

> **Status:** Draft | **Last updated:** 2026-10-10

## Roadmap Summary
| Phase | Name | Goal | Target duration |
|---|---|---|---|
| Phase 1 | Data and OCR Prototype | Prove that on-device OCR plus a bundled drug database can identify common medicine strips | ~1 week |
| Phase 2 | Scan and Find MVP | A working iOS app that scans a strip, confirms the medicine, and shows nearby pharmacies | ~2 weeks |
| Phase 3 | Alternatives and My Medicines | Safe same-salt alternatives and a personal medicine shelf with expiry reminders | ~2 weeks |
| Phase 4 | Accessibility, ML and Data Updates | Better field extraction, elderly-friendly features, and free offline data updates | ~2 weeks |

*Durations assume part-time work (roughly 10-15 hrs/week). Everything in every phase must run on device at zero cost, with no custom backend.*

---

## Phase 1: Data and OCR Prototype
**Goal:** Prove that on-device OCR plus a bundled drug database can identify common medicine strips accurately enough to build an app on.

**Scope:**
- Photograph about 100 medicine strips and boxes (strips carry no personal data) under varied lighting and angles
- Run Apple Vision text recognition and barcode detection on the photos
- Build the first drug database: the few hundred most common medicines (brand, salt, strength, dosage form, pack size, price), from free public sources whose licenses allow use
- Prototype parsing (regex and rules) and fuzzy matching against the database
- Measure field accuracy and top-3 match accuracy

**Out of scope for this phase:**
- Any production app UI
- Pharmacy map
- ML models
- Generic alternatives

**Deliverables:**
- Labeled photo set (about 100 samples) with ground truth
- Drug database v0 (SQLite) with a documented source and license for every column
- Evaluation notebook or script and a short report
- Decision on which data sources are usable

**Dependencies:** A Mac with Xcode (free) and an iPhone; access to strips; time to review data licenses.

**Exit criteria:** Top-3 match accuracy of at least 80% on the photo set, expiry parsed correctly on at least 80% of strips that show one, and every database source confirmed as legally usable.

---

## Phase 2: Scan and Find MVP
**Goal:** A person can scan a medicine strip, confirm what it is, and see nearby pharmacies they can call.

**Scope:**
- SwiftUI app (iOS 17+) with live scanning (VisionKit) and photo fallback
- Barcode/QR reading when present
- Field extraction, fuzzy matching, and a candidate confirmation screen
- Manual search by name as a fallback
- Drug detail screen
- Nearby pharmacies on a map (MapKit point-of-interest search) with call and message actions

**Out of scope for this phase:**
- Generic alternatives
- My Medicines shelf and reminders
- ML tagger
- Data updates

**Deliverables:**
- App installable on the developer's own iPhone
- Bundled drug database v1
- Scan, confirm, detail and pharmacy flows with empty, loading and error states
- Disclaimer and data-source screen

**Dependencies:** Phase 1 database, parser and evaluation results.

**Exit criteria:** A tester can go from scanning to a pharmacy call in under 60 seconds; the app never shows a match as certain without user confirmation; the app works fully offline except for the map.

---

## Phase 3: Alternatives and My Medicines
**Goal:** Show cheaper same-salt options safely, and let families track the medicines they own and when they expire.

**Scope:**
- Generic alternatives: same salt, same strength, same dosage form, with price per pack and a pharmacist disclaimer
- "Do not switch without asking your doctor" flag for narrow-therapeutic-index and similar drugs
- My Medicines shelf stored on device (SwiftData)
- Expiry reminders using local notifications
- Jan Aushadhi store layer on the map, if a usable free dataset exists

**Out of scope for this phase:**
- Dosing advice
- Interaction checking
- Cloud sync
- Crowd availability reports

**Deliverables:**
- Alternatives engine with tests
- Safety flag list with sources
- Shelf screens and notification scheduling
- Jan Aushadhi layer, or a documented decision to defer it

**Dependencies:** Phase 2 app; salt and price data from Phase 1; reviewed safety flag list.

**Exit criteria:** Alternatives only ever match on identical salt, strength and form (verified by tests); expiry reminders fire correctly in testing; shelf data never leaves the device.

---

## Phase 4: Accessibility, ML and Data Updates
**Goal:** Make scanning more accurate and usable for elderly people, and keep the drug data fresh without paying for a server.

**Scope:**
- Create ML word tagger to label brand, salt, strength, expiry and batch tokens
- Large text, high contrast and read-aloud (AVSpeechSynthesizer)
- Optional regional-language labels for common medicine names
- Free data updates: a versioned manifest and SQLite files on static hosting (GitHub Pages or Releases), verified by checksum
- Final evaluation and a documented release path

**Out of scope for this phase:**
- Accounts
- Crowd-sourced availability
- Any paid service

**Deliverables:**
- Trained, versioned Core ML tagger and its training notes
- Accessibility pass (Dynamic Type, VoiceOver, contrast)
- Data update mechanism with integrity checks
- Final evaluation report (rules-only vs rules + ML)

**Dependencies:** Phases 2-3; enough labeled strips to train and test (target at least 300).

**Exit criteria:** Field accuracy improves by at least 5 points over rules-only; the app passes a VoiceOver walkthrough of the main flows; a data update installs, verifies and rolls back correctly.

---

## Future / Not Yet Scheduled
- Crowd-reported availability (needs shared storage, so a backend)
- Partner pharmacy stock feeds
- Prescription scanning
- Drug interaction checks (needs reliable licensed data and clinical review)
- Android version
- Family sharing of shelves
