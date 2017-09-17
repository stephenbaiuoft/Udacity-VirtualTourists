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
    // This function set fetchedResultsController to query local storage
    func initFetchedResultsController() {

        // generate the query such that photoFrames belong to the selectedPinFrame
        let fr = NSFetchRequest<NSFetchRequestResult>.init(entityName: "PhotoFrame")
        // if selectedPinFrame has data loaded already then
        if ( selectedPinFrame.requested ){

            let predicate = NSPredicate.init(format: "pinframe = %@", argumentArray: [selectedPinFrame!])
            fr.predicate = predicate
            
            fr.sortDescriptors = []
            
            fetchedResultsController
                = NSFetchedResultsController.init(fetchRequest: fr,
                                                  managedObjectContext: stack.context,
                                                  sectionNameKeyPath: nil, cacheName: nil)
        }
        // query photoFrames that just get initialized
        else {
            // create the fetchedResultsController
            let predicateNil = NSPredicate.init(format: "pinframe = nil", argumentArray: [])
            fr.predicate = predicateNil
            fr.sortDescriptors = []
            
            fetchedResultsController
                = NSFetchedResultsController.init(fetchRequest: fr,
                                                  managedObjectContext: stack.context,
                                                  sectionNameKeyPath: nil, cacheName: nil)
            
            
            // initialize the task for getting imageUrl now
            FClient.sharedInstance.requestImageUrlSet(longtitude: (selectedPinFrame?.longtitude)!, latitude: (selectedPinFrame?.latitude)!, completionHandlerForRequestData: { (imageUrlDataSet, errorString)
                in
                // Success got 1-12 imageData
                if (errorString == nil) {
                    
                    // now stack.performBackgroundBatchOperation invokes our implemented function Asynchronously!!!!
                    // remeber the Actor model and this is the proper way to do it
                    // modified performBack ==> such that self.selectedPinFrame relationship is added on the stackQueue
                    self.stack.performBackgroundBatchOperation({  (workerContext) in
                        
                        for imageUrlData in imageUrlDataSet! {
                            // create pf instance and linked its relationship to pinFrame chosen
                            // Do the Linking in FetchedResultsControlled Delegate Methods
                            let photoFrame = PhotoFrame.init(imageStringUrl: imageUrlData, context: workerContext)
                        }
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


