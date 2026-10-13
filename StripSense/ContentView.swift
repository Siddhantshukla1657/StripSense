//
//  ContentView.swift
//  StripSense
//
//  Created by KJSCE on 13/10/26.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var settings = AppSettings.shared
    @StateObject private var shelfService = ShelfService.shared
    
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "viewfinder")
                }
                .tag(0)
            
            PharmaciesView()
                .tabItem {
                    Label("Pharmacies", systemImage: "map.fill")
                }
                .tag(1)
            
            ShelfView()
                .tabItem {
                    Label("My Shelf", systemImage: "archivebox.fill")
                }
                .badge(shelfService.alertCount > 0 ? "\(shelfService.alertCount)" : nil)
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .tint(Color(red: 0.15, green: 0.39, blue: 0.92)) // StripSense Medical Blue
        .environment(\.sizeCategory, settings.isLargeTextEnabled ? .accessibilityExtraLarge : .large)
        // Deep-link: notification tap opens My Shelf tab
        .onReceive(NotificationCenter.default.publisher(for: .openShelfTab)) { _ in
            selectedTab = 2
        }
    }
}

#Preview {
    ContentView()
}
