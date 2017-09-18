//
//  UpdateDataMethods.swift
//  VirtualTourist
//
//  Created by stephen on 9/13/17.
//  Copyright © 2017 Bai Cloud Tech Co. All rights reserved.
//

import Foundation
import CoreData
import UIKit

// This file implements the NSFetchedResultsControllerDelegate!!!

// This file is responsible for all the methods that manages data, 
// Examples: getting updates from PARSE, saving to backgroundContext, and making desired fetchedResultsController

extension DetailedViewController {
    
    func loadImageData() {
    
        // initialize the task for getting imageUrl now
        FClient.sharedInstance.requestImageUrlSet(longtitude: (selectedPinFrame?.longtitude)!, latitude: (selectedPinFrame?.latitude)!, completionHandlerForRequestData: { (imageUrlDataSet, errorString)
            in
            // Success got 1-12 imageData
            if (errorString == nil) {
                if( imageUrlDataSet?.count == 0 ){
                    DispatchQueue.main.async {
                        self.showLabel()
                    }
                    self.stack.performContextBatchOperation({ (mainContext) in
                        self.selectedPinFrame.requested = true
                    })
                }
                else {
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
                
                // re-enable the button
                DispatchQueue.main.async {
                    self.newCollectionButton.isEnabled = true
                }
            }
                
            else {
                // Error
                DebugM.log(errorString!)
            }
            
        })
    }
    
    
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
        
        if ( selectedPinFrame.requested && selectedPinFrame.photoframe?.count == 0) {
            // display the label
            showLabel()
        }
        // query photoFrames that just get initialized
        if(!selectedPinFrame.requested ) {
            // initialize the task for getting imageUrl now
            loadImageData()
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


