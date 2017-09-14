//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by stephen on 9/11/17.
//  Copyright © 2017 Bai Cloud Tech Co. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var textLabel: UILabel!
    
    var editButton: UIBarButtonItem!
    var doneButton: UIBarButtonItem!
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? = nil
    var stack: CoreDataStack!
    var context: NSManagedObjectContext!
    var removeAnnotation: Bool = false
    
    // variables to store so no need to re-initialize
    var showMapFrame: CGRect!
    var hideMapFrame: CGRect!
    var showLabelFrame: CGRect!
    var hideLabelFrame: CGRect!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize miscellaneous variables
        initVariables()
        
        // initialize navigation right bar item
        loadBarButtonItem()
        
        // Section to get shraed data stack and the main context for displaying
        let delegate = UIApplication.shared.delegate as! AppDelegate
        stack = delegate.stack
        context = stack.context
        
        // Section for delegate assignments
        mapView.delegate = self                
        
        // now loadPin
        loadPinsFromStack()
        
        // so important to know it is added this way!!!
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(gestureRecognized:)))
        
        //long press (2 sec duration)
        uilpgr.minimumPressDuration = 1
        mapView.addGestureRecognizer(uilpgr)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // reset the title again
        navigationItem.title = "Virtual Tourists"
    }
    
    func loadBarButtonItem() {
        editButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(editingMode))
        doneButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(editingMode))
        
        navigationItem.rightBarButtonItem = editButton
    }
    
    // enter editingMode for mapViewControllers
    func editingMode() {
        // toggle removeAnnotation
        removeAnnotation = !removeAnnotation
        DebugM.log( "annotation toggled state: \(removeAnnotation)" )
        
        if(removeAnnotation){
            navigationItem.rightBarButtonItem = doneButton
            UIView.animate(withDuration: 0.4, animations: {
                
                self.mapView.frame = self.hideMapFrame
                // because of the navigation item which is also included in view
                self.textLabel.frame = self.showLabelFrame
                
            })
            
        } else {
            navigationItem.rightBarButtonItem = editButton
            UIView.animate(withDuration: 0.4, animations: {
                self.mapView.frame = self.showMapFrame
                self.textLabel.frame = self.hideLabelFrame
            })
        }
        
    }
    
    func longPressed(gestureRecognized: UIGestureRecognizer){
        let touchpoint = gestureRecognized.location(in: mapView)
        let location = mapView.convert(touchpoint, toCoordinateFrom: mapView)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        
        // Only Add Once Started Detecting Long Pressing && Not in Editing Mode
        if ( !removeAnnotation && gestureRecognized.state == UIGestureRecognizerState.began) {
            mapView.addAnnotation(annotation)
            // add CoreDataModel
            addPin(annotation: annotation)
        }
    }
    
    // read annotation objects from Stack
    // update mapView
    func loadPinsFromStack() {
        
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "PinFrame")
        fr.sortDescriptors = []
        fr.fetchLimit = 100
        // Create the FetchedResultsController ==> backgroundContext!
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.backgroundContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // perform fetch request and then we can access results
        executeSearch()
        
        // let mainQueue handle parsing for now: hopefully it's quick or i'll have to create
        // background to create mkPoints, and then use mainQueue to update mapView
        DispatchQueue.main.async {
            if let fo = self.fetchedResultsController?.fetchedObjects as? [PinFrame]{
                
                for pin in fo {
                    let annotation = MKPointAnnotation();
                    annotation.coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longtitude)
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
        
    }

}

// MARK: back-end helping functions for MapViewController
extension MapViewController {
    
    // initialize miscellaneous variables for VC
    func initVariables() {
        hideMapFrame = CGRect.init(x: 0, y: -50, width: self.view.frame.width, height: self.view.frame.height)
        // because of the navigation item which is also included in view
        
        showLabelFrame = CGRect.init(x: 0, y: view.frame.height - 50, width: self.view.frame.width, height: 50)
        
        showMapFrame = CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height )
        hideLabelFrame = CGRect.init(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 50)
    }
    
    // add to coredatastack ==> pinFrame added to backgroundContext!!!
    func addPin( annotation: MKPointAnnotation) {
        let pinFrame =  PinFrame.init(longtitude: annotation.coordinate.longitude,
                                      latitude: annotation.coordinate.latitude, context: stack.backgroundContext)
        DebugM.log("pinFrame object created: \(pinFrame)")
    }
    
    // remove from coredatastack given selected pinFrame
    func removePin(pinFrame: PinFrame) {
        stack.context.delete(pinFrame)
    }
    
    // fetchedResultsController perform search: ==> fetchedResultsController must be initialized
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(String(describing: fetchedResultsController))")
            }
        }
    }
}
