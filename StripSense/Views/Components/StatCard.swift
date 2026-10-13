//
//  StatCard.swift
//  StripSense
//

import SwiftUI

public struct StatCard: View {
    public let title: String
    public let value: String
    public let icon: String
    public let color: Color
    public var subtitle: String?
    
    public init(title: String, value: String, icon: String, color: Color, subtitle: String? = nil) {
        self.title = title
        self.value = value
        self.icon = icon
        self.color = color
        self.subtitle = subtitle
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundColor(color)
                    .frame(width: 28, height: 28)
                    .background(color.opacity(0.15))
                    .clipShape(Circle())
                
                Spacer()
                
                Text(value)
                    .font(.title2.weight(.bold))
                    .foregroundColor(.primary)
            }
            
            Text(title)
                .font(.footnote.weight(.medium))
                .foregroundColor(.secondary)
            
            if let sub = subtitle {
                Text(sub)
                    .font(.caption2)
                    .foregroundColor(color)
            }
        }
        .padding(14)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}
