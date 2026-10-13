//
//  Drug.swift
//  StripSense
//

import Foundation

public struct Drug: Identifiable, Codable, Hashable {
    public let id: Int
    public let brand: String
    public let manufacturer: String
    public let dosageForm: String       // e.g. "Tablet", "Capsule", "Syrup"
    public let packSize: String         // e.g. "10 Tablets", "15 Tablets", "100 ml"
    public let mrp: Double              // Indian Rupees (₹)
    public let source: String           // e.g. "NPPA/NLEM 2024", "PMBJP Jan Aushadhi"
    public let license: String          // e.g. "Government Open Data License - India"
    public let barcode: String?         // EAN-13, UPC or QR code payload
    public let salts: [DrugSalt]
    public let safetyFlag: SafetyFlag?
    public let isJanAushadhi: Bool
    
    public init(
        id: Int,
        brand: String,
        manufacturer: String,
        dosageForm: String,
        packSize: String,
        mrp: Double,
        source: String,
        license: String = "Open Government Data (OGD) Platform India",
        barcode: String? = nil,
        salts: [DrugSalt],
        safetyFlag: SafetyFlag? = nil,
        isJanAushadhi: Bool = false
    ) {
        self.id = id
        self.brand = brand
        self.manufacturer = manufacturer
        self.dosageForm = dosageForm
        self.packSize = packSize
        self.mrp = mrp
        self.source = source
        self.license = license
        self.barcode = barcode
        self.salts = salts
        self.safetyFlag = safetyFlag
        self.isJanAushadhi = isJanAushadhi
    }
    
    /// Returns formatted comma-separated salt names and strengths
    public var saltsSummary: String {
        salts.map { "\($0.name) (\($0.strength))" }.joined(separator: " + ")
    }
    
    /// Returns primary strength summary
    public var strengthSummary: String {
        salts.map { $0.strength }.joined(separator: " + ")
    }
    
    /// Returns formatted price in INR
    public var formattedPrice: String {
        mrp > 0 ? String(format: "₹%.2f", mrp) : "Price not available"
    }
}
