//
//  TestsViewController.swift
//  AI Tester
//
//  Created by Andrei Sadovnicov on 04/04/16.
//  Copyright © 2016 Andrei Sadovnicov. All rights reserved.
//

import UIKit
import CoreData

// MARK: - CLASS
class TestsViewController: UITableViewController {

    // MARK: - PROPERTIES
    
    // MARK: - Core data manager
    var coreDataManager: CoreDataManager!
    var fetchedResultsController: NSFetchedResultsController!
    let testEntityName = "Test"
    
    // MARK: - Manage row selection when deleting Tests
    var changeType: NSFetchedResultsChangeType!
    var selectedTestInTableView: Test!
    var swipeToDeleteGestureStarted = false
    
    // MARK: - Date formatter
    lazy var dateFormatter: NSDateFormatter = {
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = .MediumStyle
        
        return formatter
        
    }()
    
    // MARK: - METHODS
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Core data manager
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        coreDataManager = appDelegate.coreDataManager
        
        // Fetched results controller
        initializeFetchedResultsController()
        
        // Allow selection when deleting
        tableView.allowsSelectionDuringEditing = true
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        performSegueWithIdentifier(Identifiers.addOrEditTestSegue, sender: selectedTestInTableView)
        
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        coreDataManager.saveContext()
        
    }
    
    
    // MARK: - @IBActions
    @IBAction func AddTestButtonTapped(sender: UIBarButtonItem) {
        
        let newTest = coreDataManager.insertNewTest()
        
        performSegueWithIdentifier(Identifiers.addOrEditTestSegue, sender: newTest)
        
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let sections = fetchedResultsController.sections {
            
            let currentSection = sections[section]
            
            return currentSection.numberOfObjects
            
        }
        
        return 0
        
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier(Identifiers.testCell, forIndexPath: indexPath)
        
        configureCell(cell, indexPath: indexPath)

        return cell
    }
    

    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        
        let test = fetchedResultsController.objectAtIndexPath(indexPath) as! Test
        
        cell.textLabel?.text = test.testName
        cell.detailTextLabel?.text = test.testDescription
        
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            
            guard let testToDelete = fetchedResultsController.objectAtIndexPath(indexPath) as? Test else { return }
            
            coreDataManager.deleteTest(testToDelete)
            
            
        }
        
    }
    
    
    // MARK: - Table view delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let selectedTest = fetchedResultsController.objectAtIndexPath(indexPath) as? Test else { return }
        
        performSegueWithIdentifier(Identifiers.addOrEditTestSegue, sender: selectedTest)
        
        selectedTestInTableView = selectedTest
        
    }
    
    override func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
        
        swipeToDeleteGestureStarted = true
        
    }
    
    override func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
        
        if (swipeToDeleteGestureStarted) && (changeType != NSFetchedResultsChangeType.Delete) {
            
            swipeToDeleteGestureStarted = false
            
            selectRowForSelectedTest()
            
        }
        
    }
    
    
    
    // MARK: - Select row for selected test
    func selectRowForSelectedTest() {
        
        if let selectedTest = selectedTestInTableView {
            
            let indexPathOfSelectedTest = fetchedResultsController.indexPathForObject(selectedTest)
            
            if indexPathOfSelectedTest == nil {
                
                selectedTestInTableView = nil
                
                performSegueWithIdentifier(Identifiers.addOrEditTestSegue, sender: nil)
                
            } else {
                
                tableView.selectRowAtIndexPath(indexPathOfSelectedTest, animated: false, scrollPosition: .None)
                
            }
            
        }
        
    }
    
    
    // MARK: - Prepare for segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == Identifiers.addOrEditTestSegue {
            
            // Instantiate new AddOrEditTestViewController
            let navigationController = segue.destinationViewController as! UINavigationController
            let storyboard = navigationController.storyboard!
            
            if sender == nil {
                
                let blankViewController = storyboard.instantiateViewControllerWithIdentifier(Identifiers.blankViewControllerStoryboardId) as! BlankViewController
                navigationController.viewControllers[0] = blankViewController
                
            } else {
                
                let addOrEditTestViewController = storyboard.instantiateViewControllerWithIdentifier(Identifiers.addTestStoryboardId) as! AddOrEditTestViewController
                navigationController.viewControllers[0] = addOrEditTestViewController
                
                // Pass the data to the new AddTestViewController
                addOrEditTestViewController.coreDataManager = coreDataManager
                addOrEditTestViewController.test = sender as! Test
                addOrEditTestViewController.dateFormatter = dateFormatter
                
            }
            
            
            
        }
        
    }
    
}



// MARK: - EXTENSIONS

// MARK: - NSFetchedResults controller
extension TestsViewController: NSFetchedResultsControllerDelegate {
    
    func initializeFetchedResultsController() {
        
        let request = NSFetchRequest(entityName: testEntityName)
        
        let lastUpdateSortDescriptor = NSSortDescriptor(key: "lastUpdate", ascending: false)
        
        request.sortDescriptors = [lastUpdateSortDescriptor]
        
        let managedObjectContext = coreDataManager.managedObjectContext
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            
            try fetchedResultsController.performFetch()
            
        } catch {
            
            fatalError("Failed to initialize FetchedResultsController: \(error)")
            
        }
        
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        
        tableView.beginUpdates()
        
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
            
        case .Insert:
            
            changeType = NSFetchedResultsChangeType.Insert
            
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
            selectedTestInTableView = anObject as! Test
            
            
        case .Delete:
            
            changeType = NSFetchedResultsChangeType.Delete
            
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            
        case .Update:
            
            changeType = NSFetchedResultsChangeType.Update
            
            configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, indexPath: indexPath!)
            
        case .Move:
            
            changeType = NSFetchedResultsChangeType.Move
            
            if indexPath != newIndexPath {
                
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                
                configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, indexPath: indexPath!)
                
            } else {
                
                tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .None)
                
            }
            
        }
        
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        tableView.endUpdates()
        
        // 1. All tests have been deleted
        if tableView.numberOfRowsInSection(0) == 0 {
            
            selectedTestInTableView = nil
            
            performSegueWithIdentifier(Identifiers.addOrEditTestSegue, sender: nil)
            
            return
            
        }
        
        // 2. Editing or adding a test
        if (changeType == NSFetchedResultsChangeType.Move) ||  (changeType == NSFetchedResultsChangeType.Insert) {
            
            let firstRowIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            
            tableView.selectRowAtIndexPath(firstRowIndexPath, animated: false, scrollPosition: .Top)
            
            return
            
        }
        
        // 3. Deleting a test
        if (changeType == NSFetchedResultsChangeType.Delete) {
            
            selectRowForSelectedTest()
            
        }
        
        
        // 4. Set the changeType to nil
        changeType = nil
        
    }
    
}




