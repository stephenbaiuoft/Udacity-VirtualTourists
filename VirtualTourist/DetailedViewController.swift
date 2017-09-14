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
    
    var selectedPinFrame: PinFrame!
    var stack: CoreDataStack!

    // MARK: Variable Section
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        didSet{
            
            fetchedResultsController?.delegate = self
            executeSearch()
            // reload data for collectionViewController

        }
    }
    
    // collectionView section
    let reuseIdentifier = "CellReuseID"
    
    // flowLayout Variables
    let cellSpace:CGFloat = 10.0
    let itemsPerRow: CGFloat = 3
    var didLoadView = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // set up stack which points to the same entire application stack (datastack)
        let delegate = UIApplication.shared.delegate as! AppDelegate
        stack = delegate.stack
        
        // create fetchResultsController first ==> so context will notfiy FetchedResultsDelegate
        // after loadDataModel
        initFetchedResultsController()
        
        // delegate setup ==> so fetchedReultsController is not nil
        collectionView.delegate = self
        
        // loadDataModel
        loadDataForCollectionView()
        
        
        // set flowlayout
        setFlowLayout(size: view.frame.width)

        
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

    
    // set equal spacing for based on itemsPerRow
    func setFlowLayout(size: CGFloat) {
        let dimension = (size - cellSpace * (itemsPerRow + 2)) / itemsPerRow
        flowLayout.minimumInteritemSpacing = cellSpace
        flowLayout.minimumLineSpacing = cellSpace
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
}
