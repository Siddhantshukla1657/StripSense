//
//  JanAushadhiData.swift
//  StripSense
//

import Foundation
import CoreLocation

public struct JanAushadhiData {
    public static let sampleStores: [Pharmacy] = [
        Pharmacy(
            id: "pmbjp_101",
            name: "Pradhan Mantri Jan Aushadhi Kendra - KEM Hospital",
            coordinate: CLLocationCoordinate2D(latitude: 18.9996, longitude: 72.8428),
            address: "Near Gate 2, KEM Hospital, Parel, Mumbai, Maharashtra 400012",
            phone: "+91 22 2410 7000",
            distanceMeters: 450,
            isJanAushadhi: true
        ),
        Pharmacy(
            id: "pmbjp_102",
            name: "Jan Aushadhi Kendra - Dadar Station",
            coordinate: CLLocationCoordinate2D(latitude: 19.0178, longitude: 72.8478),
            address: "Shop 4, Station Road, Dadar West, Mumbai, Maharashtra 400028",
            phone: "+91 98201 12345",
            distanceMeters: 1200,
            isJanAushadhi: true
        ),
        Pharmacy(
            id: "pmbjp_103",
            name: "Pradhan Mantri Jan Aushadhi Kendra - AIIMS",
            coordinate: CLLocationCoordinate2D(latitude: 28.5672, longitude: 77.2100),
            address: "Ansari Nagar, Near OPD Gate, New Delhi 110029",
            phone: "+91 11 2658 8500",
            distanceMeters: 800,
            isJanAushadhi: true
        ),
        Pharmacy(
            id: "pmbjp_104",
            name: "PMBJP Jan Aushadhi Store - Indiranagar",
            coordinate: CLLocationCoordinate2D(latitude: 12.9784, longitude: 77.6408),
            address: "100 Feet Rd, HAL 2nd Stage, Indiranagar, Bengaluru, Karnataka 560038",
            phone: "+91 80 2521 9988",
            distanceMeters: 1500,
            isJanAushadhi: true
        ),
        Pharmacy(
            id: "pmbjp_105",
            name: "Jan Aushadhi Kendra - FC Road",
            coordinate: CLLocationCoordinate2D(latitude: 18.5204, longitude: 73.8420),
            address: "Opp Fergusson College, Shivajinagar, Pune, Maharashtra 411004",
            phone: "+91 20 2553 4411",
            distanceMeters: 950,
            isJanAushadhi: true
        ),
        Pharmacy(
            id: "apollo_201",
            name: "Apollo Pharmacy 24/7",
            coordinate: CLLocationCoordinate2D(latitude: 19.0020, longitude: 72.8415),
            address: "Dr. B. Ambedkar Road, Parel, Mumbai 400012",
            phone: "+91 22 2415 6789",
            distanceMeters: 620,
            isJanAushadhi: false
        ),
        Pharmacy(
            id: "wellness_202",
            name: "Wellness Forever Chemist",
            coordinate: CLLocationCoordinate2D(latitude: 19.0150, longitude: 72.8450),
            address: "Gokhale Road North, Dadar, Mumbai 400028",
            phone: "+91 22 2430 9876",
            distanceMeters: 1100,
            isJanAushadhi: false
        ),
        Pharmacy(
            id: "medplus_203",
            name: "MedPlus Pharmacy",
            coordinate: CLLocationCoordinate2D(latitude: 19.0055, longitude: 72.8390),
            address: "Elphinstone Bridge Rd, Lower Parel, Mumbai 400013",
            phone: "+91 22 2492 5544",
            distanceMeters: 1400,
            isJanAushadhi: false
        )
    ]
}
