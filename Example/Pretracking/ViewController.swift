//
//  ViewController.swift
//  Pretracking
//
//  Created by YK on 02/05/2016.
//  Copyright (c) 2016 YK. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        MyPretracker.sharedManager.setupParameters(10000, latitude: 42.047995, longitude: -87.680586, radius: 100, accuracy: 100)
        MyPretracker.sharedManager.initLocationManager()
        MyPretracker.sharedManager.notifyPeople()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

