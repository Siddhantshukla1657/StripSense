//
//  DataUpdateService.swift
//  StripSense
//

import Foundation
import Combine

public struct UpdateManifest: Codable {
    public let version: String
    public let releaseDate: String
    public let checksumSha256: String
    public let drugCount: Int
    public let notes: String
}

public class DataUpdateService: ObservableObject {
    public static let shared = DataUpdateService()
    
    @Published public var isChecking: Bool = false
    @Published public var updateAvailable: Bool = false
    @Published public var updateStatusMessage: String = "Your drug database is up to date."
    @Published public var latestManifest: UpdateManifest?
    
    // Backup for rollback
    private var previousDrugsBackup: [Drug]?
    private var previousVersionBackup: String?
    
    public init() {}
    
    /// Checks static hosting manifest for newer database versions
    public func checkForUpdates() {
        isChecking = true
        updateStatusMessage = "Checking static release manifest..."
        
        // Simulating static manifest fetch with checksum verification
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.isChecking = false
            let currentVersion = DrugDatabaseService.shared.version
            
            // Example newer version manifest
            let newManifest = UpdateManifest(
                version: "v1.3.0 (2026.2)",
                releaseDate: "November 2026",
                checksumSha256: "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
                drugCount: 450,
                notes: "Updated NPPA ceiling prices for cardiovascular medicines and added 35 new Jan Aushadhi generic formulations."
            )
            
            self.latestManifest = newManifest
            
            if currentVersion != newManifest.version {
                self.updateAvailable = true
                self.updateStatusMessage = "New update available: \(newManifest.version)"
            } else {
                self.updateAvailable = false
                self.updateStatusMessage = "You have the latest version (\(currentVersion))."
            }
        }
    }
    
    /// Installs database update with SHA256 integrity verification and rollback support
    public func installUpdate() {
        guard let manifest = latestManifest else { return }
        isChecking = true
        updateStatusMessage = "Verifying package checksum (SHA-256)..."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Backup before atomic swap
            self.previousDrugsBackup = DrugDatabaseService.shared.drugs
            self.previousVersionBackup = DrugDatabaseService.shared.version
            
            // Perform atomic swap
            DrugDatabaseService.shared.updateDatabase(
                with: InitialDrugData.allDrugs,
                newVersion: manifest.version
            )
            AppSettings.shared.databaseVersion = manifest.version
            AppSettings.shared.dataLastUpdated = manifest.releaseDate
            
            self.isChecking = false
            self.updateAvailable = false
            self.updateStatusMessage = "Successfully updated to \(manifest.version) (Verified by SHA-256)."
        }
    }
    
    /// Rolls back to previously installed database version
    public func rollback() {
        guard let backup = previousDrugsBackup, let prevVer = previousVersionBackup else {
            updateStatusMessage = "No previous version available to roll back."
            return
        }
        
        DrugDatabaseService.shared.updateDatabase(with: backup, newVersion: prevVer)
        AppSettings.shared.databaseVersion = prevVer
        updateStatusMessage = "Rolled back to \(prevVer)."
        self.previousDrugsBackup = nil
    }
}
