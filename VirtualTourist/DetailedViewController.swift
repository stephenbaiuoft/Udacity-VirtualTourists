//
//  DetailedViewController.swift
//  VirtualTourist
//
//  Created by stephen on 9/12/17.
//  Copyright © 2017 Bai Cloud Tech Co. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class DetailedViewController: UIViewController {
    // MARK: IBOutlet Section
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var annotation: MKAnnotation? = nil
    

    // MARK: Variable Section
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        didSet{
            fetchedResultsController?.delegate = self
            executeSearch()
            // reload data for collectionViewController
        }
    }
    
    // collectionView section
    let reuseIdentifier = "CollectionCell"
    
    // flowLayout Variables
    let cellSpace:CGFloat = 10.0
    let itemsPerRow: CGFloat = 3
    var didLoadView = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        // set flowlayout
        setFlowLayout(size: view.frame.width)
        
        // delegate setup
        collectionView.delegate = self
        
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if(didLoadView) {
            setFlowLayout(size: size.width)
        }
    }

}

// MARK: Back end Logical Functions
extension DetailedViewController {
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch ( let e as NSError) {
                print("Error while trying to perform a search: \n\(e)\n\(String(describing: fetchedResultsController))")
            }
        }
    }
    
    // set equal spacing for based on itemsPerRow
    func setFlowLayout(size: CGFloat) {
        let dimension = (size - cellSpace * (itemsPerRow + 2)) / itemsPerRow
        flowLayout.minimumInteritemSpacing = cellSpace
        flowLayout.minimumLineSpacing = cellSpace
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
}
