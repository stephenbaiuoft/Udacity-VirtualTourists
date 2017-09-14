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
            return (fr.fetchedObjects?.count)!
        } else {
            return 0
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
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let set = IndexSet(integer: sectionIndex)
        collectionView.performBatchUpdates({
            switch (type) {
            case .insert:
                self.collectionView.insertSections(set)
            case .delete:
                self.collectionView.deleteSections(set)
            default:
                // irrelevant in our case
                break
            }
        }, completion: nil)
        
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        collectionView.performBatchUpdates({
            switch(type) {
            case .insert:
                self.collectionView.insertItems(at: [newIndexPath!])
            case .delete:
                self.collectionView.deleteItems(at: [indexPath!])
            case .update:
                self.collectionView.reloadItems(at: [indexPath!])
            //tableView.reloadRows(at: [indexPath!], with: .fade)
            case .move:
                self.collectionView.deleteItems(at: [indexPath!])
                self.collectionView.insertItems(at: [newIndexPath!])
            }
        }, completion: nil)
        
    }
    
}
