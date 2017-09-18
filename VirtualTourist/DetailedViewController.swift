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
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    var blockCount = 0
    var coordinate: CLLocationCoordinate2D!
    
    // MARK: Variable Section
    var selectedPinFrame: PinFrame!
    var stack: CoreDataStack!

    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? {
        didSet{
            
            fetchedResultsController?.delegate = self
            executeSearch()
        }
    }
    
    var blockOperationSet = [BlockOperation]()
    // collectionView section
    let reuseIdentifier = "CellReuseID"
    
    // flowLayout Variables
    let cellSpace:CGFloat = 5.0
    let edgeSpace:CGFloat = 3.0
    let itemsPerRow: CGFloat = 3
    var didLoadView = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if(selectedPinFrame.requested == true) {
            newCollectionButton.isEnabled = true
        }
        else {
            newCollectionButton.isEnabled = false
        }

        
        // set up stack which points to the same entire application stack (datastack)
        let delegate = UIApplication.shared.delegate as! AppDelegate
        stack = delegate.stack

        // delegate setup ==> so fetchedReultsController is not nil!!!
        // So IMPORTANT that CollectionView HAS TWO DELEGATES!!!
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // create fetchResultsController first ==> so context will notfiy FetchedResultsDelegate
        initFetchedResultsController()
        
        // set flowlayout
        setFlowLayout(size: view.frame.width)
        didLoadView = true
        
        
        // asynchrnously add the annotation pin
        addToMapView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // asynchrnously
        removeFromMapView()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if(didLoadView) {
            print("viewWillTransition with width: \(size.width)" )
            setFlowLayout(size: size.width)
        }
    }

    // newCollection is pressed
    @IBAction func newCollectionPressed() {
        // remove all database objects
        stack.performContextBatchOperation { (mainContext) in
            for photoFrame in self.selectedPinFrame.photoframe! {
                mainContext.delete(photoFrame as! NSManagedObject)
            }
        }
        
        // load the imageData from Flickr again
        loadImageData()
        
        
    }
}

// MARK: Back end Logical Functions
extension DetailedViewController {
    func showLabel() {
        let label = UILabel.init()
        label.text = "This pin has no images"
        label.textAlignment = .center
        // have to set false so autolayout calcualtes our constraints!
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.init(item: label, attribute: .centerX, relatedBy: .equal, toItem: mapView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint.init(item: label, attribute: .width, relatedBy: .equal, toItem: mapView, attribute: .width, multiplier: 1, constant: 0).isActive = true
        
        NSLayoutConstraint.init(item: label, attribute: .top, relatedBy: .equal, toItem: mapView, attribute: .bottom, multiplier: 1, constant: 50).isActive = true
        
        NSLayoutConstraint.init(item: label, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50.0).isActive = true
        
    }
    
    func addToMapView() {
        DispatchQueue.main.async {
            self.coordinate = CLLocationCoordinate2D.init(latitude: self.selectedPinFrame.latitude,
                                                        longitude: self.selectedPinFrame.longtitude)
            
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(self.coordinate, 3000, 3000)
            self.mapView.setRegion(coordinateRegion, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = self.coordinate
            self.mapView.addAnnotation(annotation)
        }
    }
    
    func removeFromMapView() {
        DispatchQueue.main.async {
            let annotation = MKPointAnnotation()
            annotation.coordinate = self.coordinate
            self.mapView.removeAnnotation(annotation)
        }
    }
    
    // set equal spacing for based on itemsPerRow
    func setFlowLayout(size: CGFloat) {
        let dimension = (size - cellSpace * (itemsPerRow - 1) - 2 * edgeSpace ) / itemsPerRow
        flowLayout.minimumInteritemSpacing = cellSpace
        flowLayout.minimumLineSpacing = cellSpace
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        flowLayout.sectionInset = UIEdgeInsetsMake(edgeSpace, edgeSpace, edgeSpace, edgeSpace)
    }
}
