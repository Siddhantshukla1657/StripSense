//
//  SettingsView.swift
//  StripSense
//

import SwiftUI

public struct SettingsView: View {
    @ObservedObject private var settings = AppSettings.shared
    @StateObject private var updateService = DataUpdateService.shared
    @StateObject private var dbService = DrugDatabaseService.shared
    @StateObject private var notifService = NotificationService.shared
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            Form {
                // Accessibility & Voice Section
                Section(header: Label("Accessibility & Voice", systemImage: "accessibility")) {
                    Toggle("Large Text Mode", isOn: $settings.isLargeTextEnabled)
                    
                    Toggle("Auto Read-Aloud on Scan", isOn: $settings.isReadAloudAutoEnabled)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Speech Rate")
                            Spacer()
                            Text(String(format: "%.1fx", settings.speechRate * 2.0))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $settings.speechRate, in: 0.25...0.75, step: 0.05)
                    }
                }
                
                // Expiry Reminder Schedule
                Section(header: Label("Expiry Reminders", systemImage: "bell")) {
                    Toggle("Remind 30 Days Before Expiry", isOn: $settings.remindDaysBefore30)
                    Toggle("Remind 7 Days Before Expiry", isOn: $settings.remindDaysBefore7)
                    Toggle("Remind on Expiry Day", isOn: $settings.remindOnExpiryDay)
                    
                    if !notifService.isPermissionGranted {
                        Button("Request Notification Permission") {
                            notifService.requestPermission()
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                // Offline Drug Database & Updates
                Section(header: Label("Drug Database & Updates", systemImage: "internaldrive")) {
                    HStack {
                        Text("Installed Version")
                        Spacer()
                        Text(settings.databaseVersion)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Total Formulations")
                        Spacer()
                        Text("\(dbService.drugs.count) Drugs")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Last Updated")
                        Spacer()
                        Text(settings.dataLastUpdated)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Button(action: {
                            updateService.checkForUpdates()
                        }) {
                            HStack {
                                if updateService.isChecking {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Verifying...")
                                } else {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text("Check for Database Updates")
                                }
                            }
                            .foregroundColor(.blue)
                        }
                        .disabled(updateService.isChecking)
                        
                        Text(updateService.updateStatusMessage)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    if updateService.updateAvailable {
                        Button(action: {
                            updateService.installUpdate()
                        }) {
                            HStack {
                                Image(systemName: "arrow.down.circle.fill")
                                Text("Install Verified Update (SHA-256)")
                            }
                            .foregroundColor(.green)
                            .fontWeight(.semibold)
                        }
                    }
                }
                
                // Data Sources & Transparency
                Section(header: Label("Data Sources & Licenses", systemImage: "doc.text")) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("National Pharmaceutical Pricing Authority (NPPA)")
                            .font(.subheadline.weight(.semibold))
                        Text("National List of Essential Medicines (NLEM 2024 Ceiling Price Schedule)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("PMBJP Jan Aushadhi Product List")
                            .font(.subheadline.weight(.semibold))
                        Text("Pharmaceuticals & Medical Devices Bureau of India (PMBI)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Licensing Terms")
                            .font(.subheadline.weight(.semibold))
                        Text("Open Government Data (OGD) Platform India - Free for Public Use")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 2)
                }
                
                // Privacy Guarantee
                Section(header: Label("Privacy Guarantee", systemImage: "lock.shield")) {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "hand.raised.fill")
                            .foregroundColor(.green)
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("100% On-Device & Private")
                                .font(.subheadline.weight(.bold))
                            Text("StripSense does not require accounts, does not collect analytics on medicines, and never transmits your scanned strip images to any remote server.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Legal Disclaimer Section
                Section {
                    DisclaimerBanner()
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Settings & About")
        }
    }
}
