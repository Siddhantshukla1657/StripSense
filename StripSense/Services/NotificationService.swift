//
//  NotificationService.swift
//  StripSense
//

import Foundation
import Combine
import UserNotifications

public class NotificationService: ObservableObject {
    public static let shared = NotificationService()
    
    @Published public var isPermissionGranted: Bool = false
    
    public init() {
        checkPermission()
    }
    
    public func checkPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isPermissionGranted = (settings.authorizationStatus == .authorized)
            }
        }
    }
    
    public func requestPermission(completion: @escaping (Bool) -> Void = { _ in }) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isPermissionGranted = granted
                completion(granted)
            }
        }
    }
    
    /// Schedules reminders at 30 days, 7 days, and day of expiry
    public func scheduleExpiryReminders(for item: ShelfItem) {
        guard let expiryDate = item.expiryDate else { return }
        let now = Date()
        
        let settings = AppSettings.shared
        let reminders = [
            (daysBefore: 30, isEnabled: settings.remindDaysBefore30, title: "Medicine Expiring in 30 Days"),
            (daysBefore: 7, isEnabled: settings.remindDaysBefore7, title: "Medicine Expiring Next Week"),
            (daysBefore: 0, isEnabled: settings.remindOnExpiryDay, title: "⚠️ Medicine Has Expired")
        ]
        
        for reminder in reminders where reminder.isEnabled {
            guard let triggerDate = Calendar.current.date(byAdding: .day, value: -reminder.daysBefore, to: expiryDate),
                  triggerDate > now else {
                continue
            }
            
            let content = UNMutableNotificationContent()
            content.title = reminder.title
            content.body = "\(item.brand) (\(item.strength)) expires on \(item.formattedExpiry). Please inspect your strip."
            content.sound = .default
            
            let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour], from: triggerDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
            
            let identifier = "expiry_\(item.id.uuidString)_\(reminder.daysBefore)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to schedule notification: \(error)")
                }
            }
        }
    }
    
    /// Cancels scheduled reminders for an item
    public func cancelExpiryReminders(for item: ShelfItem) {
        let identifiers = [
            "expiry_\(item.id.uuidString)_30",
            "expiry_\(item.id.uuidString)_7",
            "expiry_\(item.id.uuidString)_0"
        ]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}
