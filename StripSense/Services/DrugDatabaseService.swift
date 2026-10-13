//
//  DrugDatabaseService.swift
//  StripSense
//

import Foundation
import Combine

public class DrugDatabaseService: ObservableObject {
    public static let shared = DrugDatabaseService()
    
    @Published public private(set) var drugs: [Drug] = []
    @Published public private(set) var version: String = "v1.2.0 (2026.1)"
    @Published public private(set) var lastUpdated: String = "October 2026"
    
    public init(drugs: [Drug] = InitialDrugData.allDrugs) {
        self.drugs = drugs
    }
    
    /// Finds a drug by exact database ID
    public func drug(byId id: Int) -> Drug? {
        drugs.first { $0.id == id }
    }
    
    /// Finds a drug by exact barcode (EAN-13, UPC, QR)
    public func drug(byBarcode barcode: String) -> Drug? {
        let clean = barcode.trimmingCharacters(in: .whitespacesAndNewlines)
        return drugs.first { $0.barcode == clean }
    }
    
    /// Search by query text across brand names and active salts
    public func search(query: String) -> [Drug] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return drugs }
        
        let normalizedQ = StringSimilarity.normalize(q)
        
        var scoredDrugs: [(Drug, Double)] = []
        
        for drug in drugs {
            let brandNorm = StringSimilarity.normalize(drug.brand)
            let saltsNorm = StringSimilarity.normalize(drug.saltsSummary)
            
            // Check direct contains
            if brandNorm.contains(normalizedQ) {
                scoredDrugs.append((drug, 1.0))
                continue
            }
            if saltsNorm.contains(normalizedQ) {
                scoredDrugs.append((drug, 0.9))
                continue
            }
            
            // Fuzzy brand similarity
            let brandSim = StringSimilarity.similarityRatio(normalizedQ, brandNorm)
            let tokenSim = StringSimilarity.tokenOverlapScore(query: normalizedQ, target: brandNorm)
            let maxSim = max(brandSim, tokenSim)
            
            if maxSim >= 0.5 {
                scoredDrugs.append((drug, maxSim))
            }
        }
        
        // Sort descending by match score
        return scoredDrugs.sorted { $0.1 > $1.1 }.map { $0.0 }
    }
    
    /// Replace database contents (for offline data updates)
    public func updateDatabase(with newDrugs: [Drug], newVersion: String) {
        self.drugs = newDrugs
        self.version = newVersion
        self.lastUpdated = AppFormatters.monthYearDate.string(from: Date())
    }
}
