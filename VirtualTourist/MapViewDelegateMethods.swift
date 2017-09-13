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
            pinView?.canShowCallout = false
            pinView?.animatesDrop  = true
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        DebugM.log( "Entered mapView selection annotation delegation methods")
        // this is to remove from annotation
        if(removeAnnotation) {
            DebugM.log( "Did select a mkannotationview object")
            // fetch MkAnnotationObject
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PinFrame")
            
            let latitude = view.annotation?.coordinate.latitude
            let longtitude = view.annotation?.coordinate.longitude
            let predicate = NSPredicate.init(format: "(longtitude == %@) AND (latitude == %@)", argumentArray: [longtitude!, latitude!])
            fetchRequest.predicate = predicate
            // required by default
            fetchRequest.sortDescriptors = []
            
            fetchedResultsController = NSFetchedResultsController.init(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
            
            // now you can execute search
            executeSearch()
            // then context delete? i think so?
            if let pinFrameSet = fetchedResultsController?.fetchedObjects as? [PinFrame] {
                if pinFrameSet.count >= 1 {
                    // delete the whole thing!
                    for pinFrame in pinFrameSet {
                        context.delete(pinFrame)
                    }

                } else {
                    DebugM.log( "Failed to get that particular annotation or got a list of them: duplicates!")
                }
            }
            
            // successfully remove from coredatastack
            // now remove from mapView
            mapView.removeAnnotation(view.annotation!)
        }
        
        // This is the section for detailed MapView segue and etc
        else{
            // push to navigationController
            let detailedController = storyboard?.instantiateViewController(withIdentifier: "DetailedViewController") as! DetailedViewController
            // pass data to controller
            detailedController.annotation = view.annotation!
            
            // hacky way of changing the navigationController Title ==> have to change back
            
            navigationItem.title = "OK"
            self.navigationController!.pushViewController(detailedController, animated: true)
        }
        
    }
    
}
