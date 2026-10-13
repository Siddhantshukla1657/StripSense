//
//  MatchingService.swift
//  StripSense
//

import Foundation

public struct MatchingService {
    private let database: DrugDatabaseService
    
    public init(database: DrugDatabaseService = .shared) {
        self.database = database
    }
    
    /// Produces up to three ranked candidates based on extracted fields
    public func candidates(for fields: ExtractedFields) -> [Candidate] {
        // 1. Exact barcode match
        if let barcode = fields.detectedBarcode, !barcode.isEmpty {
            if let matchedDrug = database.drug(byBarcode: barcode) {
                return [
                    Candidate(
                        drug: matchedDrug,
                        score: 1.0,
                        matchReason: "Verified Barcode Match (\(barcode))",
                        isStrengthMatched: true
                    )
                ]
            }
        }
        
        let allDrugs = database.drugs
        var scoredCandidates: [Candidate] = []
        
        let normalizedRawText = StringSimilarity.normalize(fields.rawText)
        let detectedStrengthNorm = fields.detectedStrength.map { StringSimilarity.normalize($0) }
        
        for drug in allDrugs {
            var score = 0.0
            var reasons: [String] = []
            
            let brandNorm = StringSimilarity.normalize(drug.brand)
            let saltsNorm = StringSimilarity.normalize(drug.saltsSummary)
            let drugStrengthNorm = StringSimilarity.normalize(drug.strengthSummary)
            
            // A. Brand match check
            if normalizedRawText.contains(brandNorm) {
                score += 0.50
                reasons.append("Brand '\(drug.brand)' matched in strip")
            } else {
                let sim = StringSimilarity.similarityRatio(fields.detectedBrand ?? "", brandNorm)
                if sim > 0.6 {
                    score += 0.40 * sim
                    reasons.append("Fuzzy brand match (\(Int(sim * 100))%)")
                }
            }
            
            // B. Salt names check
            var saltMatchCount = 0
            for salt in drug.salts {
                let sNameNorm = StringSimilarity.normalize(salt.name)
                if normalizedRawText.contains(sNameNorm) {
                    saltMatchCount += 1
                }
            }
            if saltMatchCount > 0 {
                let saltRatio = Double(saltMatchCount) / Double(drug.salts.count)
                score += 0.30 * saltRatio
                reasons.append("Active salt matched")
            }
            
            // C. Strength match check
            var strengthMatched = false
            if let detectedStr = detectedStrengthNorm, !detectedStr.isEmpty {
                if drugStrengthNorm.contains(detectedStr) || detectedStr.contains(drugStrengthNorm) {
                    score += 0.20
                    strengthMatched = true
                    reasons.append("Strength (\(drug.strengthSummary)) confirmed")
                } else if normalizedRawText.contains(drugStrengthNorm) {
                    score += 0.15
                    strengthMatched = true
                    reasons.append("Strength text matched")
                }
            } else if normalizedRawText.contains(drugStrengthNorm) {
                score += 0.15
                strengthMatched = true
                reasons.append("Strength '\(drug.strengthSummary)' found")
            }
            
            // Only consider if score is above threshold
            if score >= 0.25 {
                let reason = reasons.isEmpty ? "Fuzzy match" : reasons.joined(separator: " • ")
                scoredCandidates.append(
                    Candidate(
                        drug: drug,
                        score: min(0.99, score),
                        matchReason: reason,
                        isStrengthMatched: strengthMatched
                    )
                )
            }
        }
        
        // Sort descending by score, take top 3
        let topCandidates = scoredCandidates
            .sorted { $0.score > $1.score }
            .prefix(3)
        
        return Array(topCandidates)
    }
}
