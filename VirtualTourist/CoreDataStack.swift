//
//  CoreDataStack.swift
//
//
//  Created by Fernando Rodríguez Romero on 21/02/16.
//  Copyright © 2016 udacity.com. All rights reserved.
//

import CoreData

// MARK: - CoreDataStack

struct CoreDataStack {
    
    // MARK: Properties
    
    private let model: NSManagedObjectModel
    internal let coordinator: NSPersistentStoreCoordinator
    private let modelURL: URL
    internal let dbURL: URL
    internal let persistingContext: NSManagedObjectContext
    internal let backgroundContext: NSManagedObjectContext
    let context: NSManagedObjectContext
    
    // MARK: Initializers
    
    init?(modelName: String) {
        
        // Assumes the model is in the main bundle
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            print("Unable to find \(modelName)in the main bundle")
            return nil
        }
        self.modelURL = modelURL
        
        // Try to create the model from the URL
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            print("unable to create a model from \(modelURL)")
            return nil
        }
        self.model = model
        
        // Create the store coordinator
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        // Create a persistingContext (private queue) and a child one (main queue)
        // create a context and add connect it to the coordinator
        persistingContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        persistingContext.persistentStoreCoordinator = coordinator
        
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = persistingContext
        
        // Create a background context child of main context
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = context
        
        // Add a SQLite store located in the documents folder
        let fm = FileManager.default
        
        guard let docUrl = fm.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to reach the documents folder")
            return nil
        }
        /*doc url is: file:///Users/stephen/Library/Developer/CoreSimulator/Devices/D5B81A44-44EE-4BE1-8B47-553808F624A2/data/Containers/Data/Application/66AA466C-D1A9-4681-93C7-7EC8D2C69064/Documents/
         */
        //print("doc url is: \(docUrl)")
        
        self.dbURL = docUrl.appendingPathComponent("model.sqlite")
        
        // Options for migration
        let options = [NSInferMappingModelAutomaticallyOption: true,NSMigratePersistentStoresAutomaticallyOption: true]
        
        do {
            try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: options as [NSObject : AnyObject]?)
        } catch {
            print("unable to add store at \(dbURL)")
        }
    }
    
    // MARK: Utils
    
    func addStoreCoordinator(_ storeType: String, configuration: String?, storeURL: URL, options : [NSObject:AnyObject]?) throws {
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL, options: nil)
    }
}

// MARK: - CoreDataStack (Removing Data)

internal extension CoreDataStack  {
    
    func dropAllData() throws {
        // delete all the objects in the db. This won't delete the files, it will
        // just leave empty tables.
        try coordinator.destroyPersistentStore(at: dbURL, ofType: NSSQLiteStoreType , options: nil)
        try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: nil)
    }
}

// MARK: - CoreDataStack (Batch Processing in the Background)

extension CoreDataStack {
    // performBackgroundBatchOperation is the function to call to commit batch/changes from say PARSE or other servicess
    // as this function calls backgroundContext.save()
    
    // Batch is a function signature
    typealias Batch = (_ workerContext: NSManagedObjectContext) -> ()
    
    // here @escaping Batch, so batch is a function paramter!! which is used in performBackgroundBatchOperations
    func performBackgroundBatchOperation(_ batch: @escaping Batch) {
        
        backgroundContext.perform() {
            
            batch(self.backgroundContext)
            
            // Save it to the parent context, so normal saving
            // can work
            do {
                // backgroundContext.save() is the built-in function that notifies its parent context
                print("saving to backgroundContext!!!")
                try self.backgroundContext.save()
            } catch {
                fatalError("Error while saving backgroundContext: \(error)")
            }
        }
    }
}

// MARK: - CoreDataStack (Save Data)

extension CoreDataStack {

    func saveContext() throws{

        // We call this synchronously, but it's a very fast
        // operation (it doesn't hit the disk). We need to know
        // when it ends so we can call the next save (on the persisting
        // context). This last one might take some time and is done
        // in a background queue
        context.performAndWait() {
            
            // Note context receives changes as we use performBackgroundBatchOperation to set up the connection
            if self.context.hasChanges {
                do {
                    print("context has changes and call save()")
                    try self.context.save()
                } catch {
                    fatalError("Error while saving main context: \(error)")
                }
                
                // context.save() propogates to persistingContext whose parent is the storeCoordinator
                // call persistingContext.save() to save onto the database
                self.persistingContext.perform() {
                    do {
                        print("persistingContext has changes and call save()  [StoreCoordinator(local storage)]")
                        try self.persistingContext.save()
                    } catch {
                        fatalError("Error while saving persisting context: \(error)")
                    }
                }
            }
        }
        
//        // Add the case for deletion
//        if persistingContext.hasChanges {
//            persistingContext.perform {
//                do {
//                    print("persistingContext.save() and this goes to StoreCoordinator(local storage)")
//                    try self.persistingContext.save()
//                } catch {
//                    fatalError("Error while saving persisting context: \(error)")
//                }
//            }
//        }
    }
    
    
    func autoSave(_ delayInSeconds : Int) {
        
        if delayInSeconds > 0 {
            do {
                try saveContext()
                print("AutoSaving")
            } catch {
                print("Error while autosaving")
            }
            
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: time) {
                self.autoSave(delayInSeconds)
            }
        }
    }
}
