# StripSense — Todo

> **Last updated:** 2026-10-10. Check items off as they're completed; keep this file in sync with actual progress.

## Phase 1: Data and OCR Prototype
- [ ] Confirm the toolchain is free and ready (Mac, Xcode, iPhone, free Apple ID provisioning)
- [ ] Photograph about 100 strips and boxes
  - [ ] Vary lighting, angles and glare
  - [ ] Include strips with and without expiry, and with barcodes or QR codes
- [ ] Label each photo with brand, salt, strength, expiry and batch
- [ ] Run Vision text and barcode recognition on the photos and record the outputs
- [ ] Find free public data sources
  - [ ] Check price lists and the Jan Aushadhi product list
  - [ ] Review each source's license and note what can be bundled
- [ ] Write the database builder and produce `drugs.sqlite` with an FTS5 index
- [ ] Prototype rules-based field parsing (strength, expiry, batch)
- [ ] Prototype fuzzy matching and measure top-1 and top-3 accuracy
- [ ] Write the evaluation report and decide go or no-go (target 80% top-3 and 80% expiry)

## Phase 2: Scan and Find MVP
- [ ] Create the SwiftUI project (iOS 17+) with tests
- [ ] Bundle the database and implement the Drug Database layer
- [ ] Build the Scan screen with VisionKit live scanning and a photo fallback
  - [ ] Multi-frame voting
  - [ ] Glare and distance tips
- [ ] Add barcode and QR reading with exact lookup
- [ ] Implement field extraction with confidence scores
- [ ] Implement matching and the Confirm Candidates screen
- [ ] Build manual search
- [ ] Build the Drug Detail screen with source, disclaimer and expired warning
- [ ] Implement the pharmacy search with MapKit and the map and list screen
  - [ ] Location permission flow and typed-area fallback
- [ ] Add Call and Message actions with a prefilled message
- [ ] Add empty, loading and error states throughout
- [ ] Build the About screen with data sources and licenses
- [ ] Test on a physical iPhone, including offline behavior

## Phase 3: Alternatives and My Medicines
- [ ] Build the alternatives engine (identical salt, strength and form only)
  - [ ] Unit tests proving no cross-salt or cross-strength matches
- [ ] Compile and review the safety flag list with sources
- [ ] Build the Alternatives screen with price savings and disclaimers
- [ ] Build the My Medicines shelf with SwiftData
  - [ ] Add, edit, remove and sort by expiry
  - [ ] Duplicate handling
- [ ] Implement expiry reminders with local notifications
  - [ ] Permission flow and in-app fallback
- [ ] Evaluate a free Jan Aushadhi store dataset and add the map layer, or record the decision to defer
- [ ] Run a tester session with at least 10 people and collect feedback

## Phase 4: Accessibility, ML and Data Updates
- [ ] Label at least 300 strips for tagger training and testing
- [ ] Train the Create ML word tagger and export it to Core ML
  - [ ] Compare rules-only with rules plus ML on held-out data
  - [ ] Version the model and document the steps
- [ ] Integrate the tagger with a rules fallback
- [ ] Add read-aloud and large-text mode
- [ ] Complete an accessibility pass (VoiceOver, Dynamic Type, contrast)
- [ ] Build the data update flow
  - [ ] Publish a manifest and database file on GitHub Pages or Releases
  - [ ] Checksum verification, atomic swap and rollback
- [ ] Optionally add regional-language names for common medicines
- [ ] Write the final evaluation report
- [ ] Prepare the release path (own-device install and open-source repository; decide on the paid program separately)

## Backlog / Unscheduled
- [ ] Crowd-reported availability (needs a backend)
- [ ] Partner pharmacy stock feeds
- [ ] Prescription scanning
- [ ] Drug interaction checks
- [ ] Android version
- [ ] Family sharing of shelves
- [ ] Competitor scan for medicine scanning apps
