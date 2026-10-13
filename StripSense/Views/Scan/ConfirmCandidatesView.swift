//
//  ConfirmCandidatesView.swift
//  StripSense
//

import SwiftUI

public struct ConfirmCandidatesView: View {
    public let candidates: [Candidate]
    public let extractedFields: ExtractedFields
    public var onSelectCandidate: (Drug) -> Void
    public var onNoneOfThese: () -> Void
    
    public init(
        candidates: [Candidate],
        extractedFields: ExtractedFields,
        onSelectCandidate: @escaping (Drug) -> Void,
        onNoneOfThese: @escaping () -> Void
    ) {
        self.candidates = candidates
        self.extractedFields = extractedFields
        self.onSelectCandidate = onSelectCandidate
        self.onNoneOfThese = onNoneOfThese
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundColor(Color(red: 0.15, green: 0.39, blue: 0.92))
                        .font(.title3)
                    Text("Confirm Identified Medicine")
                        .font(.title3.weight(.bold))
                }
                
                Text("Select the card that matches the medicine strip you are holding. We never auto-select without your verification.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            // Extracted strip info banner
            if extractedFields.detectedExpiryString != nil || extractedFields.detectedStrength != nil {
                HStack(spacing: 12) {
                    if let str = extractedFields.detectedStrength {
                        Label(str, systemImage: "pills.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.blue)
                    }
                    if let exp = extractedFields.detectedExpiryString {
                        Label("Exp: \(exp)", systemImage: "calendar")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.orange)
                    }
                    if let batch = extractedFields.detectedBatchNumber {
                        Label("B: \(batch)", systemImage: "number")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(UIColor.tertiarySystemGroupedBackground))
                .cornerRadius(10)
                .padding(.bottom, 12)
            }
            
            ScrollView {
                VStack(spacing: 14) {
                    if candidates.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            Text("No Confident Matches Found")
                                .font(.headline)
                            Text("The text on the foil may be blurry or not yet in the offline database.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 30)
                    } else {
                        ForEach(candidates) { candidate in
                            candidateCard(candidate)
                        }
                    }
                    
                    // "None of these" button
                    Button(action: onNoneOfThese) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("None of these (Search by Name)")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 50)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .foregroundColor(.primary)
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.top, 6)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    private func candidateCard(_ candidate: Candidate) -> some View {
        Button(action: {
            onSelectCandidate(candidate.drug)
        }) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(candidate.drug.brand)
                                .font(.headline.weight(.bold))
                                .foregroundColor(.primary)
                            
                            if candidate.drug.isJanAushadhi {
                                Text("Jan Aushadhi")
                                    .font(.caption2.weight(.bold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.green.opacity(0.2))
                                    .foregroundColor(.green)
                                    .cornerRadius(6)
                            }
                        }
                        
                        Text(candidate.drug.manufacturer)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Match Score Badge
                    Text("\(Int(candidate.score * 100))% match")
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.12))
                        .foregroundColor(.blue)
                        .clipShape(Capsule())
                }
                
                Divider()
                
                // Salt composition & highlighted strength
                VStack(alignment: .leading, spacing: 4) {
                    Text("Composition & Strength:")
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 6) {
                        Text(candidate.drug.saltsSummary)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        if candidate.isStrengthMatched {
                            HStack(spacing: 3) {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Strength match")
                            }
                            .font(.caption2.weight(.bold))
                            .foregroundColor(.green)
                        }
                    }
                }
                
                HStack {
                    Text("\(candidate.drug.dosageForm) • \(candidate.drug.packSize)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(candidate.drug.formattedPrice)
                        .font(.subheadline.weight(.bold))
                        .foregroundColor(.primary)
                }
                
                // Match Reason
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.caption2)
                    Text(candidate.matchReason)
                        .font(.caption2)
                }
                .foregroundColor(.blue)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1.5)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Select \(candidate.drug.brand), \(candidate.drug.saltsSummary), price \(candidate.drug.formattedPrice)")
    }
}
