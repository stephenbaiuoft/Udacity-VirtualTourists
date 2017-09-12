//
//  MapViewDelegateMethods.swift
//  VirtualTourist
//
//  Created by stephen on 9/11/17.
//  Copyright © 2017 Bai Cloud Tech Co. All rights reserved.
//

import UIKit
import MapKit
import CoreData

extension MapViewController: MKMapViewDelegate {
    // this function is for annimation of pin drop
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        if (pinView == nil) {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView?.canShowCallout = true
            pinView?.animatesDrop  = true
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // this is to remove from annotation
        if(removeAnnotation) {
            // fetch MkAnnotationObject
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "PinFrame")
            
            let latitude = view.annotation?.coordinate.latitude
            let longtitude = view.annotation?.coordinate.longitude
            let predicate = NSPredicate.init(format: "(longtitude = @%) AND (latitude = @%)", argumentArray: [latitude!, longtitude!])
            fetchRequest.predicate = predicate
            
            fetchedResultsController = NSFetchedResultsController.init(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
            
            // now you can execute search
            executeSearch()
            // then context delete? i think so?
            if let pinFrameSet = fetchedResultsController?.fetchedObjects as? [PinFrame] {
                if pinFrameSet.count == 1 {
                    removePin(pinFrame: pinFrameSet[0])
                } else {
                    DebugM.log(msg: "Failed to get that particular annotation or got a list of them: duplicates!")
                }
            }
            
            // successfully remove from coredatastack
            // now remove from mapView
            mapView.removeAnnotation(view.annotation!)
        }
        
    }
    
}
