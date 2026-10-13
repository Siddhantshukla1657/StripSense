//
//  AlternativesView.swift
//  StripSense
//

import SwiftUI

public struct AlternativesView: View {
    public let targetDrug: Drug
    
    private let alternativesService = AlternativesService()
    @State private var result: AlternativesResult?
    
    public init(targetDrug: Drug) {
        self.targetDrug = targetDrug
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                // Reference Drug Summary Card
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("CURRENT MEDICINE")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(.secondary)
                            Text(targetDrug.brand)
                                .font(.title3.weight(.bold))
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("CURRENT PRICE")
                                .font(.caption2.weight(.bold))
                                .foregroundColor(.secondary)
                            Text(targetDrug.formattedPrice)
                                .font(.headline.weight(.bold))
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Label(targetDrug.saltsSummary, systemImage: "pills.fill")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(targetDrug.dosageForm) • \(targetDrug.packSize)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(16)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(16)
                
                if let res = result {
                    if res.isSafetyBlocked {
                        // NTI Safety Guardrail Warning Banner
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.title)
                                    .foregroundColor(.red)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Brand Substitution Restricted")
                                        .font(.headline.weight(.bold))
                                        .foregroundColor(.red)
                                    Text("Critical therapeutic window")
                                        .font(.caption)
                                        .foregroundColor(.red.opacity(0.8))
                                }
                            }
                            
                            Text(res.safetyMessage ?? "Do not switch brands without consulting your doctor.")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 6) {
                                Image(systemName: "cross.case.fill")
                                    .foregroundColor(.red)
                                Text("Always maintain your prescribed brand for this salt.")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(16)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.red.opacity(0.4), lineWidth: 1.5)
                        )
                    } else if res.alternatives.isEmpty {
                        // No alternatives found
                        VStack(spacing: 12) {
                            Image(systemName: "pills.circle")
                                .font(.system(size: 44))
                                .foregroundColor(.secondary)
                            Text("No Direct Generic Alternatives Found")
                                .font(.headline)
                            Text("No other medicines in the offline database currently match the exact salt, strength, and dosage form.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.vertical, 32)
                    } else {
                        // Alternatives List
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("SAME-SALT EQUIVALENTS (\(res.alternatives.count))")
                                    .font(.caption2.weight(.bold))
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("Sorted by lowest price")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            ForEach(res.alternatives) { item in
                                alternativeRow(item)
                            }
                        }
                    }
                    
                    // Disclaimer
                    DisclaimerBanner(customText: res.disclaimer)
                }
            }
            .padding(16)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Generic Alternatives")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            self.result = alternativesService.alternatives(for: targetDrug)
        }
    }
    
    private func alternativeRow(_ item: AlternativeItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(item.drug.brand)
                            .font(.headline.weight(.bold))
                        
                        if item.drug.isJanAushadhi {
                            Text("PMBJP Generic")
                                .font(.caption2.weight(.bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.2))
                                .foregroundColor(Color(red: 0.08, green: 0.50, blue: 0.24))
                                .cornerRadius(6)
                        }
                    }
                    
                    Text(item.drug.manufacturer)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(item.drug.formattedPrice)
                        .font(.title3.weight(.bold))
                        .foregroundColor(.primary)
                    
                    Text("\(item.drug.packSize)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                    Text("Exact: \(item.drug.saltsSummary)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                if item.isCheaper {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.circle.fill")
                        Text(String(format: "Save ₹%.2f (%.0f%%)", item.savingsINR, item.savingsPercentage))
                    }
                    .font(.caption.weight(.bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.15))
                    .foregroundColor(Color(red: 0.08, green: 0.50, blue: 0.24))
                    .clipShape(Capsule())
                } else {
                    Text("Similar Price")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(14)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(item.drug.isJanAushadhi ? Color.green.opacity(0.4) : Color.secondary.opacity(0.15), lineWidth: 1)
        )
    }
}
