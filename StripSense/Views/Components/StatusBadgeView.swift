//
//  StatusBadgeView.swift
//  StripSense
//

import SwiftUI

public struct StatusBadgeView: View {
    public let status: ExpiryStatus
    
    public init(status: ExpiryStatus) {
        self.status = status
    }
    
    public var body: some View {
        HStack(spacing: 5) {
            Image(systemName: status.iconName)
                .font(.caption.weight(.bold))
            Text(status.rawValue)
                .font(.caption.weight(.semibold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(backgroundColor.opacity(0.15))
        .foregroundColor(foregroundColor)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(foregroundColor.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var foregroundColor: Color {
        switch status {
        case .ok:
            return Color(red: 0.08, green: 0.50, blue: 0.24) // #15803D Forest Green
        case .expiringSoon:
            return Color(red: 0.71, green: 0.33, blue: 0.04) // #B45309 Amber
        case .expired:
            return Color(red: 0.73, green: 0.11, blue: 0.11) // #B91C1C Red
        case .unknown:
            return Color.secondary
        }
    }
    
    private var backgroundColor: Color {
        foregroundColor
    }
}
