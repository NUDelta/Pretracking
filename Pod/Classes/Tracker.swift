//
//  Tracker.swift
//  Testing
//
//  Created by Yongsung on 1/26/16.
//  Copyright © 2016 Delta. All rights reserved.
//
import CoreLocation

public class Tracker: NSObject, CLLocationManagerDelegate{
    var distance: Double?
    var latitude: Double?
    var longitude: Double?
    var radius: Double?
    var accuracy: Double?
    private var myLocation = CLLocation()
    private let locationManager = CLLocationManager()
    
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
    
    public func setupParameters(distance: Double, latitude: Double, longitude: Double, radius: Double, accuracy: CLLocationAccuracy) {
        self.distance = distance
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
        myLocation = CLLocation(latitude: self.latitude!, longitude: self.longitude!)
        self.accuracy = accuracy
        locationManager.desiredAccuracy = self.accuracy!
        print("initialization")
        
    }
    
    public func initLocationManager() {
        print("init location manager here")
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        let center = CLLocationCoordinate2DMake(self.latitude!, self.longitude!)
        let monitoringRegion = CLCircularRegion.init(center: center, radius: 100, identifier: "tester")
        
        locationManager.startMonitoringForRegion(monitoringRegion)
        locationManager.startUpdatingLocation()
    }
    
    public func notifyPeople() {
        print("do your thing here")
    }
    
    public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        let age = -lastLocation.timestamp.timeIntervalSinceNow
        if (lastLocation.horizontalAccuracy < 0 || lastLocation.horizontalAccuracy > 65.0) {
            return
        }
        
        if (age > 20) {
            return
        }
        
        let distanceToLocation = lastLocation.distanceFromLocation(myLocation)
        print("distance is \(distanceToLocation)")
        if (distanceToLocation <= self.distance) {
            notifyPeople()
        }
    }
    
    public func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.description)
    }
    
    public func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        print("did enter region")
    }
    
    public func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        locationManager.desiredAccuracy = self.accuracy!
        print("did exit region")
    }
    
}