//
//  DrugSalt.swift
//  StripSense
//

import Foundation

public struct DrugSalt: Identifiable, Codable, Hashable {
    public var id: String { "\(name.lowercased())_\(strength.lowercased())" }
    public let name: String
    public let strength: String
    
    public init(name: String, strength: String) {
        self.name = name
        self.strength = strength
    }
}
