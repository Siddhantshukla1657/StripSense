//
//  FieldExtractor.swift
//  StripSense
//

import Foundation

public struct FieldExtractor {
    private static let strengthPattern = #"\b(\d+(?:\.\d+)?)\s*(mg|mcg|g|ml|iu|%|v\/v|w\/v|mg\/ml)\b"#
    
    /// Extracts structured fields from raw OCR scan result
    public static func extract(from scanResult: ScanResult) -> ExtractedFields {
        var fields = ExtractedFields(
            rawText: scanResult.rawText,
            detectedBarcode: scanResult.detectedBarcode,
            confidence: scanResult.confidence
        )
        
        // 1. Parse Expiry & Batch
        let parseResult = ExpiryDateParser.parse(from: scanResult.rawText)
        fields.detectedExpiryDate = parseResult.date
        fields.detectedExpiryString = parseResult.rawDateString
        fields.detectedBatchNumber = parseResult.batchNumber
        
        // 2. Parse Strength Patterns
        let lines = scanResult.recognizedLines
        var foundStrengths: [String] = []
        
        if let regex = try? NSRegularExpression(pattern: strengthPattern, options: .caseInsensitive) {
            for line in lines {
                let nsLine = line as NSString
                let fullRange = NSRange(location: 0, length: nsLine.length)
                let matches = regex.matches(in: line, options: [], range: fullRange)
                for match in matches {
                    let strengthStr = nsLine.substring(with: match.range).lowercased()
                    if !foundStrengths.contains(strengthStr) {
                        foundStrengths.append(strengthStr)
                    }
                }
            }
        }
        
        if !foundStrengths.isEmpty {
            fields.detectedStrength = foundStrengths.joined(separator: " + ")
        }
        
        // 3. Extract candidate brand & salt tokens
        var candidateTokens: [String] = []
        let noiseWords: Set<String> = [
            "tablets", "tablet", "capsules", "capsule", "syrup", "ip", "usp", "bp",
            "mfg", "exp", "expiry", "date", "batch", "no", "mrp", "rs", "inr",
            "contains", "each", "coated", "film", "uncoated", "protect", "light",
            "moisture", "dosage", "directed", "physician", "keep", "out", "reach",
            "children", "storage", "store", "below", "manufactured", "india", "by",
            "ltd", "limited", "pvt", "pharma", "laboratories", "healthcare"
        ]
        
        for line in lines {
            let words = line.components(separatedBy: CharacterSet.alphanumerics.inverted)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { $0.count > 2 }
            
            for word in words {
                let lower = word.lowercased()
                if !noiseWords.contains(lower) && !lower.allSatisfy({ $0.isNumber }) {
                    candidateTokens.append(word)
                }
            }
        }
        
        if let firstWord = candidateTokens.first {
            fields.detectedBrand = firstWord
        }
        
        // Candidate salts
        fields.detectedSalts = Array(candidateTokens.dropFirst().prefix(4))
        
        // Calculate extraction confidence
        var confidenceScore = 0.5
        if fields.detectedBarcode != nil { confidenceScore += 0.4 }
        if fields.detectedExpiryDate != nil { confidenceScore += 0.2 }
        if fields.detectedStrength != nil { confidenceScore += 0.2 }
        if fields.detectedBrand != nil { confidenceScore += 0.1 }
        fields.confidence = min(1.0, confidenceScore)
        
        return fields
    }
}
