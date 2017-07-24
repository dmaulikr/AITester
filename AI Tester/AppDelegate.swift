//
//  AppDelegate.swift
//  AI Tester
//
//  Created by Andrei Sadovnicov on 04/04/16.
//  Copyright © 2016 Andrei Sadovnicov. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - PROPERTIES
    
    // MARK: - Window
    var window: UIWindow?

    // MARK: - Core data stack
    lazy var coreDataStack = CoreDataStack()
    var coreDataManager: CoreDataManager!

    
    // MARK: - METHODS
    
    // MARK: - Application life cycle
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize core data manager
        coreDataManager = CoreDataManager(managedObjectContext: coreDataStack.managedObjectContext)
        
        // Import sample data
        coreDataManager.importSampleData()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {

        
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {

            coreDataManager.saveContext()
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {

            coreDataManager.saveContext()
        
    }


}

