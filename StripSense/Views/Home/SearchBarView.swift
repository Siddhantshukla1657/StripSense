//
//  SearchBarView.swift
//  StripSense
//

import SwiftUI

public struct SearchBarView: View {
    @Binding public var text: String
    public var placeholder: String = "Search brand or salt (e.g. Dolo, Metformin)..."
    
    public init(text: Binding<String>, placeholder: String = "Search brand or salt (e.g. Dolo, Metformin)...") {
        self._text = text
        self.placeholder = placeholder
    }
    
    public var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.body)
            
            TextField(placeholder, text: $text)
                .font(.body)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.body)
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
        )
    }
}
