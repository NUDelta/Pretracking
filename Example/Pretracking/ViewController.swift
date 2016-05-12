//
//  ViewController.swift
//  Pretracking
//
//  Created by YK on 02/05/2016.
//  Copyright (c) 2016 YK. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        MyPretracker.mySharedManager.setupParameters(25, radius: 200, accuracy: kCLLocationAccuracyNearestTenMeters, distanceFilter: nil)
        MyPretracker.mySharedManager.initLocationManager()
        
        //add location
        MyPretracker.mySharedManager.addLocation(nil, latitude: 42.047995, longitude: -87.686, radius: nil, name: "Test Region")
        MyPretracker.mySharedManager.addLocation(nil, latitude: 42.047995, longitude: -87.686, radius: nil, name: "Test Region 2")
        MyPretracker.mySharedManager.addLocation(nil, latitude: 42.047995, longitude: -87.686, radius: nil, name: "Test Region 3")
        
        // remove location after short delay
        let seconds = 2.0
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            MyPretracker.mySharedManager.removeLocation("Test Region 2")
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

