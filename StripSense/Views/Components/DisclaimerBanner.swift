//
//  DisclaimerBanner.swift
//  StripSense
//

import SwiftUI

public struct DisclaimerBanner: View {
    public var customText: String?
    
    public init(customText: String? = nil) {
        self.customText = customText
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "hand.raised.fill")
                .foregroundColor(Color(red: 0.15, green: 0.39, blue: 0.92)) // Primary Blue
                .font(.body)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Not Medical Advice")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.primary)
                
                Text(customText ?? "StripSense is an informational tool. Always verify identified medicines, dosage, and brand substitutions with your doctor or licensed pharmacist.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.15, green: 0.39, blue: 0.92).opacity(0.08))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 0.15, green: 0.39, blue: 0.92).opacity(0.2), lineWidth: 1)
        )
    }
}
