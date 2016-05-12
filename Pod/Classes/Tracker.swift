//
//  Tracker.swift
//  Testing
//
//  Created by Yongsung on 1/26/16.
//  Copyright © 2016 Delta. All rights reserved.
//
import Foundation
import CoreLocation
import AVFoundation

public class Tracker: NSObject, CLLocationManagerDelegate {
    public var distance: Double = 20.0
    public var radius: Double = 125.0
    public var accuracy: Double = kCLLocationAccuracyNearestTenMeters
    public var distanceFilter: Double = -1.0
    
    var locationDic: [String: [String: Any]] = [:]
    let locationManager = CLLocationManager()
    
    var player = AVAudioPlayer()
    var isPlaying: Bool = false
    
    // MARK: Initializations, getters, and setters
    required public override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
    
    public class var sharedManager: Tracker {
        return Constants.sharedManager
    }
    
    private struct Constants {
        static let sharedManager = Tracker()
    }
    
    public func getCurrentAccurary() -> Double {
        return locationManager.desiredAccuracy
    }
    
    public func getLocation() -> CLLocation {
        return locationManager.location!
    }
    
    public func setupParameters(distance: Double?, radius: Double?, accuracy: CLLocationAccuracy?, distanceFilter: Double?) {
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
        }
        if let unwrappedDistanceFilter = distanceFilter {
            self.distanceFilter = unwrappedDistanceFilter
            locationManager.distanceFilter = self.distanceFilter
        }
    }
    
    public func clearAllMonitoredRegions() {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoringForRegion(region)
        }
    }
    
    public func initLocationManager() {
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if #available(iOS 9.0, *) {
            locationManager.allowsBackgroundLocationUpdates = true
        } else {
            // on all other versions, slient audio will be played
        }
        
        clearAllMonitoredRegions()
        
        locationManager.startUpdatingLocation()
        
        // print debug string with all location manager parameters
        let locActivity = locationManager.activityType == .Other
        let locAccuracy = locationManager.desiredAccuracy
        let locDistance = locationManager.distanceFilter
        let locationManagerParametersDebugString = "Manager Activity = \(locActivity)\n" +
            "Manager Accuracy = \(locAccuracy)\n" +
            "Manager Distance Filter = \(locDistance)\n"
        
        let authStatus = CLLocationManager.authorizationStatus() == .AuthorizedAlways
        let locServicesEnabled = CLLocationManager.locationServicesEnabled()
        let locSigChangeAvailable = CLLocationManager.significantLocationChangeMonitoringAvailable()
        let locationManagerPermissionsDebugString = "Location manager setup with following parameters:\n" +
            "Authorization = \(authStatus)\n" +
            "Location Services Enabled = \(locServicesEnabled)\n" +
            "Significant Location Change Enabled = \(locSigChangeAvailable)\n"
        
        print("Initialized Location Manager Information:\n" + locationManagerPermissionsDebugString + locationManagerParametersDebugString)
    }
    
    // MARK: Adding/Removing Locations
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
            let monitoredRegions = locationManager.monitoredRegions
            print(locationManager.monitoredRegions)
            for region in monitoredRegions {
                if name == region.identifier {
                    locationManager.stopMonitoringForRegion(region)
                    print("stopped monitoring \(name)")
                }
            }
        }
    }
    
    // MARK: Notifiying Users
    public func notifyPeople(region: CLRegion, locationWhenNotified: CLLocation) {
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
                        
                        notifyPeople(monitorRegion, locationWhenNotified: lastLocation)
                    }
                }
            }
        }
    }
    
    //MARK: Tracking Location Updates
    public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        notifyIfWithinDistance(locations.last!)
    }
    
    public func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.description)
    }
    
    public func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("did enter region \(region.identifier)")
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationDic[region.identifier]?["withinRegion"] = true
        playAudio()
    }
    
    public func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("did exit region \(region.identifier)")
        self.locationDic[region.identifier]?["withinRegion"] = false
        self.locationDic[region.identifier]?["notifiedForRegion"] = false
        
        if outOfAllRegions() {
            locationManager.desiredAccuracy = self.accuracy
            stopAudio()
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
    
    // MARK: Slient audio for background tracking
    private func playAudio() {
        if !isPlaying {
            let pathToAudio = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("silence", ofType: "mp3")!)
            
            do {
                // setup audio player
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: AVAudioSessionCategoryOptions.MixWithOthers)
                try AVAudioSession.sharedInstance().setActive(true)
                print(pathToAudio)
                player = try AVAudioPlayer(contentsOfURL: pathToAudio, fileTypeHint: "mp3")
                player.numberOfLoops = -1
                player.prepareToPlay()
                player.play()
                
                isPlaying = true
                print ("playing silent audio in background")
            }
            catch _ {
                return print("silence sound file not found")
            }
        }
    }
    
    private func stopAudio() {
        if isPlaying {
            player.stop()
            print("stopped playing audio")
            isPlaying = false
        }
    }
}