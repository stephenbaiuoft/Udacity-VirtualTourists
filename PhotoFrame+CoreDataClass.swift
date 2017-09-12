//
//  PhotoFrame+CoreDataClass.swift
//  VirtualTourist
//
//  Created by stephen on 9/11/17.
//  Copyright © 2017 Bai Cloud Tech Co. All rights reserved.
//

import Foundation
import CoreData

@objc(PhotoFrame)
public class PhotoFrame: NSManagedObject {
    // MARK: Initializer
    
    convenience init( imageData: NSData, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "PhotoFrame", in: context) {
            self.init(entity: ent, insertInto: context)
            self.imageData = imageData
        } else {
            fatalError("Unable to find Entity name of PhotoFrame")
        }
    }
}
