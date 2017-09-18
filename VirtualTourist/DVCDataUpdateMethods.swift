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
        let predicate = NSPredicate.init(format: "pinframe = %@", argumentArray: [selectedPinFrame!])
        fr.predicate = predicate
        
        fr.sortDescriptors = []
        
        fetchedResultsController
            = NSFetchedResultsController.init(fetchRequest: fr,
                                              managedObjectContext: stack.context,
                                              sectionNameKeyPath: nil, cacheName: nil)
        
        // if selectedPinFrame has data loaded already then
        if ( selectedPinFrame.requested ){
            

        }
        // query photoFrames that just get initialized
        else {
            // initialize the task for getting imageUrl now
            FClient.sharedInstance.requestImageUrlSet(longtitude: (selectedPinFrame?.longtitude)!, latitude: (selectedPinFrame?.latitude)!, completionHandlerForRequestData: { (imageUrlDataSet, errorString)
                in
                // Success got 1-12 imageData
                if (errorString == nil) {
                    
                    // Now mainContext is responsible for creating instances!! 
                    // Always remeber this or else if you do not build the relationship here ==> it fails!!
                    self.stack.performContextBatchOperation({ (mainContext) in
                        for imageUrlData in imageUrlDataSet! {
                            // create pf instance and linked its relationship to pinFrame chosen
                            // Do the Linking in FetchedResultsControlled Delegate Methods
                            let photoFrame = PhotoFrame.init(imageStringUrl: imageUrlData, context: mainContext)
                            photoFrame.pinframe = self.selectedPinFrame
                        }
                        // set selectedPinFrame to be true
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


