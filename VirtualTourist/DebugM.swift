//
//  DebugM.swift
//  VirtualTourist
//
//  Created by stephen on 9/12/17.
//  Copyright © 2017 Bai Cloud Tech Co. All rights reserved.
//

import Foundation

// This file creates some helping printing debugging functions
class DebugM {
    static func log( msg:String) {
        if(true) {
            print(msg)
        }
    }
    
    static func log( msg:String, obj: AnyObject) {
        if(true) {
            print(msg + ": " + (obj as! String) )
        }
    }
}
