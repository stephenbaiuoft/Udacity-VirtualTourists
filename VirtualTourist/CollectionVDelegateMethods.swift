//
//  CollectionViewDelegates.swift
//  VirtualTourist
//
//  Created by stephen on 9/12/17.
//  Copyright © 2017 Bai Cloud Tech Co. All rights reserved.
//

import Foundation
import UIKit
import CoreData

// Delegates for DetailedViewController ==> which manages 
extension DetailedViewController: UICollectionViewDataSource {
    
    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let fr = fetchedResultsController {
            return (fr.sections?.count)!
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if let fr = fetchedResultsController {
            // important to return that particular section number of Objects!!
            //return  10 < fr.sections![section].numberOfObjects ? 10 : fr.sections![section].numberOfObjects
            return  fr.sections![section].numberOfObjects

        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, titleForHeaderInSection section: Int) -> String? {
        if let fc = fetchedResultsController {
            return fc.sections![section].name
        } else {
            return nil
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // notify the button if collectionViewButton Text needs to be changed
        updateBotButton()
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        let activityIndicator = cell.activityIndicator!
        
        // configure cell data!
        let photoFrame = fetchedResultsController?.object(at: indexPath) as? PhotoFrame
        
        // create activityIndicator & start animating
        // stop it when imageData finishes loading


        activityIndicator.hidesWhenStopped = true
        
        print("start animating now!")
        activityIndicator.startAnimating()
        // 2 cases ==> one is just queried and need to get and save binary data
        if  ( photoFrame?.imageData == nil ) {
        
            let task = FClient.sharedInstance.taskForRequestImageData(filePath: (photoFrame?.imageUrlString)!, completionHandlerForRequestImageData: { (imageData, errString)
                in
                
                if(errString == nil) {
                    
                    self.stack.performContextBatchOperation({ (mainContext) in
                        photoFrame?.imageData = imageData as NSData?
                        
                    })
                    
                    DispatchQueue.main.async {
                        
                        // stop activityIndicator
                        activityIndicator.stopAnimating()
                    }
                }
            })
        }
            
        else {
            DispatchQueue.main.async {
                let data =  photoFrame?.imageData! as Data?
                //cell.imageView.image = UIImage.init(data:  data!)
                cell.imageView.image = UIImage.init(data:  data!)
                cell.imageView.alpha = 1
                if self.selectedIndexSet.contains(indexPath) {
                    // set it here
                    DebugM.log("setting it here as well => will be called on reload this item")
                    cell.imageView.alpha = 0.6
                }
                // stop activityIndicator
                activityIndicator.stopAnimating()
            }
        }
                
        
        return cell

    }
    
}

// Implementing UICollectionViewDelegate Methods
extension DetailedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("This item is selected in particular: saving indexPath info ")
        
         // Because swift re-uses the cells!!! so guess what
         // you should save this index info and see when displaying, change the value there!!
        if(!selectedIndexSet.contains(indexPath)) {
            selectedIndexSet.append(indexPath)
        } else {
            selectedIndexSet.remove(at: selectedIndexSet.index(of: indexPath)!)
        }

        // Now reload the item, which goes back to the return cell delegate!!
        collectionView.reloadItems(at: [indexPath])

    }
    
 
    
}

// This is how fetchedResultsController notifies collectionView
extension DetailedViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print( " number of blockOperationSet in the beginning: \(blockOperationSet.count)" )
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let set = IndexSet(integer: sectionIndex)

            switch (type) {
            case .insert:
                blockOperationSet.append(BlockOperation.init(block: {
                    [set] in
                     self.collectionView.insertSections(set)
                }))
                
            case .delete:
                blockOperationSet.append(BlockOperation.init(block: {
                    [set] in
                    self.collectionView.deleteSections(set)
                }))

            default:
                // irrelevant in our case
                break
            }
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        

            switch(type) {
            case .insert:
                self.blockOperationSet.append(BlockOperation.init(block: {
                    [newIndexPath] in
                    self.collectionView.insertItems(at: [newIndexPath!])
                }))

            case .delete:
                self.blockOperationSet.append(BlockOperation.init(block: {
                    [indexPath] in
                    self.collectionView.deleteItems(at: [indexPath!])
                }))
        
            case .update:
                self.blockOperationSet.append(BlockOperation.init(block: {
                    [indexPath] in
                    self.collectionView.reloadItems(at: [indexPath!])
                }))
                
            case .move:
                self.blockOperationSet.append(BlockOperation.init(block: {
                    [indexPath, newIndexPath] in
                    self.collectionView.deleteItems(at: [indexPath!])
                    self.collectionView.insertItems(at: [newIndexPath!])
                }))
            }
        
    }
    
    // didChangeContent: all the changes have been sent to fetchedResultsController 
    // through debugging: we know that fetchedResultsController receives changes continuously for a period of time!
    // So group up all the changes for collectionView delegates and take effect of these changes here
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        
        collectionView.performBatchUpdates({
            for blockOp in self.blockOperationSet {
                blockOp.start()
            }
            
        }) { (success) in
            if(success) {
                print("Successfully done performBatchUpdates")
                self.blockOperationSet.removeAll()
            } else {
                print("Failed to performBatchUpdates to collectionView")
            }
        }
    }

    

}
