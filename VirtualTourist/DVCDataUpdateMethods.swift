//
//  UpdateDataMethods.swift
//  VirtualTourist
//
//  Created by stephen on 9/13/17.
//  Copyright © 2017 Bai Cloud Tech Co. All rights reserved.
//

import Foundation
import CoreData

// This file implements the NSFetchedResultsControllerDelegate!!!

// This file is responsible for all the methods that manages data, 
// Examples: getting updates from PARSE, saving to backgroundContext, and making desired fetchedResultsController

extension DetailedViewController {
    // This function set the fetchedResultsController
    func initFetchedResultsController() {
        // generate the query such that photoFrames belong to the selectedPinFrame
        let fr = NSFetchRequest<NSFetchRequestResult>.init(entityName: "PhotoFrame")
        let predicate = NSPredicate.init(format: "pinframe = %@", argumentArray: [selectedPinFrame!])
        fr.predicate = predicate
        
        fr.sortDescriptors = []
        
        fetchedResultsController
            = NSFetchedResultsController.init(fetchRequest: fr,
                                              managedObjectContext: stack.persistingContext,
                                              sectionNameKeyPath: nil, cacheName: nil)
    }
    
    // This function load image data for collectionView
    func loadDataForCollectionView() {
        
        // data already in coredatastack
        if selectedPinFrame.requested {
            print("Previous imageDatas already exists ==> load these images ")
            // only make a request querying local storage
            initFetchedResultsController()
            
            
        }
        // data is not pulled from Flickr yet, make the Flickr request
        else {
            FClient.sharedInstance.requestFlickrData(longtitude: (selectedPinFrame?.longtitude)!, latitude: (selectedPinFrame?.latitude)!, completionHandlerForRequestData: { (imageDataSet, errorString) in
                // Success got 1-12 imageData
                if (errorString == nil) {
                    // not stack.performBackgroundBatchOperation invokes our implemented function Asynchronously!!!!
                    // remeber the Actor model and this is the proper way to do it
                    // performBackgroundBatchOperation also save() the changes!
                    self.stack.performBackgroundBatchOperation({ (backgroundContext) in
                        
                        for imageData in imageDataSet! {
                            // create pf instance and linked its relationship to pinFrame chosen
                            let picf = PhotoFrame.init(imageData: imageData, context: backgroundContext)
                            picf.pinframe = self.selectedPinFrame
                        }
                        
                        self.selectedPinFrame.requested = true
                    })
                    
                }
                else {
                    // Error
                    DebugM.log(errorString!)
                }
            })
            
        }
        
        
    }
    
    
    
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch ( let e as NSError) {
                print("Error while trying to perform a search: \n\(e)\n\(String(describing: fetchedResultsController))")
            }
        }
    }
    
}


