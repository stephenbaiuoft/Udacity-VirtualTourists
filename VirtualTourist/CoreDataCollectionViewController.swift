//
//  CoreDataCollectionViewController.swift
//  VirtualTourist
//
//  Created by stephen on 9/11/17.
//  Copyright © 2017 Bai Cloud Tech Co. All rights reserved.
//

/*very similar to CoreDataTableViewController, where this file servesr as a 
 base class that seamlessly synchrnoizes FetchResultController with CollectionViewController*/

import UIKit
import CoreData


class CoreDataCollectionViewController: UICollectionViewController {
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        didSet{
            fetchedResultsController?.delegate = self
            executeSearch();
            self.collectionView?.reloadData()
        }
    }
    


    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Will Override This Method!")

        // Do any additional setup after loading the view.
    }
    
    // execute fetchedRequests ==> then afterwards, you can get fetchedObjects as results
    func executeSearch() {
        if let fc = fetchedResultsController{
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(String(describing: fetchedResultsController))")
            }
        }
    }

}

// Delegate methods for NSFetchedResultsControllerDelegate
extension CoreDataCollectionViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        
        collectionView?.performBatchUpdates({
            let set = IndexSet(integer: sectionIndex)
            
            switch (type) {
            case .insert:
                self.collectionView?.insertSections(set)
            case .delete:
                self.collectionView?.deleteSections(set)
            default:
                // irrelevant in our case
                break
            }
        }, completion: nil)

    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        collectionView?.performBatchUpdates({
            switch(type) {
            case .insert:
                self.collectionView?.insertItems(at: [newIndexPath!])
                
            case .delete:
                self.collectionView?.deleteItems(at: [indexPath!])
            case .update:
                self.collectionView?.reloadItems(at: [newIndexPath!])
                
            case .move:
                self.collectionView?.deleteItems(at: [indexPath!])
                self.collectionView?.insertItems(at: [newIndexPath!])
            }
        }, completion: nil)
    }
    
    
}

extension CoreDataCollectionViewController{
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if let fc = fetchedResultsController{
            return (fc.sections?.count)!
        }
        else{
                return 0
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fc = fetchedResultsController {
            return (fc.sections![section].objects?.count)!
        }
        // #warning Incomplete implementation, return the number of items
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("This method MUST be implemented by a subclass of CoreDataCollectionViewController")
    }
    
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
}

