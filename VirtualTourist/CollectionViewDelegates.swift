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
            let tmp = fr.sections![section].numberOfObjects
            
            return (fr.sections![section].numberOfObjects)
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        // configure cell data!
        let photoFrame = fetchedResultsController?.object(at: indexPath) as? PhotoFrame
        let cdata = photoFrame?.imageData as Data?
        cell.imageView.image = UIImage.init(data: cdata!)
        return cell

    }
    
    // MARK: UICollectionViewDelegate
    // Go to DetailMemeViewController!!!
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
//
//    }
    
    
}

// Implementing UICollectionViewDelegate Methods
extension DetailedViewController: UICollectionViewDelegate {
    
}

// This is how fetchedResultsController notifies collectionView
extension DetailedViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // initializes this blockOperationHead so continuously update operations can be added to
        blockOperationHead = BlockOperation.init(block: {
            // do nothing?
        })
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let set = IndexSet(integer: sectionIndex)

            switch (type) {
            case .insert:
                self.blockOperationHead?.addExecutionBlock {
                    self.collectionView.insertSections(set)
                }
            case .delete:
                self.blockOperationHead?.addExecutionBlock {
                    self.collectionView.deleteSections(set)
                }

            default:
                // irrelevant in our case
                break
            }
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        

            switch(type) {
            case .insert:
                guard let newIndexPath = newIndexPath else {
                    return
                }
                self.blockOperationHead?.addExecutionBlock {
                    self.collectionView.insertItems(at: [newIndexPath])
                    
                    self.blockCount += 1
                }

            case .delete:
                guard let indexPath = indexPath else {
                    return
                }
                self.blockOperationHead?.addExecutionBlock {
                    self.collectionView.deleteItems(at: [indexPath])
                    
                    self.blockCount += 1
                }

            case .update:
                guard let indexPath = indexPath else {
                    return
                }
                self.blockOperationHead?.addExecutionBlock {
                    self.collectionView.reloadItems(at: [indexPath])
                    
                    self.blockCount += 1
                }

            //tableView.reloadRows(at: [indexPath!], with: .fade)
            case .move:
                guard let indexPath = indexPath, let newIndexPath = newIndexPath
                else {
                    return
                }
                self.blockOperationHead?.addExecutionBlock {
                    self.collectionView.deleteItems(at: [indexPath])
                    self.collectionView.insertItems(at: [newIndexPath])
                    
                    self.blockCount += 1
                }
            }
        
    }
    
    // didChangeContent: all the changes have been sent to fetchedResultsController 
    // through debugging: we know that fetchedResultsController receives changes continuously for a period of time!
    // So group up all the changes for collectionView delegates and take effect of these changes here
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if (blockOperationHead != nil) {
            print("blockOperationHead has been initialized for sure")
        } else{
            print("is this what the problem is?")
        }
        let tmp = blockOperationHead!.executionBlocks.count
        
        print ( "# of operations is: \(tmp)" )
        print   ("# of countBlobkcs is \(blockCount)")
        
        collectionView.performBatchUpdates({
            self.blockOperationHead?.start()
            
        }) { (success) in
            if(success) {
                print("Successfully done performBatchUpdates")
            } else {
                print("Failed to performBatchUpdates to collectionView")
            }
        }
    }

    

}
