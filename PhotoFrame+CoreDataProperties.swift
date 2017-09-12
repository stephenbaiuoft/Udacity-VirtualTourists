//
//  PhotoFrame+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by stephen on 9/11/17.
//  Copyright © 2017 Bai Cloud Tech Co. All rights reserved.
//

import Foundation
import CoreData


extension PhotoFrame {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhotoFrame> {
        return NSFetchRequest<PhotoFrame>(entityName: "PhotoFrame")
    }

    @NSManaged public var imageData: NSData?
    @NSManaged public var pinframe: PinFrame?

}
