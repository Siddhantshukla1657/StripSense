# StripSense — Feature List

> **Status:** Draft | **Last updated:** 2026-10-10

## Feature Summary
| # | Feature | Category | Phase | Priority | Status |
|---|---|---|---|---|---|
| 1 | Strip photo set and OCR evaluation | Data | Phase 1: Data and OCR Prototype | Must-have | Planned |
| 2 | Drug database builder | Data | Phase 1: Data and OCR Prototype | Must-have | Planned |
| 3 | Scan capture | Scanning | Phase 2: Scan and Find MVP | Must-have | Planned |
| 4 | Barcode and QR reading | Scanning | Phase 2: Scan and Find MVP | Should-have | Planned |
| 5 | Field extraction | Scanning | Phase 2: Scan and Find MVP | Must-have | Planned |
| 6 | Drug matching with confirmation | Matching | Phase 2: Scan and Find MVP | Must-have | Planned |
| 7 | Manual search | Matching | Phase 2: Scan and Find MVP | Must-have | Planned |
| 8 | Drug detail screen | Information | Phase 2: Scan and Find MVP | Must-have | Planned |
| 9 | Nearby pharmacies map | Map | Phase 2: Scan and Find MVP | Must-have | Planned |
| 10 | Call or message pharmacy | Map | Phase 2: Scan and Find MVP | Should-have | Planned |
| 11 | Generic alternatives with safeguards | Information | Phase 3: Alternatives and My Medicines | Must-have | Planned |
| 12 | My Medicines shelf | Shelf | Phase 3: Alternatives and My Medicines | Must-have | Planned |
| 13 | Expiry reminders | Shelf | Phase 3: Alternatives and My Medicines | Should-have | Planned |
| 14 | Jan Aushadhi store layer | Map | Phase 3: Alternatives and My Medicines | Nice-to-have | Planned |
| 15 | ML field tagger | ML | Phase 4: Accessibility, ML and Data Updates | Should-have | Planned |
| 16 | Read-aloud and large text | Accessibility | Phase 4: Accessibility, ML and Data Updates | Must-have | Planned |
| 17 | Offline data updates via static hosting | Data | Phase 4: Accessibility, ML and Data Updates | Should-have | Planned |

*Priority: Must-have / Should-have / Nice-to-have. Status: Planned / In progress / Done.*

---

## 1. Strip photo set and OCR evaluation
**Category:** Data
**Phase:** Phase 1: Data and OCR Prototype
**Priority:** Must-have

**What it does:**
A labeled collection of strip and box photos with a script that measures how well Apple Vision reads them.

**User story:**
As the developer, I want measured OCR accuracy, so that I know the approach works before building the app.

**How it works:**
1. Trigger: photograph about 100 strips and boxes under varied lighting and angles.
2. Logic: label each with brand, salt, strength, expiry and batch; run Vision text and barcode recognition; compare the output with labels.
3. Result: per-field accuracy numbers and a list of failure patterns (glare, curvature, tiny print).

**Inputs:** Photos, labels.

**Outputs:** CSV of results, evaluation report.

**Edge cases & error handling:**
- Edge case: strip with no expiry printed → behavior: excluded from the expiry metric.
- Edge case: blurry photo → behavior: kept as a hard case and reported separately.

**Dependencies:** Xcode and an iPhone; access to strips.

---

## 2. Drug database builder
**Category:** Data
**Phase:** Phase 1: Data and OCR Prototype
**Priority:** Must-have

**What it does:**
A script that builds the bundled SQLite drug database from free public sources.

**User story:**
As the developer, I want a reproducible database, so that I can improve and refresh it.

**How it works:**
1. Trigger: run the build script.
2. Logic: load source files (price lists, product lists); normalize brand, salt, strength, dosage form and pack size; merge duplicates; attach source and license per row; create an FTS5 index.
3. Result: `drugs.sqlite` plus a source and license report.

**Inputs:** Source files.

**Outputs:** SQLite database, source report.

**Edge cases & error handling:**
- Edge case: conflicting prices across sources → behavior: keep both with sources; show the lower-confidence note.
- Edge case: source license disallows redistribution → behavior: exclude that source.

**Dependencies:** Public datasets.

---

## 3. Scan capture
**Category:** Scanning
**Phase:** Phase 2: Scan and Find MVP
**Priority:** Must-have

**What it does:**
Captures text from a strip using the live camera, with a photo fallback.

**User story:**
As an elderly patient, I want to point my phone at a strip, so that I don't have to read the print.

**How it works:**
1. Trigger: user taps Scan.
2. Logic: use VisionKit data scanning for live text; collect several frames and keep the most consistent recognized strings (voting); show glare and distance tips if confidence stays low.
3. Result: raw recognized text passed to field extraction.

**Inputs:** Camera frames or a photo.

**Outputs:** Recognized text with confidence.

**Edge cases & error handling:**
- Error case: camera permission denied → behavior: offer photo import and manual search.
- Edge case: device without data scanner support → behavior: use photo capture with Vision.

**Dependencies:** Camera permission.

---

## 4. Barcode and QR reading
**Category:** Scanning
**Phase:** Phase 2: Scan and Find MVP
**Priority:** Should-have

**What it does:**
Reads barcodes or QR codes on packs and uses them for an exact match when possible.

**User story:**
As a user, I want exact matches when a code exists, so that I trust the result more.

**How it works:**
1. Trigger: runs alongside text scanning.
2. Logic: detect codes with Vision; look up the code in the database if present; otherwise ignore it.
3. Result: an exact match candidate marked as code-verified.

**Inputs:** Camera frame.

**Outputs:** Code value and optional exact candidate.

**Edge cases & error handling:**
- Edge case: code not in the database → behavior: continue with text-based matching.

**Dependencies:** Feature 3; code coverage in the database.

---

## 5. Field extraction
**Category:** Scanning
**Phase:** Phase 2: Scan and Find MVP
**Priority:** Must-have

**What it does:**
Turns raw recognized text into structured fields: brand, salt, strength, expiry and batch.

**User story:**
As a user, I want the app to understand the strip text, so that I get the right medicine.

**How it works:**
1. Trigger: scan produces text.
2. Logic: rules and regex find strength patterns (for example `500 mg`), expiry patterns (`EXP 08/2027`, `08-2027`), and batch markers; remaining tokens become brand and salt candidates.
3. Result: a structured record with a confidence score per field.

**Inputs:** Recognized text.

**Outputs:** Structured fields.

**Edge cases & error handling:**
- Edge case: multiple dates printed (manufacture and expiry) → behavior: choose the one labeled EXP, otherwise the later date.
- Edge case: unreadable expiry → behavior: leave blank and ask the user to enter it.

**Dependencies:** Feature 3.

---

## 6. Drug matching with confirmation
**Category:** Matching
**Phase:** Phase 2: Scan and Find MVP
**Priority:** Must-have

**What it does:**
Finds the closest database entries and asks the user to confirm.

**User story:**
As any user, I want to confirm the app's guess, so that mistakes don't mislead me.

**How it works:**
1. Trigger: structured fields are ready.
2. Logic: query the FTS index; rank by fuzzy brand similarity, salt overlap and strength match; keep the top three.
3. Result: a confirmation screen with up to three candidates, each showing brand, salt and strength; user taps one or chooses "None of these."

**Inputs:** Structured fields.

**Outputs:** A confirmed drug record or a fallback to manual search.

**Edge cases & error handling:**
- Edge case: no candidate above the minimum score → behavior: say so and open manual search.
- Edge case: top candidates differ only by strength → behavior: highlight the strength.

**Dependencies:** Features 2, 5.

---

## 7. Manual search
**Category:** Matching
**Phase:** Phase 2: Scan and Find MVP
**Priority:** Must-have

**What it does:**
Lets the user type a brand or salt name and pick from results.

**User story:**
As a user whose scan failed, I want to search by name, so that I can still get information.

**How it works:**
1. Trigger: user opens Search or scanning fails.
2. Logic: FTS prefix and fuzzy search over brand and salt; show results as you type.
3. Result: a result list leading to the drug detail screen.

**Inputs:** Typed text.

**Outputs:** Search results.

**Edge cases & error handling:**
- Edge case: no results → behavior: suggest checking spelling and show the data coverage note.

**Dependencies:** Feature 2.

---

## 8. Drug detail screen
**Category:** Information
**Phase:** Phase 2: Scan and Find MVP
**Priority:** Must-have

**What it does:**
Shows the confirmed medicine's salt, strength, dosage form, pack size, price and data source.

**User story:**
As a patient, I want clear information about the strip, so that I understand what I'm holding.

**How it works:**
1. Trigger: a candidate is confirmed or a search result is opened.
2. Logic: load the record; show expiry from the scan if available; show source and last-updated date; show the disclaimer.
3. Result: a readable detail page with actions to find pharmacies (and later, alternatives and Add to shelf).

**Inputs:** Drug record, scanned expiry.

**Outputs:** Detail view.

**Edge cases & error handling:**
- Edge case: price missing → behavior: show "price not available."
- Edge case: expiry already passed → behavior: show a prominent expired warning.

**Dependencies:** Features 2, 6 or 7.

---

## 9. Nearby pharmacies map
**Category:** Map
**Phase:** Phase 2: Scan and Find MVP
**Priority:** Must-have

**What it does:**
Shows pharmacies near the user on a MapKit map.

**User story:**
As a traveler, I want to see nearby pharmacies, so that I can check whether they have what I need.

**How it works:**
1. Trigger: user taps Find pharmacies.
2. Logic: request when-in-use location; run a MapKit point-of-interest search filtered to pharmacies near the user; sort by distance.
3. Result: map pins and a list with distance.

**Inputs:** Location.

**Outputs:** Pharmacy results.

**Edge cases & error handling:**
- Error case: location denied → behavior: let the user type an area or place name.
- Error case: offline → behavior: explain that the map needs a connection.

**Dependencies:** Location permission, network.

---

## 10. Call or message pharmacy
**Category:** Map
**Phase:** Phase 2: Scan and Find MVP
**Priority:** Should-have

**What it does:**
One-tap call, or a prefilled message asking whether the pharmacy has the medicine.

**User story:**
As a user, I want to ask a pharmacy directly, so that I don't walk there for nothing.

**How it works:**
1. Trigger: user taps Call or Message on a pharmacy.
2. Logic: use the phone number from the map item; build a message such as "Do you have [brand] [strength], [dosage form]?" and open the system messaging or WhatsApp share.
3. Result: the call or message screen opens.

**Inputs:** Pharmacy, confirmed drug.

**Outputs:** Outgoing call or message draft.

**Edge cases & error handling:**
- Edge case: pharmacy has no phone number → behavior: hide the call button; offer directions.

**Dependencies:** Features 8, 9.

---

## 11. Generic alternatives with safeguards
**Category:** Information
**Phase:** Phase 3: Alternatives and My Medicines
**Priority:** Must-have

**What it does:**
Lists other brands with the same salt, strength and dosage form, with price per pack.

**User story:**
As a budget-conscious patient, I want to see cheaper equivalents, so that I can ask my pharmacist about them.

**How it works:**
1. Trigger: user opens Alternatives from the detail screen.
2. Logic: query records with identical salt composition, strength and dosage form; sort by price; show savings against the scanned medicine; show "Confirm with your pharmacist or doctor before switching"; if the drug is on the safety flag list, replace the list with "Do not switch without asking your doctor."
3. Result: a comparison list or the warning.

**Inputs:** Confirmed drug.

**Outputs:** Alternatives list.

**Edge cases & error handling:**
- Edge case: combination product (multiple salts) → behavior: require all salts and strengths to match exactly.
- Edge case: no alternatives → behavior: say so.

**Dependencies:** Features 2, 8; reviewed safety flag list.

---

## 12. My Medicines shelf
**Category:** Shelf
**Phase:** Phase 3: Alternatives and My Medicines
**Priority:** Must-have

**What it does:**
A private list of medicines the user owns, with expiry dates.

**User story:**
As a caregiver, I want a shelf of home medicines, so that I know what we have and what is expiring.

**How it works:**
1. Trigger: user taps Add to shelf after a scan or search.
2. Logic: store the drug reference, scanned or entered expiry, optional batch and an optional note in SwiftData; sort by soonest expiry.
3. Result: a shelf list with colored and labeled expiry status (ok, expiring soon, expired).

**Inputs:** Confirmed drug, expiry.

**Outputs:** Shelf records.

**Edge cases & error handling:**
- Edge case: duplicate entry → behavior: ask whether to add another strip or update the existing one.
- Edge case: no expiry known → behavior: require manual entry or mark unknown.

**Dependencies:** Feature 8.

---

## 13. Expiry reminders
**Category:** Shelf
**Phase:** Phase 3: Alternatives and My Medicines
**Priority:** Should-have

**What it does:**
Sends local notifications before a shelf item expires.

**User story:**
As a caregiver, I want reminders, so that expired medicines don't get used.

**How it works:**
1. Trigger: a shelf item is saved or edited, or notification permission is granted.
2. Logic: schedule local notifications at 30 days and 7 days before expiry and on the expiry day (user-adjustable); cancel them when the item is removed.
3. Result: timely reminders listing the medicine name.

**Inputs:** Shelf items, notification settings.

**Outputs:** Scheduled local notifications.

**Edge cases & error handling:**
- Error case: permission denied → behavior: show an in-app expiring list and a prompt to enable notifications.
- Edge case: expiry in the past → behavior: no scheduling; mark as expired.

**Dependencies:** Feature 12.

---

## 14. Jan Aushadhi store layer
**Category:** Map
**Phase:** Phase 3: Alternatives and My Medicines
**Priority:** Nice-to-have

**What it does:**
Marks government generic-medicine stores on the pharmacy map.

**User story:**
As a budget-conscious patient, I want to find low-cost generic stores nearby, so that I can save money.

**How it works:**
1. Trigger: pharmacy map opens with the layer enabled.
2. Logic: load a bundled store list (if a usable free dataset exists); show stores within a radius with a distinct marker and label.
3. Result: extra pins on the map.

**Inputs:** Store dataset, location.

**Outputs:** Store pins.

**Edge cases & error handling:**
- Edge case: dataset unavailable or unusable → behavior: feature deferred and hidden.

**Dependencies:** Feature 9; a verified dataset.

---

## 15. ML field tagger
**Category:** ML
**Phase:** Phase 4: Accessibility, ML and Data Updates
**Priority:** Should-have

**What it does:**
A small Core ML model that labels each recognized token as brand, salt, strength, expiry, batch or other.

**User story:**
As a user, I want more accurate recognition, so that I rarely need to correct the app.

**How it works:**
1. Trigger: scan text is ready.
2. Logic: run the Create ML word tagger over the tokens; merge its tags with the rules output, preferring the tagger when its confidence is higher; pass results to matching.
3. Result: more accurate structured fields.

**Inputs:** Recognized tokens.

**Outputs:** Tagged tokens.

**Edge cases & error handling:**
- Edge case: model fails to load → behavior: fall back to rules only.
- Edge case: unfamiliar label layout → behavior: low confidence defers to rules and the user's confirmation.

**Dependencies:** Features 5, 6; labeled training data.

---

## 16. Read-aloud and large text
**Category:** Accessibility
**Phase:** Phase 4: Accessibility, ML and Data Updates
**Priority:** Must-have

**What it does:**
Reads results aloud and supports large, high-contrast display.

**User story:**
As an elderly patient, I want the app to speak the medicine details, so that I can use it without reading small text.

**How it works:**
1. Trigger: user taps Read aloud or enables large mode in Settings.
2. Logic: use AVSpeechSynthesizer to read name, strength, expiry and the disclaimer; scale layouts with Dynamic Type; apply high-contrast styles.
3. Result: spoken and enlarged information.

**Inputs:** Drug detail, settings.

**Outputs:** Speech output and adapted UI.

**Edge cases & error handling:**
- Edge case: silent mode → behavior: show a prompt that speech output may be muted.
- Edge case: unsupported language voice → behavior: fall back to the default voice.

**Dependencies:** Feature 8.

---

## 17. Offline data updates via static hosting
**Category:** Data
**Phase:** Phase 4: Accessibility, ML and Data Updates
**Priority:** Should-have

**What it does:**
Downloads newer versions of the drug database from free static hosting.

**User story:**
As a user, I want the drug data to stay current, so that new brands and prices appear.

**How it works:**
1. Trigger: user taps Check for updates, or the app checks occasionally while online.
2. Logic: fetch a small manifest from GitHub Pages or Releases; compare versions; download the new SQLite file; verify its checksum and schema version; swap atomically; keep the previous version for rollback.
3. Result: updated data with a visible version and date.

**Inputs:** Manifest, database file.

**Outputs:** Installed database version.

**Edge cases & error handling:**
- Error case: checksum mismatch → behavior: discard the download and keep the current database.
- Error case: offline → behavior: skip silently and retry later.

**Dependencies:** Feature 2.

---

## Deferred / Future Features
- Crowd-reported availability — needs shared storage, which means a backend.
- Partner pharmacy stock feeds — needs integrations and agreements.
- Prescription scanning — handwriting recognition and clinical risk.
- Drug interaction checks — needs licensed data and clinical review.
- Family sharing — needs sync.
