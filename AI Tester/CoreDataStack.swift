//
//  CoreDataStack.swift
//  AI Tester
//
//  Created by Andrei Sadovnicov on 04/04/16.
//  Copyright © 2016 Andrei Sadovnicov. All rights reserved.
//

import CoreData

class CoreDataStack {
    
    // MARK: - Model name
    let modelName = "AI_Tester"
    
    // MARK: - Managed object model
    private lazy var managedObjectModel: NSManagedObjectModel = {
        
        let modelURL = NSBundle.mainBundle().URLForResource(self.modelName, withExtension: "momd")!
        
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        
    }()
    
    
    // MARK: - Managed object context
    lazy var managedObjectContext: NSManagedObjectContext = {
        
        var context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        return context
        
    }()
    
    
    // MARK: - Persistent store coordinator
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(self.modelName)
        
        do {
            
            let options = [NSMigratePersistentStoresAutomaticallyOption : true]
            
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options)
            
        } catch  {
            
            fatalError("Error adding persistent store.")
            
        }
        
        return coordinator
    }()
    
    
    
    // MARK: - Documents directory
    private lazy var applicationDocumentsDirectory: NSURL = {
        
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        
        return urls[urls.count-1]
        
    }()
    
}



