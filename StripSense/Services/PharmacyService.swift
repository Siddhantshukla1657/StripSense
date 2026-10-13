//
//  PharmacyService.swift
//  StripSense
//

import Foundation
import MapKit
import CoreLocation

public class PharmacyService: NSObject, ObservableObject, CLLocationManagerDelegate {
    public static let shared = PharmacyService()
    
    private let locationManager = CLLocationManager()
    
    @Published public var userLocation: CLLocationCoordinate2D?
    @Published public var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published public var pharmacies: [Pharmacy] = []
    @Published public var isSearching: Bool = false
    @Published public var searchError: String?
    
    // Default fallback coordinate (Parel, Mumbai medical hub)
    public static let defaultCoordinate = CLLocationCoordinate2D(latitude: 18.9996, longitude: 72.8428)
    
    public override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authorizationStatus = locationManager.authorizationStatus
        
        // Initialize with bundled sample stores
        self.pharmacies = JanAushadhiData.sampleStores
        sortPharmaciesByDistance(from: PharmacyService.defaultCoordinate)
    }
    
    public func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.userLocation = location.coordinate
        searchNearbyPharmacies(at: location.coordinate)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
        if userLocation == nil {
            searchNearbyPharmacies(at: PharmacyService.defaultCoordinate)
        }
    }
    
    /// Searches nearby pharmacies using MKLocalSearch around coordinate
    public func searchNearbyPharmacies(at coordinate: CLLocationCoordinate2D) {
        isSearching = true
        searchError = nil
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Pharmacy"
        request.region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 5000,
            longitudinalMeters: 5000
        )
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isSearching = false
                
                var results: [Pharmacy] = []
                
                // Add bundled Jan Aushadhi generic stores
                results.append(contentsOf: JanAushadhiData.sampleStores.filter { $0.isJanAushadhi })
                
                if let mapItems = response?.mapItems, !mapItems.isEmpty {
                    for item in mapItems {
                        let loc = item.placemark.coordinate
                        let pharmacy = Pharmacy(
                            id: "mk_\(item.name ?? "Pharmacy")_\(loc.latitude)",
                            name: item.name ?? "Local Pharmacy",
                            coordinate: loc,
                            address: item.placemark.title ?? "Nearby Chemist",
                            phone: item.phoneNumber,
                            distanceMeters: nil,
                            isJanAushadhi: false
                        )
                        if !results.contains(where: { $0.name == pharmacy.name }) {
                            results.append(pharmacy)
                        }
                    }
                } else {
                    // Fallback to sample stores
                    for store in JanAushadhiData.sampleStores where !store.isJanAushadhi {
                        results.append(store)
                    }
                }
                
                self.pharmacies = results
                self.sortPharmaciesByDistance(from: coordinate)
            }
        }
    }
    
    /// Searches pharmacies in a typed area string (fallback when GPS is disabled)
    public func searchByArea(areaQuery: String) {
        isSearching = true
        searchError = nil
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(areaQuery) { [weak self] placemarks, error in
            guard let self = self else { return }
            if let targetCoord = placemarks?.first?.location?.coordinate {
                self.userLocation = targetCoord
                self.searchNearbyPharmacies(at: targetCoord)
            } else {
                DispatchQueue.main.async {
                    self.isSearching = false
                    self.searchError = "Could not locate '\(areaQuery)'. Showing local results."
                    self.sortPharmaciesByDistance(from: PharmacyService.defaultCoordinate)
                }
            }
        }
    }
    
    private func sortPharmaciesByDistance(from origin: CLLocationCoordinate2D) {
        let originLoc = CLLocation(latitude: origin.latitude, longitude: origin.longitude)
        
        for i in 0..<pharmacies.count {
            let storeLoc = CLLocation(latitude: pharmacies[i].coordinate.latitude, longitude: pharmacies[i].coordinate.longitude)
            pharmacies[i].distanceMeters = originLoc.distance(from: storeLoc)
        }
        
        pharmacies.sort { ($0.distanceMeters ?? .infinity) < ($1.distanceMeters ?? .infinity) }
    }
    
    /// Formats a pre-filled inquiry message draft for a pharmacy
    public func inquiryMessageDraft(for drug: Drug) -> String {
        return "Hello, do you currently have '\(drug.brand) \(drug.strengthSummary) (\(drug.dosageForm))' in stock? Thank you."
    }
}
