//
//  PinFrame+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by stephen on 9/23/17.
//  Copyright © 2017 Bai Cloud Tech Co. All rights reserved.
//
//

import Foundation
import CoreData


extension PinFrame {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PinFrame> {
        return NSFetchRequest<PinFrame>(entityName: "PinFrame")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longtitude: Double
    @NSManaged public var requested: Bool
    @NSManaged public var photoframe: NSSet?

}

// MARK: Generated accessors for photoframe
extension PinFrame {

    @objc(addPhotoframeObject:)
    @NSManaged public func addToPhotoframe(_ value: PhotoFrame)

    @objc(removePhotoframeObject:)
    @NSManaged public func removeFromPhotoframe(_ value: PhotoFrame)

    @objc(addPhotoframe:)
    @NSManaged public func addToPhotoframe(_ values: NSSet)

    @objc(removePhotoframe:)
    @NSManaged public func removeFromPhotoframe(_ values: NSSet)

}
