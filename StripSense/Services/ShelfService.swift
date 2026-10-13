//
//  ShelfService.swift
//  StripSense
//

import Foundation
import Combine

public class ShelfService: ObservableObject {
    public static let shared = ShelfService()
    
    private let storageKey = "StripSense_Shelf_Items_v1"
    
    @Published public private(set) var items: [ShelfItem] = []
    
    // For undo delete support
    public var lastDeletedItem: (item: ShelfItem, index: Int)?
    
    public init() {
        loadItems()
    }
    
    /// Loads shelf items from local private on-device storage
    public func loadItems() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            // Preload 2 realistic household medicines for initial demonstration if empty
            let calpolExpiry = Calendar.current.date(byAdding: .day, value: 18, to: Date()) // expiring soon
            let doloExpiry = Calendar.current.date(byAdding: .month, value: 14, to: Date()) // valid
            
            let defaultItems = [
                ShelfItem(
                    drugId: 102,
                    brand: "Calpol 650",
                    dosageForm: "Tablet",
                    strength: "650 mg",
                    expiryDate: calpolExpiry,
                    batchNumber: "CP2024",
                    note: "For emergency fever"
                ),
                ShelfItem(
                    drugId: 101,
                    brand: "Dolo 650",
                    dosageForm: "Tablet",
                    strength: "650 mg",
                    expiryDate: doloExpiry,
                    batchNumber: "DL290",
                    note: "Cabinet top shelf"
                )
            ]
            self.items = defaultItems.sorted { ($0.expiryDate ?? .distantFuture) < ($1.expiryDate ?? .distantFuture) }
            saveItems()
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode([ShelfItem].self, from: data)
            self.items = decoded.sorted { ($0.expiryDate ?? .distantFuture) < ($1.expiryDate ?? .distantFuture) }
        } catch {
            print("Failed to decode shelf items: \(error)")
            self.items = []
        }
    }
    
    /// Saves current shelf items to on-device storage
    private func saveItems() {
        do {
            let data = try JSONEncoder().encode(items)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to save shelf items: \(error)")
        }
    }
    
    /// Checks if a drug already exists on the shelf
    public func existingItem(for drugId: Int) -> ShelfItem? {
        items.first { $0.drugId == drugId }
    }
    
    /// Adds a new shelf item or updates an existing one
    public func add(item: ShelfItem) {
        items.append(item)
        items.sort { ($0.expiryDate ?? .distantFuture) < ($1.expiryDate ?? .distantFuture) }
        saveItems()
        NotificationService.shared.scheduleExpiryReminders(for: item)
    }
    
    /// Updates an existing shelf item
    public func update(item: ShelfItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
            items.sort { ($0.expiryDate ?? .distantFuture) < ($1.expiryDate ?? .distantFuture) }
            saveItems()
            NotificationService.shared.scheduleExpiryReminders(for: item)
        }
    }
    
    /// Removes an item by ID and saves state for undo
    public func remove(byId id: UUID) {
        if let index = items.firstIndex(where: { $0.id == id }) {
            let removed = items.remove(at: index)
            lastDeletedItem = (removed, index)
            saveItems()
            NotificationService.shared.cancelExpiryReminders(for: removed)
        }
    }
    
    /// Restores the last deleted item
    public func undoLastDelete() {
        guard let last = lastDeletedItem else { return }
        let insertIndex = min(last.index, items.count)
        items.insert(last.item, at: insertIndex)
        items.sort { ($0.expiryDate ?? .distantFuture) < ($1.expiryDate ?? .distantFuture) }
        saveItems()
        NotificationService.shared.scheduleExpiryReminders(for: last.item)
        lastDeletedItem = nil
    }
    
    /// Total count of expiring soon or expired items
    public var alertCount: Int {
        items.filter { $0.expiryStatus == .expiringSoon || $0.expiryStatus == .expired }.count
    }
    
    public var expiringSoonCount: Int {
        items.filter { $0.expiryStatus == .expiringSoon }.count
    }
    
    public var expiredCount: Int {
        items.filter { $0.expiryStatus == .expired }.count
    }
}
