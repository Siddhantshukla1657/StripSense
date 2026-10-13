//
//  ScanView.swift
//  StripSense
//

import SwiftUI
import PhotosUI

public struct ScanView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var db = DrugDatabaseService.shared
    
    // Scan pipeline state
    @State private var scanResult: ScanResult?
    @State private var extractedFields: ExtractedFields?
    @State private var candidates: [Candidate] = []
    @State private var showCandidatesSheet: Bool = false
    @State private var selectedConfirmedDrug: Drug?
    @State private var isProcessing: Bool = false
    @State private var scannerTip: String = "Position the strip inside the frame. Avoid glare from foil."
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showManualSearch: Bool = false
    
    // Callback for when a drug is confirmed
    public var onDrugConfirmed: ((Drug, ExtractedFields?) -> Void)?
    
    public init(onDrugConfirmed: ((Drug, ExtractedFields?) -> Void)? = nil) {
        self.onDrugConfirmed = onDrugConfirmed
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                // Camera View
                CameraScannerRepresentable(
                    onScanResult: { result in
                        handleScanResult(result)
                    },
                    onError: { err in
                        scannerTip = err
                    }
                )
                .ignoresSafeArea()
                
                // Viewfinder Overlays
                VStack {
                    // Top Bar Controls
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.title3.weight(.bold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Close scanner")
                        
                        Spacer()
                        
                        // Torch indicator / button
                        Button(action: {}) {
                            Image(systemName: "flashlight.on.fill")
                                .font(.body.weight(.bold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Toggle flashlight")
                        
                        // Photo Library Picker
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.body.weight(.bold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Import photo from library")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    
                    Spacer()
                    
                    // Viewfinder Target Frame
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.8), lineWidth: 2)
                            .frame(width: 290, height: 180)
                        
                        // Corner Guides
                        VStack {
                            HStack {
                                cornerMarker(rotation: 0)
                                Spacer()
                                cornerMarker(rotation: 90)
                            }
                            Spacer()
                            HStack {
                                cornerMarker(rotation: 270)
                                Spacer()
                                cornerMarker(rotation: 180)
                            }
                        }
                        .frame(width: 290, height: 180)
                    }
                    
                    // Tips Banner
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.yellow)
                        Text(scannerTip)
                            .font(.caption.weight(.medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.75))
                    .cornerRadius(12)
                    .padding(.top, 16)
                    
                    Spacer()
                    
                    // Bottom Controls & Quick Sample Strips Runner
                    VStack(spacing: 12) {
                        // Quick Simulator Samples
                        VStack(alignment: .leading, spacing: 6) {
                            Text("TEST WITH SAMPLE STRIPS (INSTANT OCR DEMO)")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(InitialDrugData.sampleStrips) { sample in
                                        Button(action: {
                                            runSampleStrip(sample)
                                        }) {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(sample.title)
                                                    .font(.caption.weight(.bold))
                                                    .foregroundColor(.white)
                                                Text(sample.subtitle)
                                                    .font(.caption2)
                                                    .foregroundColor(.white.opacity(0.7))
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color.white.opacity(0.2))
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.bottom, 6)
                        
                        // Manual search fallback button
                        Button(action: {
                            showManualSearch = true
                        }) {
                            HStack {
                                Image(systemName: "keyboard")
                                Text("Can't scan? Search by Name")
                            }
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
            .sheet(isPresented: $showCandidatesSheet) {
                if let fields = extractedFields {
                    ConfirmCandidatesView(
                        candidates: candidates,
                        extractedFields: fields,
                        onSelectCandidate: { chosenDrug in
                            showCandidatesSheet = false
                            selectedConfirmedDrug = chosenDrug
                            onDrugConfirmed?(chosenDrug, fields)
                        },
                        onNoneOfThese: {
                            showCandidatesSheet = false
                            showManualSearch = true
                        }
                    )
                }
            }
            .sheet(isPresented: $showManualSearch) {
                ManualSearchView { drug in
                    showManualSearch = false
                    selectedConfirmedDrug = drug
                    onDrugConfirmed?(drug, nil)
                }
            }
            .navigationDestination(item: $selectedConfirmedDrug) { drug in
                DrugDetailView(drug: drug, extractedFields: extractedFields)
            }
        }
    }
    
    private func cornerMarker(rotation: Double) -> some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 16))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 16, y: 0))
        }
        .stroke(Color.blue, lineWidth: 4)
        .frame(width: 16, height: 16)
        .rotationEffect(.degrees(rotation))
    }
    
    private func handleScanResult(_ result: ScanResult) {
        guard !isProcessing else { return }
        isProcessing = true
        
        let fields = FieldExtractor.extract(from: result)
        let matching = MatchingService()
        let scoredCandidates = matching.candidates(for: fields)
        
        self.scanResult = result
        self.extractedFields = fields
        self.candidates = scoredCandidates
        self.showCandidatesSheet = true
        self.isProcessing = false
    }
    
    private func runSampleStrip(_ sample: SampleStrip) {
        let result = ScanResult(
            rawText: sample.text,
            recognizedLines: sample.text.components(separatedBy: .newlines),
            detectedBarcode: sample.barcode,
            confidence: 0.95
        )
        handleScanResult(result)
    }
}

public struct ManualSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var db = DrugDatabaseService.shared
    @State private var query: String = ""
    public var onSelect: (Drug) -> Void
    
    public init(onSelect: @escaping (Drug) -> Void) {
        self.onSelect = onSelect
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                SearchBarView(text: $query, placeholder: "Type brand (Dolo, Pan) or salt...")
                    .padding(.horizontal)
                    .padding(.top, 10)
                
                let results = db.search(query: query)
                
                if results.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No matching medicine found")
                            .font(.headline)
                        Text("Check spelling or verify that the medicine is listed in the NLEM database.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List(results) { drug in
                        Button(action: {
                            onSelect(drug)
                            dismiss()
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(drug.brand)
                                        .font(.headline.weight(.semibold))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text(drug.formattedPrice)
                                        .font(.subheadline.weight(.bold))
                                        .foregroundColor(.primary)
                                }
                                Text(drug.saltsSummary)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(drug.dosageForm) • \(drug.manufacturer)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Manual Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
