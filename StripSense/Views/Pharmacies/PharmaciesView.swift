//
//  PharmaciesView.swift
//  StripSense
//

import SwiftUI
import MapKit

public struct PharmaciesView: View {
    public var targetDrug: Drug?
    
    @StateObject private var pharmacyService = PharmacyService.shared
    @State private var areaQuery: String = ""
    @State private var showOnlyJanAushadhi: Bool = false
    @State private var selectedPharmacy: Pharmacy?
    @State private var showMessageDraftSheet: Bool = false
    @State private var messageDraftText: String = ""
    @State private var showCallConfirmation: Bool = false
    @State private var callingPhone: String = ""
    
    // Map camera position
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: PharmacyService.defaultCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )
    
    public init(targetDrug: Drug? = nil) {
        self.targetDrug = targetDrug
    }
    
    private var filteredPharmacies: [Pharmacy] {
        if showOnlyJanAushadhi {
            return pharmacyService.pharmacies.filter { $0.isJanAushadhi }
        }
        return pharmacyService.pharmacies
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Area Search & Layer Filter
            VStack(spacing: 10) {
                HStack {
                    SearchBarView(text: $areaQuery, placeholder: "Search area (e.g. Dadar, Indiranagar)...")
                    
                    Button(action: {
                        if !areaQuery.isEmpty {
                            pharmacyService.searchByArea(areaQuery: areaQuery)
                        } else {
                            pharmacyService.requestLocationPermission()
                        }
                    }) {
                        Image(systemName: "location.fill")
                            .font(.body)
                            .frame(width: 44, height: 44)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .accessibilityLabel("Use current location or search area")
                }
                
                // Jan Aushadhi Filter Pill
                HStack {
                    Toggle(isOn: $showOnlyJanAushadhi) {
                        HStack(spacing: 6) {
                            Image(systemName: "cross.fill")
                                .foregroundColor(.green)
                            Text("Jan Aushadhi Generic Stores Only")
                                .font(.footnote.weight(.semibold))
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .green))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(UIColor.systemBackground))
            
            // MapKit Interactive Map
            Map(position: $cameraPosition) {
                // User Location
                if let userLoc = pharmacyService.userLocation {
                    Annotation("You", coordinate: userLoc) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 14, height: 14)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }
                }
                
                // Pharmacy Pins
                ForEach(filteredPharmacies) { pharmacy in
                    Annotation(pharmacy.name, coordinate: pharmacy.coordinate) {
                        Button(action: { selectedPharmacy = pharmacy }) {
                            VStack(spacing: 2) {
                                Image(systemName: pharmacy.isJanAushadhi ? "cross.circle.fill" : "cross.case.fill")
                                    .font(.title2)
                                    .foregroundColor(pharmacy.isJanAushadhi ? .green : .blue)
                                    .background(Color.white.clipShape(Circle()))
                            }
                        }
                    }
                }
            }
            .frame(height: 220)
            
            // Error banner if any
            if let error = pharmacyService.searchError {
                HStack {
                    Image(systemName: "exclamationmark.circle")
                    Text(error)
                        .font(.caption)
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
                .background(Color.orange.opacity(0.15))
                .foregroundColor(.orange)
            }
            
            // Pharmacy List
            List {
                Section(header: HStack {
                    Text("Nearby Chemists (\(filteredPharmacies.count))")
                        .font(.caption.weight(.bold))
                    Spacer()
                    if pharmacyService.isSearching {
                        ProgressView()
                            .scaleEffect(0.7)
                    }
                }) {
                    ForEach(filteredPharmacies) { pharmacy in
                        PharmacyRowView(
                            pharmacy: pharmacy,
                            targetDrug: targetDrug,
                            onCall: {
                                if let phone = pharmacy.phone {
                                    callingPhone = phone
                                    showCallConfirmation = true
                                }
                            },
                            onMessage: {
                                selectedPharmacy = pharmacy
                                if let drug = targetDrug {
                                    messageDraftText = pharmacyService.inquiryMessageDraft(for: drug)
                                } else {
                                    messageDraftText = "Hello, do you have my prescribed medicine in stock?"
                                }
                                showMessageDraftSheet = true
                            }
                        )
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .listStyle(.plain)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Nearby Pharmacies")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let userLoc = pharmacyService.userLocation {
                cameraPosition = .region(MKCoordinateRegion(center: userLoc, span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)))
            }
        }
        .confirmationDialog("Call Pharmacy?", isPresented: $showCallConfirmation, titleVisibility: .visible) {
            Button("Call \(callingPhone)") {
                let clean = callingPhone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                if let url = URL(string: "tel://\(clean)"), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showMessageDraftSheet) {
            NavigationStack {
                VStack(spacing: 16) {
                    if let pharm = selectedPharmacy {
                        HStack {
                            Image(systemName: pharm.isJanAushadhi ? "cross.circle.fill" : "cross.case.fill")
                                .foregroundColor(pharm.isJanAushadhi ? .green : .blue)
                            Text(pharm.name)
                                .font(.headline)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    
                    Text("Prefilled inquiry message to check medicine availability:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    TextEditor(text: $messageDraftText)
                        .padding(10)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.2), lineWidth: 1))
                        .frame(height: 140)
                        .padding(.horizontal)
                    
                    // Share / Send via Messages or WhatsApp
                    HStack(spacing: 12) {
                        Button(action: {
                            UIPasteboard.general.string = messageDraftText
                            showMessageDraftSheet = false
                        }) {
                            HStack {
                                Image(systemName: "doc.on.doc")
                                Text("Copy Text")
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            let encoded = messageDraftText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                            if let url = URL(string: "whatsapp://send?text=\(encoded)"), UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            } else if let smsUrl = URL(string: "sms:&body=\(encoded)"), UIApplication.shared.canOpenURL(smsUrl) {
                                UIApplication.shared.open(smsUrl)
                            }
                            showMessageDraftSheet = false
                        }) {
                            HStack {
                                Image(systemName: "paperplane.fill")
                                Text("Send / Share")
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top, 20)
                .navigationTitle("Stock Inquiry")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showMessageDraftSheet = false }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
}
