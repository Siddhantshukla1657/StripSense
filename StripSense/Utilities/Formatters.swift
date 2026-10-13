//
//  Formatters.swift
//  StripSense
//

import Foundation

public struct AppFormatters {
    public static let inrCurrency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₹"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()
    
    public static let monthYearDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter
    }()
    
    public static let fullDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    public static func formatINR(_ amount: Double) -> String {
        return inrCurrency.string(from: NSNumber(value: amount)) ?? String(format: "₹%.2f", amount)
    }
}
