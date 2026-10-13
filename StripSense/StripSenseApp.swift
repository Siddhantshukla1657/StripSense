//
//  StripSenseApp.swift
//  StripSense
//
//  Created by KJSCE on 13/10/26.
//

import SwiftUI
import UserNotifications

@main
struct StripSenseApp: App {
    
    // Eagerly initialise shared singletons so notification observers are live
    @StateObject private var shelfService = ShelfService.shared
    @StateObject private var notifService = NotificationService.shared
    @StateObject private var pharmacyService = PharmacyService.shared
    @ObservedObject private var settings = AppSettings.shared
    
    init() {
        // Configure UNUserNotificationCenter delegate so
        // local expiry reminders open the shelf directly
        UNUserNotificationCenter.current().delegate = AppNotificationDelegate.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(shelfService)
                .environmentObject(notifService)
        }
    }
}

// MARK: - Notification Delegate (opens Shelf on tap)
final class AppNotificationDelegate: NSObject, UNUserNotificationCenterDelegate, @unchecked Sendable {
    static let shared = AppNotificationDelegate()
    
    // Show notifications even when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner, .badge, .sound]
    }
    
    // Handle tap on notification (routes to My Shelf tab)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        // Notification tap will bring app to foreground.
        // The identifier prefix "expiry_" is used to identify shelf notifications.
        let id = response.notification.request.identifier
        if id.hasPrefix("expiry_") {
            // Post an internal notification so ContentView can switch to the Shelf tab
            await MainActor.run {
                NotificationCenter.default.post(name: .openShelfTab, object: nil)
            }
        }
    }
}

extension Notification.Name {
    static let openShelfTab = Notification.Name("StripSense.openShelfTab")
}
