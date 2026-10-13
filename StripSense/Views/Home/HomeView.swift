//
//  HomeView.swift
//  StripSense
//

import SwiftUI

public struct HomeView: View {
    @StateObject private var shelfService = ShelfService.shared
    @StateObject private var db = DrugDatabaseService.shared
    
    @State private var showScanner: Bool = false
    @State private var searchQuery: String = ""
    @State private var selectedDrugForDetail: Drug?
    @State private var selectedExtractedFields: ExtractedFields?
    @State private var activeTabSelection: Int = 0
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // App Brand Header
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("StripSense")
                                .font(.system(.largeTitle, design: .rounded).weight(.heavy))
                                .foregroundColor(Color(red: 0.15, green: 0.39, blue: 0.92))
                            
                            Text("Scan • Identify • Save on Generics")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Privacy indicator badge
                        HStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .font(.caption2)
                            Text("Offline")
                                .font(.caption2.weight(.bold))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.12))
                        .foregroundColor(Color(red: 0.08, green: 0.50, blue: 0.24))
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Search Bar
                    SearchBarView(text: $searchQuery, placeholder: "Search medicine brand or salt...")
                        .padding(.horizontal, 20)
                    
                    // If user is searching, show instant search results
                    if !searchQuery.isEmpty {
                        let searchResults = db.search(query: searchQuery)
                        VStack(alignment: .leading, spacing: 10) {
                            Text("SEARCH RESULTS (\(searchResults.count))")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 20)
                            
                            if searchResults.isEmpty {
                                Text("No medicine matching '\(searchQuery)'")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                            } else {
                                ForEach(searchResults.prefix(5)) { drug in
                                    Button(action: {
                                        selectedDrugForDetail = drug
                                    }) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 3) {
                                                Text(drug.brand)
                                                    .font(.headline.weight(.semibold))
                                                    .foregroundColor(.primary)
                                                Text(drug.saltsSummary)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            Text(drug.formattedPrice)
                                                .font(.subheadline.weight(.bold))
                                                .foregroundColor(.blue)
                                        }
                                        .padding(14)
                                        .background(Color(UIColor.secondarySystemGroupedBackground))
                                        .cornerRadius(14)
                                        .padding(.horizontal, 20)
                                    }
                                }
                            }
                        }
                    } else {
                        // Main Big Scan Action Card
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            showScanner = true
                        }) {
                            VStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                        .frame(width: 64, height: 64)
                                    Image(systemName: "viewfinder")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                VStack(spacing: 4) {
                                    Text("Scan Medicine Strip")
                                        .font(.title3.weight(.bold))
                                        .foregroundColor(.white)
                                    Text("Point camera at strip foil or box to identify salt & expiry")
                                        .font(.footnote)
                                        .foregroundColor(.white.opacity(0.85))
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .padding(.vertical, 24)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.15, green: 0.39, blue: 0.92),
                                        Color(red: 0.08, green: 0.25, blue: 0.75)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(22)
                            .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 6)
                        }
                        .padding(.horizontal, 20)
                        
                        // Shelf Expiry Alert Summary
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("MY MEDICINES CABINET")
                                    .font(.caption2.weight(.bold))
                                    .foregroundColor(.secondary)
                                Spacer()
                                NavigationLink(destination: ShelfView()) {
                                    Text("View Shelf")
                                        .font(.caption.weight(.bold))
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            HStack(spacing: 12) {
                                StatCard(
                                    title: "Total Stored",
                                    value: "\(shelfService.items.count)",
                                    icon: "archivebox.fill",
                                    color: .blue
                                )
                                
                                StatCard(
                                    title: "Expiring Soon",
                                    value: "\(shelfService.expiringSoonCount)",
                                    icon: "clock.badge.exclamationmark.fill",
                                    color: Color(red: 0.71, green: 0.33, blue: 0.04),
                                    subtitle: shelfService.expiringSoonCount > 0 ? "Next 30 days" : nil
                                )
                                
                                StatCard(
                                    title: "Expired",
                                    value: "\(shelfService.expiredCount)",
                                    icon: "exclamationmark.triangle.fill",
                                    color: Color(red: 0.73, green: 0.11, blue: 0.11),
                                    subtitle: shelfService.expiredCount > 0 ? "Inspect cabinet" : nil
                                )
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Sample Strips Interactive Carousel for Simulator / Demo
                        VStack(alignment: .leading, spacing: 10) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("DEMO & SIMULATOR SAMPLES")
                                    .font(.caption2.weight(.bold))
                                    .foregroundColor(.secondary)
                                Text("Tap any strip below to simulate instant on-device OCR")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(InitialDrugData.sampleStrips) { sample in
                                        Button(action: {
                                            runSample(sample)
                                        }) {
                                            VStack(alignment: .leading, spacing: 6) {
                                                HStack {
                                                    Image(systemName: "pills.fill")
                                                        .foregroundColor(.blue)
                                                    Text(sample.title)
                                                        .font(.subheadline.weight(.bold))
                                                        .foregroundColor(.primary)
                                                }
                                                
                                                Text(sample.subtitle)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                                    .lineLimit(2)
                                                
                                                Spacer()
                                                
                                                HStack {
                                                    Text("Simulate Scan")
                                                        .font(.caption2.weight(.bold))
                                                        .foregroundColor(.blue)
                                                    Image(systemName: "arrow.right.circle.fill")
                                                        .font(.caption2)
                                                        .foregroundColor(.blue)
                                                }
                                            }
                                            .padding(14)
                                            .frame(width: 220, height: 115)
                                            .background(Color(UIColor.secondarySystemGroupedBackground))
                                            .cornerRadius(16)
                                            .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        // Disclaimer Banner
                        DisclaimerBanner()
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 30)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .fullScreenCover(isPresented: $showScanner) {
                ScanView { confirmedDrug, fields in
                    selectedDrugForDetail = confirmedDrug
                    selectedExtractedFields = fields
                }
            }
            .navigationDestination(item: $selectedDrugForDetail) { drug in
                DrugDetailView(drug: drug, extractedFields: selectedExtractedFields)
            }
        }
    }
    
    private func runSample(_ sample: SampleStrip) {
        let result = ScanResult(
            rawText: sample.text,
            recognizedLines: sample.text.components(separatedBy: .newlines),
            detectedBarcode: sample.barcode,
            confidence: 0.95
        )
        let fields = FieldExtractor.extract(from: result)
        let matching = MatchingService()
        let candidates = matching.candidates(for: fields)
        if let topCandidate = candidates.first {
            selectedDrugForDetail = topCandidate.drug
            selectedExtractedFields = fields
        }
    }
}
