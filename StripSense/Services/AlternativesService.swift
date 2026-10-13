//
//  AlternativesService.swift
//  StripSense
//

import Foundation

public struct AlternativeItem: Identifiable, Hashable {
    public var id: Int { drug.id }
    public let drug: Drug
    public let savingsINR: Double
    public let savingsPercentage: Double
    public let isCheaper: Bool
    
    public init(drug: Drug, referenceMRP: Double) {
        self.drug = drug
        if referenceMRP > 0 && drug.mrp < referenceMRP {
            self.savingsINR = referenceMRP - drug.mrp
            self.savingsPercentage = ((referenceMRP - drug.mrp) / referenceMRP) * 100.0
            self.isCheaper = true
        } else {
            self.savingsINR = 0
            self.savingsPercentage = 0
            self.isCheaper = false
        }
    }
}

public struct AlternativesResult {
    public let referenceDrug: Drug
    public let isSafetyBlocked: Bool
    public let safetyMessage: String?
    public let alternatives: [AlternativeItem]
    public let disclaimer: String
    
    public init(
        referenceDrug: Drug,
        isSafetyBlocked: Bool,
        safetyMessage: String?,
        alternatives: [AlternativeItem],
        disclaimer: String = "Always confirm with your doctor or licensed pharmacist before substituting any brand. Bioequivalence and inactive ingredients may vary."
    ) {
        self.referenceDrug = referenceDrug
        self.isSafetyBlocked = isSafetyBlocked
        self.safetyMessage = safetyMessage
        self.alternatives = alternatives
        self.disclaimer = disclaimer
    }
}

public class AlternativesService {
    private let database: DrugDatabaseService
    
    public init(database: DrugDatabaseService = .shared) {
        self.database = database
    }
    
    /// Finds strict same-salt, same-strength, same-dosage-form generic alternatives
    public func alternatives(for target: Drug) -> AlternativesResult {
        // 1. Check safety flag first (e.g., Narrow Therapeutic Index)
        if let safetyFlag = target.safetyFlag, safetyFlag.requiresDoctorConsultation {
            return AlternativesResult(
                referenceDrug: target,
                isSafetyBlocked: true,
                safetyMessage: "DO NOT SWITCH BRANDS WITHOUT ASKING YOUR DOCTOR.\n\n\(safetyFlag.reason)\n\nSource: \(safetyFlag.source)",
                alternatives: []
            )
        }
        
        let targetForm = StringSimilarity.normalize(target.dosageForm)
        let targetSalts = target.salts
        
        var matches: [AlternativeItem] = []
        
        for candidate in database.drugs where candidate.id != target.id {
            // Check dosage form
            let candidateForm = StringSimilarity.normalize(candidate.dosageForm)
            guard candidateForm == targetForm else { continue }
            
            // Check exact salt count
            guard candidate.salts.count == targetSalts.count else { continue }
            
            // Check that every salt and strength matches exactly
            var allSaltsMatch = true
            for tSalt in targetSalts {
                let tName = StringSimilarity.normalize(tSalt.name)
                let tStr = StringSimilarity.normalize(tSalt.strength)
                
                let foundMatch = candidate.salts.contains { cSalt in
                    let cName = StringSimilarity.normalize(cSalt.name)
                    let cStr = StringSimilarity.normalize(cSalt.strength)
                    return cName == tName && cStr == tStr
                }
                
                if !foundMatch {
                    allSaltsMatch = false
                    break
                }
            }
            
            if allSaltsMatch {
                let item = AlternativeItem(drug: candidate, referenceMRP: target.mrp)
                matches.append(item)
            }
        }
        
        // Sort: cheaper first (lowest MRP first)
        let sortedAlternatives = matches.sorted { $0.drug.mrp < $1.drug.mrp }
        
        return AlternativesResult(
            referenceDrug: target,
            isSafetyBlocked: false,
            safetyMessage: nil,
            alternatives: sortedAlternatives
        )
    }
}
