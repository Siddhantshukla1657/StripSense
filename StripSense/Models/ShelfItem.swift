//
//  ShelfItem.swift
//  StripSense
//

import Foundation

public enum ExpiryStatus: String, Codable, CaseIterable {
    case ok = "Valid"
    case expiringSoon = "Expiring Soon"
    case expired = "Expired"
    case unknown = "No Expiry Recorded"
    
    public var iconName: String {
        switch self {
        case .ok:
            return "checkmark.circle.fill"
        case .expiringSoon:
            return "clock.badge.exclamationmark.fill"
        case .expired:
            return "exclamationmark.triangle.fill"
        case .unknown:
            return "questionmark.circle.fill"
        }
    }
}

public struct ShelfItem: Identifiable, Codable, Hashable {
    public let id: UUID
    public let drugId: Int
    public let brand: String
    public let dosageForm: String
    public let strength: String
    public var expiryDate: Date?
    public var batchNumber: String?
    public var note: String?
    public let addedAt: Date
    
    public init(
        id: UUID = UUID(),
        drugId: Int,
        brand: String,
        dosageForm: String,
        strength: String,
        expiryDate: Date?,
        batchNumber: String? = nil,
        note: String? = nil,
        addedAt: Date = Date()
    ) {
        self.id = id
        self.drugId = drugId
        self.brand = brand
        self.dosageForm = dosageForm
        self.strength = strength
        self.expiryDate = expiryDate
        self.batchNumber = batchNumber
        self.note = note
        self.addedAt = addedAt
    }
    
    public var expiryStatus: ExpiryStatus {
        guard let expiryDate = expiryDate else {
            return .unknown
        }
        let now = Date()
        if expiryDate < now {
            return .expired
        }
        // 30 days window in seconds = 30 * 86400
        let thirtyDaysFromNow = Calendar.current.date(byAdding: .day, value: 30, to: now) ?? now
        if expiryDate <= thirtyDaysFromNow {
            return .expiringSoon
        }
        return .ok
    }
    
    public var daysUntilExpiry: Int? {
        guard let expiryDate = expiryDate else { return nil }
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfExpiry = calendar.startOfDay(for: expiryDate)
        let components = calendar.dateComponents([.day], from: startOfToday, to: startOfExpiry)
        return components.day
    }
    
    public var formattedExpiry: String {
        guard let expiryDate = expiryDate else { return "None" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: expiryDate)
    }
}
