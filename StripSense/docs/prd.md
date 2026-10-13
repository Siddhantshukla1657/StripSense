# StripSense — Product Requirements Document

> **Status:** Draft | **Last updated:** 2026-10-10 | **Owner:** Siddhant Shukla

## 1. Overview
StripSense is an iPhone app that identifies a medicine from a photo or live scan of its strip, shows its salt, strength and expiry, lists cheaper same-salt alternatives with safety guardrails, and shows nearby pharmacies you can call. It also keeps a private shelf of the medicines you own with expiry reminders. It runs fully on device, needs no accounts, and uses only free tools and data. *(Assumption: India first, because of the brand and price data and Jan Aushadhi stores.)*

## 2. Problem Statement
Medicine strips are crowded with tiny, hard-to-read print. Patients, the elderly and families managing prescriptions often can't tell quickly what a strip contains, when it expires, whether a cheaper equivalent exists, or where to buy it nearby. Brand-name medicines can cost several times more than generics with the same salt, and expired medicines linger in homes. Existing pharmacy apps mostly focus on search and ordering, require accounts and connectivity, and don't help with strips you already hold. *(To confirm with a competitor scan and interviews.)*

## 3. Goals
- Identify common medicines from a strip quickly and with user confirmation.
- Surface safe, same-salt alternatives and prices to help people spend less.
- Help households avoid expired medicines.
- Work offline, privately, and at zero cost to build and run.

## 4. Non-Goals
- Medical advice, diagnosis, dosing or interaction guidance.
- Prescription scanning or handwriting recognition.
- Live pharmacy stock or ordering and delivery.
- Counterfeit detection.
- User accounts, cloud sync or any custom backend.
- Android or web in the first release.

## 5. Target Users / Personas
| Persona | Description | Primary need |
|---|---|---|
| Elderly patient | Takes several daily medicines; struggles with small print | Large, readable, spoken information about each strip |
| Family caregiver | Manages medicines for parents or children | Track what is at home and what is expiring |
| Budget-conscious patient | Pays out of pocket | See cheaper equivalents and their prices |
| Traveler or newcomer | Needs a medicine in an unfamiliar area | Find a nearby pharmacy fast |

## 6. User Stories
- As an elderly patient, I want to scan a strip and hear its name and expiry, so that I don't have to squint at the print.
- As a caregiver, I want a shelf of home medicines with expiry reminders, so that nothing expired gets used.
- As a budget-conscious patient, I want to see same-salt alternatives and prices, so that I can ask my pharmacist about cheaper options.
- As a traveler, I want to find nearby pharmacies and call one in a tap, so that I can check whether they have what I need.
- As any user, I want to confirm the app's guess before trusting it, so that mistakes don't mislead me.

## 7. Requirements
### 7.1 Functional Requirements
1. The system must scan a medicine strip or box using the camera, or from a saved photo, entirely on device.
2. The system must read barcodes or QR codes when present and use them as the first identification attempt.
3. The system must extract brand, salt, strength, expiry and batch from recognized text.
4. The system must present up to three candidate matches and require user confirmation before showing details.
5. The system must offer manual search by name when scanning fails.
6. The system must show salt, strength, dosage form, pack size and price for a confirmed medicine, with its data source.
7. The system must show nearby pharmacies on a map with one-tap call and prefilled message actions.
8. The system must list alternatives only when salt, strength and dosage form match exactly, with a pharmacist disclaimer (Phase 3).
9. The system must flag medicines where switching brands needs a doctor's input (Phase 3).
10. The system must keep a private shelf with expiry dates and send local expiry reminders (Phase 3).
11. The system must support large text, VoiceOver and read-aloud (Phase 4).
12. The system must support integrity-checked data updates from static hosting (Phase 4).

### 7.2 Non-Functional Requirements
- **Cost:** every dependency is free at development and runtime (see section 9 for the one distribution caveat).
- **Privacy:** scans and the shelf stay on device; no analytics that capture medicine data; no accounts.
- **Offline:** scanning, matching, details and the shelf work without a network; only the map and pharmacy search need one.
- **Performance:** a scan produces candidates in under 3 seconds on a recent iPhone.
- **Accessibility:** Dynamic Type, VoiceOver, high contrast, and never color alone.
- **Safety:** no dosing advice; always show a disclaimer; never present a match as certain without confirmation.

## 8. Success Metrics
| Metric | Target | Timeframe |
|---|---|---|
| Top-3 match accuracy on the photo set | ≥ 80% | End of Phase 1 |
| Expiry parsed correctly (strips showing one) | ≥ 80% | End of Phase 1 |
| Time from scan to pharmacy call | < 60 s | End of Phase 2 |
| Alternatives matching on salt, strength and form | 100% (test-enforced) | End of Phase 3 |
| Field accuracy lift from the ML tagger | ≥ +5 points | End of Phase 4 |
| Testers who say they'd use the shelf for expiry tracking | ≥ 60% of 10+ testers | After Phase 3 |

## 9. Constraints & Assumptions
- Constraint: no custom backend and no recurring costs.
- Constraint: free tools only — Xcode, Apple Vision, VisionKit, MapKit, Create ML, SwiftData, SQLite, and static hosting on GitHub.
- Constraint: **distribution is not fully free.** Installing on your own iPhone through Xcode with a free Apple ID works but needs re-signing about every 7 days. TestFlight and the App Store require the paid Apple Developer Program (about USD 99 per year). Plan to demo from your own device and publish the source on GitHub unless you decide to pay.
- Constraint: requires a Mac to build; scanning needs a recent iPhone supporting VisionKit data scanning.
- Assumption: free public datasets (price lists, Jan Aushadhi products) cover enough common medicines; licenses must be verified.
- Assumption: native MapKit pharmacy search is free for a small app (verify usage limits).
- Assumption: users will confirm candidates rather than trust a single guess.

## 10. Dependencies
- Apple Vision, VisionKit, MapKit, Create ML, SwiftData, UserNotifications (all free with Xcode).
- Public drug and price data (NPPA/NLEM lists, Jan Aushadhi product list and others; licenses to verify).
- GitHub Pages or Releases for optional static data updates.

## 11. Risks
| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Wrong medicine shown as certain | Medium | High | Always show top-3 candidates and require confirmation; clear disclaimers |
| Liability from alternatives being read as advice | Medium | High | Same salt, strength and form only; pharmacist disclaimer; "ask your doctor" flags |
| Free drug data incomplete or unlicensed | High | High | Start with a curated top-few-hundred list; document every source and license |
| OCR fails on glare and curved foil | High | Medium | Capture guidance, multi-frame voting, manual search fallback |
| No live stock information | High | Medium | Position the app as "find and call", not "in stock"; defer crowd reports |
| Cannot distribute widely for free | High | Medium | Own-device install and open-source repo; revisit the paid program later |
| Sensitive health data exposure | Low | High | On-device only; no sync; no analytics on medicine data |

## 12. Open Questions
- [ ] Which free data sources are complete enough and legally usable?
- [ ] Is the Jan Aushadhi store list available as usable data?
- [ ] Will you pay for the Apple Developer Program later, or stay on own-device and open source?
- [ ] Which narrow-therapeutic-index list is authoritative enough to bundle?
- [ ] Should regional-language names be in scope for the first release?
