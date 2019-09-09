//
//  Constants.swift
//  Chapter13
//
//  Created by frank.zhang on 2019/9/9.
//  Copyright © 2019 Frank. All rights reserved.
//

import CoreLocation

enum Constants {
    // The radius of the circle around the target you want to monitor, in meters
    static let geofencingRadius: Double = 300.0
    
    static let razeadBeacons: [CLBeaconRegion] = [
        // Change with your own beacon
        CLBeaconRegion(proximityUUID: UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, major: 21010, minor: 2255, identifier: "razead-mobile-kiosk")
    ]
    
    // REMINDER: Change this to a location near you!!, otherwise geofencing won't work, and beacon monitoring will never be enabled
    static let razewareMobileKioskLocation = Location(name: "Pisa", location: CLLocationCoordinate2D(latitude: 43.7153187, longitude: 10.4019739))
    //static let razewareMobileKioskLocation = Location(name: "Luszowice", location: CLLocationCoordinate2D(latitude: 50.1713779, longitude: 19.4051352))
    static let razewareMobileKioskIdentifier = "The Razeware Mobile Kiosk"
    
    struct Location {
        let name: String
        let location: CLLocationCoordinate2D
    }
}


