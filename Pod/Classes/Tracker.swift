//
//  Tracker.swift
//  Testing
//
//  Created by Yongsung on 1/26/16.
//  Copyright © 2016 Delta. All rights reserved.
//
import CoreLocation

public class Tracker: NSObject, CLLocationManagerDelegate {
    public var distance: Double = 20.0
    public var radius: Double = 200.0
    public var accuracy: Double = kCLLocationAccuracyNearestTenMeters
    public var currentTrackerAccuracy: Double = kCLLocationAccuracyNearestTenMeters
    
    var locationDic: [String: [String: Any]] = [:]
    let locationManager = CLLocationManager()
    
    required public override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.delegate = self
    }
    
    public class var sharedManager: Tracker {
        return Constants.sharedManager
    }
    
    private struct Constants {
        static let sharedManager = Tracker()
    }
    
    public func setupParameters(distance: Double?, radius: Double?, accuracy: CLLocationAccuracy?) {
        print("Setting up tracker parameters")
        
        if let unwrappedDistance = distance {
            self.distance = unwrappedDistance
        }
        if let unwrappedRadius = radius {
            self.radius = unwrappedRadius
        }
        if let unwrappedAccurary = accuracy {
            self.accuracy = unwrappedAccurary
            locationManager.desiredAccuracy = self.accuracy
            self.currentTrackerAccuracy = locationManager.desiredAccuracy
        }
    }
    
    public func clearAllMonitoredRegions() {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoringForRegion(region)
        }
    }
    
    public func initLocationManager() {
        print("Initializating location manager")
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if #available(iOS 9.0, *) {
            locationManager.allowsBackgroundLocationUpdates = true
        } else {
            // Fallback on earlier versions
        }
        
        clearAllMonitoredRegions()
        locationManager.startUpdatingLocation()
    }
    
    public func addLocation(distance: Double?, latitude: Double, longitude: Double, radius: Double?, name: String) {
        // check if optional distance and radius values are set
        var newLocationDistance: Double = self.distance
        if let unwrappedDistance = distance {
            newLocationDistance = unwrappedDistance
        }
        
        var newLocationRadius: Double = self.radius
        if let unwrappedRadius = radius {
            newLocationRadius = unwrappedRadius
        }
        
        // create and start monitoring new region
        let newRegionCenter = CLLocationCoordinate2DMake(latitude, longitude)
        let newRegionForMonitoring = CLCircularRegion.init(center: newRegionCenter, radius: newLocationRadius, identifier: name)
        
        locationManager.startMonitoringForRegion(newRegionForMonitoring)
        self.locationDic[name] = ["distance": newLocationDistance, "withinRegion": false, "notifiedForRegion": false]
    }
    
    public func removeLocation(name: String) {
        if self.locationDic.removeValueForKey(name) != nil {
            print("remove location exists")
            let monitoredRegion = locationManager.monitoredRegions
            
            for region in monitoredRegion {
                if name == region.identifier {
                    locationManager.stopMonitoringForRegion(region)
                    print("stopped monitoring \(name)")
                }
            }
        }
    }
    
    public func notifyPeople(region: CLRegion) {
        print("you are close to region \(region)")
    }
    
    public func notifyIfWithinDistance(lastLocation: CLLocation) {
        print("User position \(lastLocation), course \(lastLocation.course) and, elevation \(lastLocation.altitude)")
        
        // check if location update is recent and accurate enough
        let age = -lastLocation.timestamp.timeIntervalSinceNow
        if (lastLocation.horizontalAccuracy < 0 || lastLocation.horizontalAccuracy > 65.0 || age > 20) {
            return
        }
        
        // compute distance from current point to all monitored regions and notifiy if close enough
        for region in locationManager.monitoredRegions {
            if let monitorRegion = region as? CLCircularRegion {
                let monitorLocation = CLLocation(latitude: monitorRegion.center.latitude, longitude: monitorRegion.center.longitude)
                
                let distanceToLocation = lastLocation.distanceFromLocation(monitorLocation)
                
                if let currentLocationInfo = self.locationDic[monitorRegion.identifier] {
                    let distance = currentLocationInfo["distance"] as! Double
                    let hasBeenNotifiedForRegion = currentLocationInfo["notifiedForRegion"] as! Bool
                    
                    if (distanceToLocation <= distance && !hasBeenNotifiedForRegion) {
                        print(distanceToLocation)
                        self.locationDic[monitorRegion.identifier]?["notifiedForRegion"] = true
                        self.locationDic[monitorRegion.identifier]?["withinRegion"] = true
                        
                        notifyPeople(monitorRegion)
                    }
                }
            }
        }
    }
    
    public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        notifyIfWithinDistance(locations.last!)
    }
    
    public func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.description)
    }
    
    public func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("did enter region \(region.identifier)")
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.currentTrackerAccuracy = locationManager.desiredAccuracy
        self.locationDic[region.identifier]?["withinRegion"] = true
    }
    
    public func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("did exit region \(region.identifier)")
        self.locationDic[region.identifier]?["withinRegion"] = false
        self.locationDic[region.identifier]?["notifiedForRegion"] = false
        
        if outOfAllRegions() {
            locationManager.desiredAccuracy = self.accuracy
            self.currentTrackerAccuracy = locationManager.desiredAccuracy
        }
    }
    
    private func outOfAllRegions() -> Bool {
        print("checking all regions")
        for (_, regionInfo) in self.locationDic {
            if regionInfo["withinRegion"] as! Bool{
                return false
            }
        }
        return true
    }
}