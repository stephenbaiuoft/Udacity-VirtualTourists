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
//extension DetailedViewController: UICollectionViewDataSource {
//    
//    // MARK: UICollectionViewDataSource
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of items
//
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        //let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MemeCollectionViewCell
//        
//        // Configure the cell...
//
//    }
//    
//    // MARK: UICollectionViewDelegate
//    // Go to DetailMemeViewController!!!
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
////        let controller = storyboard?.instantiateViewController(withIdentifier: MemeDetailViewController ) as! MemeDetailViewController
////        let index = (indexPath as NSIndexPath).row
////        controller.selectedMeme = memes[index]
////        controller.hidesBottomBarWhenPushed = true
////        
////        self.navigationController?.pushViewController(controller, animated: true)
//    }
//    
//    
//}

// Implementing UICollectionViewDelegate Methods
extension DetailedViewController: UICollectionViewDelegate {
    
}

// MARK: fetchedResultsController Delegate Methods
extension DetailedViewController: NSFetchedResultsControllerDelegate {
    
}
