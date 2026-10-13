//
//  PharmacyRowView.swift
//  StripSense
//

import SwiftUI
import MapKit

public struct PharmacyRowView: View {
    public let pharmacy: Pharmacy
    public var targetDrug: Drug?
    public var onCall: () -> Void
    public var onMessage: () -> Void
    
    public init(pharmacy: Pharmacy, targetDrug: Drug? = nil, onCall: @escaping () -> Void, onMessage: @escaping () -> Void) {
        self.pharmacy = pharmacy
        self.targetDrug = targetDrug
        self.onCall = onCall
        self.onMessage = onMessage
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(pharmacy.name)
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.primary)
                        
                        if pharmacy.isJanAushadhi {
                            Text("Jan Aushadhi")
                                .font(.caption2.weight(.bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.18))
                                .foregroundColor(Color(red: 0.08, green: 0.50, blue: 0.24))
                                .cornerRadius(6)
                        }
                    }
                    
                    Text(pharmacy.address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                if !pharmacy.formattedDistance.isEmpty {
                    Text(pharmacy.formattedDistance)
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .clipShape(Capsule())
                }
            }
            
            Divider()
            
            // Actions: Call, Message, Directions
            HStack(spacing: 10) {
                // Call Action
                if let phone = pharmacy.phone, !phone.isEmpty {
                    Button(action: onCall) {
                        HStack(spacing: 6) {
                            Image(systemName: "phone.fill")
                            Text("Call")
                                .fontWeight(.semibold)
                        }
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(Color.green.opacity(0.15))
                        .foregroundColor(Color(red: 0.08, green: 0.50, blue: 0.24))
                        .cornerRadius(10)
                    }
                }
                
                // Message Stock Inquiry
                Button(action: onMessage) {
                    HStack(spacing: 6) {
                        Image(systemName: "message.fill")
                        Text("Inquire Stock")
                            .fontWeight(.semibold)
                    }
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(Color.blue.opacity(0.15))
                    .foregroundColor(.blue)
                    .cornerRadius(10)
                }
                
                // Apple Maps Directions
                Button(action: {
                    let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: pharmacy.coordinate))
                    mapItem.name = pharmacy.name
                    mapItem.openInMaps(launchOptions: [
                        MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
                    ])
                }) {
                    Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                        .font(.caption)
                        .frame(width: 38, height: 38)
                        .background(Color.secondary.opacity(0.15))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                }
                .accessibilityLabel("Get directions in Apple Maps")
            }
        }
        .padding(14)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}
