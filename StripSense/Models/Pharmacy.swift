//
//  Pharmacy.swift
//  StripSense
//

import Foundation
import CoreLocation

public struct Pharmacy: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let coordinate: CLLocationCoordinate2D
    public let address: String
    public let phone: String?
    public var distanceMeters: Double?
    public let isJanAushadhi: Bool
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        coordinate: CLLocationCoordinate2D,
        address: String,
        phone: String? = nil,
        distanceMeters: Double? = nil,
        isJanAushadhi: Bool = false
    ) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
        self.address = address
        self.phone = phone
        self.distanceMeters = distanceMeters
        self.isJanAushadhi = isJanAushadhi
    }
    
    public var formattedDistance: String {
        guard let distance = distanceMeters else { return "" }
        if distance < 1000 {
            return String(format: "%.0f m away", distance)
        } else {
            return String(format: "%.1f km away", distance / 1000.0)
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Pharmacy, rhs: Pharmacy) -> Bool {
        lhs.id == rhs.id
    }
}
