//
//  PinFrame+CoreDataClass.swift
//  VirtualTourist
//
//  Created by stephen on 9/11/17.
//  Copyright © 2017 Bai Cloud Tech Co. All rights reserved.
//

import Foundation
import CoreData

@objc(PinFrame)
public class PinFrame: NSManagedObject {
    // MARK: Initializer
    
    convenience init(longtitude: Double, latitude: Double, context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "PinFrame", in: context) {
            self.init(entity: ent, insertInto: context)
            self.longtitude = longtitude
            self.latitude = latitude
            // by default set to false
            self.requested = false
        } else {
            fatalError("Unable to find Entity name of PinFrame!")
        }
    }
}
