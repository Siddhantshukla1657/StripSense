//
//  ShelfView.swift
//  StripSense
//

import SwiftUI

public enum ShelfFilter: String, CaseIterable {
    case all = "All"
    case expiringSoon = "Expiring Soon"
    case expired = "Expired"
    case valid = "Valid"
}

public struct ShelfView: View {
    @StateObject private var shelfService = ShelfService.shared
    @StateObject private var notifService = NotificationService.shared
    
    @State private var selectedFilter: ShelfFilter = .all
    @State private var showAddItemSheet: Bool = false
    @State private var itemToEdit: ShelfItem?
    @State private var showUndoToast: Bool = false
    @State private var undoItemName: String = ""
    
    public init() {}
    
    private var filteredItems: [ShelfItem] {
        switch selectedFilter {
        case .all:
            return shelfService.items
        case .expiringSoon:
            return shelfService.items.filter { $0.expiryStatus == .expiringSoon }
        case .expired:
            return shelfService.items.filter { $0.expiryStatus == .expired }
        case .valid:
            return shelfService.items.filter { $0.expiryStatus == .ok }
        }
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Notification Alert Banner if permission not yet granted
                if !notifService.isPermissionGranted {
                    HStack(spacing: 10) {
                        Image(systemName: "bell.badge.fill")
                            .foregroundColor(.orange)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Enable Expiry Reminders")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.primary)
                            Text("Get timely notifications 30 & 7 days before strips expire.")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("Enable") {
                            notifService.requestPermission()
                        }
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding(12)
                    .background(Color.orange.opacity(0.12))
                }
                
                // Filter Segmented Control
                Picker("Filter", selection: $selectedFilter) {
                    Text("All (\(shelfService.items.count))").tag(ShelfFilter.all)
                    Text("Expiring (\(shelfService.expiringSoonCount))").tag(ShelfFilter.expiringSoon)
                    Text("Expired (\(shelfService.expiredCount))").tag(ShelfFilter.expired)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                
                // Main Shelf List
                if filteredItems.isEmpty {
                    VStack(spacing: 14) {
                        Image(systemName: "archivebox")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text(emptyStateTitle)
                            .font(.headline)
                        
                        Text(emptyStateDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                        
                        Button(action: { showAddItemSheet = true }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Medicine Strip")
                            }
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredItems) { item in
                            ShelfItemRowView(item: item) {
                                itemToEdit = item
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    undoItemName = item.brand
                                    shelfService.remove(byId: item.id)
                                    showUndoToast = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
                
                // Undo Toast
                if showUndoToast {
                    HStack {
                        Text("Removed '\(undoItemName)'")
                            .font(.footnote.weight(.medium))
                            .foregroundColor(.white)
                        Spacer()
                        Button("Undo") {
                            shelfService.undoLastDelete()
                            showUndoToast = false
                        }
                        .font(.footnote.weight(.bold))
                        .foregroundColor(.yellow)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.85))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("My Medicines")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showAddItemSheet = true }) {
                        Image(systemName: "plus")
                            .font(.body.weight(.bold))
                    }
                    .accessibilityLabel("Add medicine to shelf")
                }
            }
            .sheet(isPresented: $showAddItemSheet) {
                AddEditShelfItemView()
            }
            .sheet(item: $itemToEdit) { item in
                AddEditShelfItemView(itemToEdit: item)
            }
        }
    }
    
    private var emptyStateTitle: String {
        switch selectedFilter {
        case .all: return "Your Shelf is Empty"
        case .expiringSoon: return "No Medicines Expiring Soon"
        case .expired: return "No Expired Medicines"
        case .valid: return "No Valid Medicines"
        }
    }
    
    private var emptyStateDescription: String {
        switch selectedFilter {
        case .all:
            return "Scan a medicine strip or tap Add to track expiry dates and get alerts before medicines expire."
        case .expiringSoon:
            return "Great news! None of your tracked medicines are expiring in the next 30 days."
        case .expired:
            return "No expired medicines found in your cabinet."
        case .valid:
            return "Add medicines to keep track of their validity."
        }
    }
}
