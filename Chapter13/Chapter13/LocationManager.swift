//
//  LocationManager.swift
//  Chapter13
//
//  Created by frank.zhang on 2019/8/29.
//  Copyright © 2019 Frank. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationManagerDelegate {
    func locationManager(_ locationManager: LocationManager, didEnterRegionId regionId: String)
    func locationManager(_ locationManager: LocationManager, didExitRegionId regionId: String)
    
    func locationManager(_ locationManager: LocationManager, didRangeBeacon beacon: CLBeacon)
    func locationManager(_ locationManager: LocationManager, didLeaveBeacon beacon: CLBeacon)
}

class LocationManager: NSObject {
    enum GeofencingError: Error {
        case notAuthorized
        case notSupported
    }
    
    var locationManager: CLLocationManager
    var delegate: LocationManagerDelegate?
    var trackedLocation: CLLocationCoordinate2D?
    
    override init() {
        locationManager = CLLocationManager()
        super.init()
    }
    
    func initialize() {
        locationManager.delegate = self
        locationManager.activityType = .otherNavigation
        
        // Geofencing requires always authorization
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func startMonitoring(location: CLLocationCoordinate2D, radius: Double, identifier: String) throws {
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else  { throw GeofencingError.notSupported }
        guard CLLocationManager.authorizationStatus() == .authorizedAlways else { throw GeofencingError.notAuthorized }
        
        trackedLocation = location
        
        let region = CLCircularRegion(center: location, radius: radius, identifier: identifier)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        
        locationManager.startMonitoring(for: region)
        
        // Delay state request by 1 second due to an old bug
        // http://www.openradar.me/16986842
        DispatchQueue.main.asyncAfter(deadline:  DispatchTime.now() + DispatchTimeInterval.seconds(1), qos: .default, flags: []) {
            self.locationManager.requestState(for: region)
        }
    }
    
    func stopMonitoringRegions() {
        trackedLocation = nil
        
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
    }
}

// MARK: - Beacons
extension LocationManager {
    func startMonitoring(beacons: [CLBeaconRegion]) {
        for beacon in beacons {
            startMonitoring(beacon: beacon)
        }
    }
    
    func startMonitoring(beacon: CLBeaconRegion) {
        guard CLLocationManager.isRangingAvailable() else {
            print("[ERROR] Beacon ranging is not available")
            return
        }
        
        locationManager.startMonitoring(for: beacon)
    }
    
    func stopMonitoring(beacons: [CLBeaconRegion]) {
        for beacon in beacons {
            stopMonitoring(beacon: beacon)
        }
    }
    
    func stopMonitoring(beacon: CLBeaconRegion) {
        locationManager.stopRangingBeacons(in: beacon)
        locationManager.stopMonitoring(for: beacon)
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    // MARK: Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        guard let trackedLocation = trackedLocation else { return }
        let location = CLLocation(latitude: trackedLocation.latitude, longitude: trackedLocation.longitude)
        let distance = currentLocation.distance(from: location)
        print("Distance: \(distance)")
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        print("Authorization status changed to: \(status)")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Geofencing monitoring failed for region \(String(describing: region?.identifier)), error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        switch state {
        case .inside:
            locationManager(manager, didEnterRegion: region)
            
        case .outside, .unknown:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let region = region as? CLBeaconRegion {
            print("Entered in beacon region: \(region)")
            locationManager.startRangingBeacons(in: region)
        } else {
            print("Entered in region: \(region)")
            delegate?.locationManager(self, didEnterRegionId: region.identifier)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Left region \(region)")
        delegate?.locationManager(self, didExitRegionId: region.identifier)
    }
    
    // MARK: Beacons
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        for beacon in beacons {
            delegate?.locationManager(self, didRangeBeacon: beacon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print("Beacon ranging failed for region \(region) with error: \(error.localizedDescription)")
    }
}
