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
        
        MyPretracker.mySharedManager.setupParameters(10000, latitude: 42.047995, longitude: -87.680586, radius: 100, accuracy: 0.1, name: "new location")
        MyPretracker.mySharedManager.initLocationManager()
        
        //add location
        MyPretracker.mySharedManager.addLocation(10000, latitude: 42.047995, longitude: -87.686, radius: 50, name: "Test Region")
        MyPretracker.mySharedManager.addLocation(10000, latitude: 42.047995, longitude: -87.686, radius: 50, name: "Test Region 2")
        MyPretracker.mySharedManager.addLocation(10000, latitude: 42.047995, longitude: -87.686, radius: 50, name: "Test Region 3")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

