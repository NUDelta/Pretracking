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
    public var accuracy: Double = kCLLocationAccuracyHundredMeters
    
    var latitude: Double?
    var longitude: Double?
    
    var loc_name: String?
    var locationDic: [String: [String: Any]] = [:]
    private var myLocation = CLLocation()
    private let locationManager = CLLocationManager()
    
    public func getDistance() -> Double? {
        return self.distance
    }
    
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
    
    public func setupParameters(distance: Double, latitude: Double, longitude: Double, radius: Double, accuracy: CLLocationAccuracy, name: String) {
        self.distance = distance
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
        myLocation = CLLocation(latitude: self.latitude!, longitude: self.longitude!)
        self.accuracy = accuracy
        self.loc_name = name
        locationManager.desiredAccuracy = self.accuracy
        self.locationDic[name] = ["distance": distance, "withinRegion": false, "notifiedForRegion": false]
        print("initialization")
        
    }
    
    public func clearAllMonitoredRegions() {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoringForRegion(region)
        }
    }
    
    public func initLocationManager() {
        print("init location manager here")
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if #available(iOS 9.0, *) {
            locationManager.allowsBackgroundLocationUpdates = true
        } else {
            // Fallback on earlier versions
        }
        
        clearAllMonitoredRegions()
        
        let center = CLLocationCoordinate2DMake(self.latitude!, self.longitude!)
        let monitoringRegion = CLCircularRegion.init(center: center, radius: 100, identifier: self.loc_name!)
        
//        locationManager.startMonitoringForRegion(monitoringRegion)
        locationManager.startUpdatingLocation()
    }
    
    public func addLocation(distance: Double, latitude: Double, longitude: Double, radius: Double, name: String) {
        let center = CLLocationCoordinate2DMake(latitude, longitude)
        let monitoringRegion = CLCircularRegion.init(center: center, radius: radius, identifier: name)
        locationManager.startMonitoringForRegion(monitoringRegion)
        self.locationDic[name] = ["distance": distance, "withinRegion": false, "notifiedForRegion": false]
    }
    
    public func removeLocation(name: String) {
        let monitoredRegion = locationManager.monitoredRegions
        for region in monitoredRegion {
            if name == region.identifier {
                locationManager.stopMonitoringForRegion(region)
                print("stopped monitoring \(name)")
            }
        }
        self.locationDic.removeValueForKey(name)
    }
    
    public func notifyPeople(region: CLRegion) {
        print("you are close to region \(region)")
    }
    
    public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        let age = -lastLocation.timestamp.timeIntervalSinceNow
        
        if (lastLocation.horizontalAccuracy < 0 || lastLocation.horizontalAccuracy > 65.0 || age > 20) {
            return
        }
        
        for region in locationManager.monitoredRegions {
            if let monitorRegion = region as? CLCircularRegion {
                let monitorLocation = CLLocation(latitude: monitorRegion.center.latitude, longitude: monitorRegion.center.longitude)
                
                let distanceToLocation = lastLocation.distanceFromLocation(monitorLocation)
                
                let currentLocationInfo = self.locationDic[monitorRegion.identifier]!
                let distance = currentLocationInfo["distance"] as! Double
                let hasBeenNotifiedForRegion = currentLocationInfo["notifiedForRegion"] as! Bool
                
                if (distanceToLocation <= distance && !hasBeenNotifiedForRegion) {
                    notifyPeople(monitorRegion)
                    self.locationDic[monitorRegion.identifier]!["notifiedForRegion"] = true
                }
            }

        }

    }
    
    public func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.description)
    }
    
    public func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationDic[region.identifier]!["withinRegion"] = true
        print("did enter region \(region.identifier)")
    }
    
    public func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("did exit region \(region.identifier)")
        self.locationDic[region.identifier]!["withinRegion"] = false
        self.locationDic[region.identifier]!["notifiedForRegion"] = false
        
        if outOfAllRegions() {
            locationManager.desiredAccuracy = self.accuracy
        }
    }
    
    private func outOfAllRegions() -> Bool {
        for (region, regionInfo) in self.locationDic {
            if regionInfo["withinRegion"] as! Bool{
                return false
            }
        }
        return true
    }
    
}