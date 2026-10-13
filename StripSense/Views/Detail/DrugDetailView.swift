//
//  DrugDetailView.swift
//  StripSense
//

import SwiftUI

public struct DrugDetailView: View {
    public let drug: Drug
    public var extractedFields: ExtractedFields?
    
    @StateObject private var speechService = SpeechService.shared
    @StateObject private var shelfService = ShelfService.shared
    @State private var showAddToShelfSheet: Bool = false
    @State private var showAddedToast: Bool = false
    @State private var toastMessage: String = ""
    
    public init(drug: Drug, extractedFields: ExtractedFields? = nil) {
        self.drug = drug
        self.extractedFields = extractedFields
    }
    
    private var scannedExpiryStatus: ExpiryStatus? {
        guard let expiryDate = extractedFields?.detectedExpiryDate else { return nil }
        let now = Date()
        if expiryDate < now { return .expired }
        let thirtyDays = Calendar.current.date(byAdding: .day, value: 30, to: now) ?? now
        if expiryDate <= thirtyDays { return .expiringSoon }
        return .ok
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Medicine Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                Text(drug.brand)
                                    .font(.title2.weight(.bold))
                                    .foregroundColor(.primary)
                                
                                if drug.isJanAushadhi {
                                    Text("PMBJP Generic")
                                        .font(.caption2.weight(.bold))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color.green.opacity(0.18))
                                        .foregroundColor(Color(red: 0.08, green: 0.50, blue: 0.24))
                                        .cornerRadius(6)
                                }
                            }
                            
                            Text(drug.manufacturer)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Read-Aloud Voice Button
                        Button(action: {
                            if speechService.isSpeaking {
                                speechService.stop()
                            } else {
                                speechService.speak(
                                    drug: drug,
                                    expiryStatus: scannedExpiryStatus,
                                    expiryString: extractedFields?.detectedExpiryString
                                )
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: speechService.isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2")
                                    .font(.subheadline.weight(.semibold))
                                Text(speechService.isSpeaking ? "Stop" : "Read")
                                    .font(.caption.weight(.bold))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.12))
                            .foregroundColor(.blue)
                            .clipShape(Capsule())
                        }
                        .accessibilityLabel(speechService.isSpeaking ? "Stop read aloud" : "Read medicine details aloud")
                    }
                    
                    Divider()
                    
                    // Salt composition & strength
                    VStack(alignment: .leading, spacing: 4) {
                        Text("ACTIVE COMPOSITION")
                            .font(.caption2.weight(.bold))
                            .foregroundColor(.secondary)
                        
                        ForEach(drug.salts) { salt in
                            HStack {
                                Text(salt.name)
                                    .font(.body.weight(.medium))
                                Spacer()
                                Text(salt.strength)
                                    .font(.body.weight(.bold))
                                    .foregroundColor(.blue)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    
                    Divider()
                    
                    // Price & Packaging
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("MAX RETAIL PRICE (MRP)")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(.secondary)
                            Text(drug.formattedPrice)
                                .font(.title3.weight(.bold))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("PACKAGING")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(.secondary)
                            Text("\(drug.packSize) • \(drug.dosageForm)")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(18)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(18)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                
                // Expiry Banner (if detected in scan)
                if let expiryDate = extractedFields?.detectedExpiryDate, let status = scannedExpiryStatus {
                    HStack(spacing: 12) {
                        Image(systemName: status.iconName)
                            .font(.title2)
                            .foregroundColor(expiryColor(for: status))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text("Scanned Expiry: \(extractedFields?.detectedExpiryString ?? "Date Found")")
                                    .font(.subheadline.weight(.bold))
                                Spacer()
                                StatusBadgeView(status: status)
                            }
                            
                            if status == .expired {
                                Text("⚠️ This medicine is EXPIRED. Do not consume or sell.")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(.red)
                            } else if status == .expiringSoon {
                                Text("Expiring soon within the next 30 days. Plan replacement.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Within safe usable date.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(14)
                    .background(expiryColor(for: status).opacity(0.1))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(expiryColor(for: status).opacity(0.3), lineWidth: 1)
                    )
                }
                
                // Safety Flag Alert (Narrow Therapeutic Index)
                if let flag = drug.safetyFlag {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.octagon.fill")
                                .foregroundColor(.red)
                                .font(.headline)
                            Text("Narrow Therapeutic Index Alert")
                                .font(.headline.weight(.bold))
                                .foregroundColor(.red)
                        }
                        
                        Text(flag.reason)
                            .font(.footnote)
                            .foregroundColor(.primary)
                        
                        Text("Source: \(flag.source)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(14)
                    .background(Color.red.opacity(0.08))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
                }
                
                // Primary Action Navigation Buttons
                VStack(spacing: 12) {
                    // 1. Generic Alternatives Button
                    NavigationLink(destination: AlternativesView(targetDrug: drug)) {
                        HStack {
                            Image(systemName: "arrow.triangle.branch")
                                .font(.headline)
                                .foregroundColor(.green)
                                .frame(width: 32, height: 32)
                                .background(Color.green.opacity(0.15))
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Same-Salt Alternatives & Prices")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("Compare cheaper brands and Jan Aushadhi generic options")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.footnote.weight(.semibold))
                        }
                        .padding(14)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                    }
                    
                    // 2. Nearby Pharmacies Button
                    NavigationLink(destination: PharmaciesView(targetDrug: drug)) {
                        HStack {
                            Image(systemName: "map.fill")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .frame(width: 32, height: 32)
                                .background(Color.blue.opacity(0.15))
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Find Nearby Pharmacies")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("Locate chemists and Jan Aushadhi stores on map to call")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.footnote.weight(.semibold))
                        }
                        .padding(14)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                    }
                    
                    // 3. Add to My Shelf Button
                    Button(action: {
                        showAddToShelfSheet = true
                    }) {
                        HStack {
                            Image(systemName: "archivebox.fill")
                                .font(.headline)
                                .foregroundColor(.purple)
                                .frame(width: 32, height: 32)
                                .background(Color.purple.opacity(0.15))
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Add to My Medicines Shelf")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("Save privately on device with expiry reminder notifications")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.purple)
                                .font(.title3)
                        }
                        .padding(14)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                    }
                }
                
                // Data Source Attribution
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.footnote)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Data Source: \(drug.source)")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)
                        Text("License: \(drug.license)")
                            .font(.caption2)
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                    Spacer()
                }
                .padding(.horizontal, 6)
                
                // Standard Disclaimer Banner
                DisclaimerBanner()
            }
            .padding(16)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle(drug.brand)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddToShelfSheet) {
            AddEditShelfItemView(
                prefilledDrug: drug,
                prefilledExpiry: extractedFields?.detectedExpiryDate,
                prefilledBatch: extractedFields?.detectedBatchNumber
            )
        }
        .onDisappear {
            speechService.stop()
        }
    }
    
    private func expiryColor(for status: ExpiryStatus) -> Color {
        switch status {
        case .ok:
            return Color(red: 0.08, green: 0.50, blue: 0.24)
        case .expiringSoon:
            return Color(red: 0.71, green: 0.33, blue: 0.04)
        case .expired:
            return Color(red: 0.73, green: 0.11, blue: 0.11)
        case .unknown:
            return Color.secondary
        }
    }
}
