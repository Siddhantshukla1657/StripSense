//
//  SafetyFlag.swift
//  StripSense
//

import Foundation

public struct SafetyFlag: Codable, Hashable {
    public let reason: String
    public let source: String
    public let requiresDoctorConsultation: Bool
    
    public init(reason: String, source: String, requiresDoctorConsultation: Bool = true) {
        self.reason = reason
        self.source = source
        self.requiresDoctorConsultation = requiresDoctorConsultation
    }
}
