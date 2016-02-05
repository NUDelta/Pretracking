//
//  MyPretracker.swift
//  Pretracking
//
//  Created by Yongsung on 2/5/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import Pretracking

class MyPretracker: Tracker {
    
//    override internal class var sharedManager: MyPretracker {
//        return Constants.sharedManager
//    }
//    
//    private struct Constants {
//        static let sharedManager = MyPretracker()
//    }
    
//    static let mySharedManager = MyPretracker()
    
    override func notifyPeople() {
        print("override this function")
    }
    
}
