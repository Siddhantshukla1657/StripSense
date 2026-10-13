//
//  ShelfItemRowView.swift
//  StripSense
//

import SwiftUI

public struct ShelfItemRowView: View {
    public let item: ShelfItem
    public var onEdit: () -> Void
    
    public init(item: ShelfItem, onEdit: @escaping () -> Void) {
        self.item = item
        self.onEdit = onEdit
    }
    
    public var body: some View {
        Button(action: onEdit) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.brand)
                            .font(.headline.weight(.bold))
                            .foregroundColor(.primary)
                        
                        Text("\(item.dosageForm) • \(item.strength)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    StatusBadgeView(status: item.expiryStatus)
                }
                
                Divider()
                
                HStack {
                    if let expiryDate = item.expiryDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption2)
                            Text("Expires: \(item.formattedExpiry)")
                                .font(.caption.weight(.medium))
                        }
                        .foregroundColor(.primary)
                    } else {
                        Text("No expiry recorded")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let batch = item.batchNumber, !batch.isEmpty {
                        Text("Batch: \(batch)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let note = item.note, !note.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "note.text")
                            .font(.caption2)
                        Text(note)
                            .font(.caption2)
                            .lineLimit(1)
                    }
                    .foregroundColor(.secondary)
                }
            }
            .padding(14)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(item.brand), \(item.strength), status \(item.expiryStatus.rawValue), expires \(item.formattedExpiry)")
    }
}
