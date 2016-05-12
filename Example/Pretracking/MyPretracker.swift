//
//  MyPretracker.swift
//  Pretracking
//
//  Created by Yongsung on 2/5/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import Pretracking
import CoreLocation

class MyPretracker: Tracker {
    
    static let mySharedManager = MyPretracker()
    override func notifyPeople(region: CLRegion, locationWhenNotified: CLLocation) {
        let date = NSDate()
        print("notification at \(date) for region \(region) at location \(locationWhenNotified)")
    }
}
