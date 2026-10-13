//
//  ScanModels.swift
//  StripSense
//

import Foundation

public struct ScanResult: Hashable {
    public let rawText: String
    public let recognizedLines: [String]
    public let detectedBarcode: String?
    public let confidence: Double
    
    public init(
        rawText: String,
        recognizedLines: [String] = [],
        detectedBarcode: String? = nil,
        confidence: Double = 1.0
    ) {
        self.rawText = rawText
        self.recognizedLines = recognizedLines.isEmpty ? rawText.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty } : recognizedLines
        self.detectedBarcode = detectedBarcode
        self.confidence = confidence
    }
}

public struct ExtractedFields: Hashable {
    public var rawText: String
    public var detectedBrand: String?
    public var detectedSalts: [String]
    public var detectedStrength: String?
    public var detectedExpiryDate: Date?
    public var detectedExpiryString: String?
    public var detectedBatchNumber: String?
    public var detectedBarcode: String?
    public var confidence: Double
    
    public init(
        rawText: String = "",
        detectedBrand: String? = nil,
        detectedSalts: [String] = [],
        detectedStrength: String? = nil,
        detectedExpiryDate: Date? = nil,
        detectedExpiryString: String? = nil,
        detectedBatchNumber: String? = nil,
        detectedBarcode: String? = nil,
        confidence: Double = 0.8
    ) {
        self.rawText = rawText
        self.detectedBrand = detectedBrand
        self.detectedSalts = detectedSalts
        self.detectedStrength = detectedStrength
        self.detectedExpiryDate = detectedExpiryDate
        self.detectedExpiryString = detectedExpiryString
        self.detectedBatchNumber = detectedBatchNumber
        self.detectedBarcode = detectedBarcode
        self.confidence = confidence
    }
}

public struct Candidate: Identifiable, Hashable {
    public var id: Int { drug.id }
    public let drug: Drug
    public let score: Double            // 0.0 to 1.0
    public let matchReason: String      // e.g. "Exact Barcode Match", "Brand & Strength Match"
    public let isStrengthMatched: Bool
    
    public init(
        drug: Drug,
        score: Double,
        matchReason: String,
        isStrengthMatched: Bool
    ) {
        self.drug = drug
        self.score = score
        self.matchReason = matchReason
        self.isStrengthMatched = isStrengthMatched
    }
}

public struct SampleStrip: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let text: String
    public let barcode: String?
    
    public init(id: String, title: String, subtitle: String, text: String, barcode: String? = nil) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.text = text
        self.barcode = barcode
    }
}
