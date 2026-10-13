//
//  AppSettings.swift
//  StripSense
//

import Foundation
import Combine
import SwiftUI

public class AppSettings: ObservableObject {
    @AppStorage("isLargeTextEnabled") public var isLargeTextEnabled: Bool = false
    @AppStorage("isReadAloudAutoEnabled") public var isReadAloudAutoEnabled: Bool = false
    @AppStorage("speechRate") public var speechRate: Double = 0.5
    @AppStorage("remindDaysBefore30") public var remindDaysBefore30: Bool = true
    @AppStorage("remindDaysBefore7") public var remindDaysBefore7: Bool = true
    @AppStorage("remindOnExpiryDay") public var remindOnExpiryDay: Bool = true
    @AppStorage("showJanAushadhiLayer") public var showJanAushadhiLayer: Bool = true
    @AppStorage("databaseVersion") public var databaseVersion: String = "v1.2.0 (2026.1)"
    @AppStorage("dataLastUpdated") public var dataLastUpdated: String = "Oct 2026"
    
    public static let shared = AppSettings()
    
    public init() {}
}
