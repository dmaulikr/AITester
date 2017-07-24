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
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    let testEntityName = "Test"
    
    // MARK: - Manage row selection when deleting Tests
    var changeType: NSFetchedResultsChangeType!
    var selectedTestInTableView: Test!
    var swipeToDeleteGestureStarted = false
    
    // MARK: - Date formatter
    lazy var dateFormatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.long
        formatter.timeStyle = .medium
        
        return formatter
        
    }()
    
    // MARK: - METHODS
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Core data manager
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        coreDataManager = appDelegate.coreDataManager
        
        // Fetched results controller
        initializeFetchedResultsController()
        
        // Allow selection when deleting
        tableView.allowsSelectionDuringEditing = true
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        performSegue(withIdentifier: Identifiers.addOrEditTestSegue, sender: selectedTestInTableView)
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        coreDataManager.saveContext()
        
    }
    
    
    // MARK: - @IBActions
    @IBAction func AddTestButtonTapped(_ sender: UIBarButtonItem) {
        
        let newTest = coreDataManager.insertNewTest()
        
        performSegue(withIdentifier: Identifiers.addOrEditTestSegue, sender: newTest)
        
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let sections = fetchedResultsController.sections {
            
            let currentSection = sections[section]
            
            return currentSection.numberOfObjects
            
        }
        
        return 0
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.testCell, for: indexPath)
        
        configureCell(cell, indexPath: indexPath)

        return cell
    }
    

    func configureCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        
        let test = fetchedResultsController.object(at: indexPath) as! Test
        
        cell.textLabel?.text = test.testName
        cell.detailTextLabel?.text = test.testDescription
        
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            guard let testToDelete = fetchedResultsController.object(at: indexPath) as? Test else { return }
            
            coreDataManager.deleteTest(testToDelete)
            
            
        }
        
    }
    
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let selectedTest = fetchedResultsController.object(at: indexPath) as? Test else { return }
        
        performSegue(withIdentifier: Identifiers.addOrEditTestSegue, sender: selectedTest)
        
        selectedTestInTableView = selectedTest
        
    }
    
    override func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        
        swipeToDeleteGestureStarted = true
        
    }
    
    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        
        if (swipeToDeleteGestureStarted) && (changeType != NSFetchedResultsChangeType.delete) {
            
            swipeToDeleteGestureStarted = false
            
            selectRowForSelectedTest()
            
        }
        
    }
    
    
    
    // MARK: - Select row for selected test
    func selectRowForSelectedTest() {
        
        if let selectedTest = selectedTestInTableView {
            
            let indexPathOfSelectedTest = fetchedResultsController.indexPath(forObject: selectedTest)
            
            if indexPathOfSelectedTest == nil {
                
                selectedTestInTableView = nil
                
                performSegue(withIdentifier: Identifiers.addOrEditTestSegue, sender: nil)
                
            } else {
                
                tableView.selectRow(at: indexPathOfSelectedTest, animated: false, scrollPosition: .none)
                
            }
            
        }
        
    }
    
    
    // MARK: - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Identifiers.addOrEditTestSegue {
            
            // Instantiate new AddOrEditTestViewController
            let navigationController = segue.destination as! UINavigationController
            let storyboard = navigationController.storyboard!
            
            if sender == nil {
                
                let blankViewController = storyboard.instantiateViewController(withIdentifier: Identifiers.blankViewControllerStoryboardId) as! BlankViewController
                navigationController.viewControllers[0] = blankViewController
                
            } else {
                
                let addOrEditTestViewController = storyboard.instantiateViewController(withIdentifier: Identifiers.addTestStoryboardId) as! AddOrEditTestViewController
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
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: testEntityName)
        
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
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.beginUpdates()
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .insert:
            
            changeType = NSFetchedResultsChangeType.insert
            
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            
            selectedTestInTableView = anObject as! Test
            
            
        case .delete:
            
            changeType = NSFetchedResultsChangeType.delete
            
            tableView.deleteRows(at: [indexPath!], with: .fade)
            
        case .update:
            
            changeType = NSFetchedResultsChangeType.update
            
            configureCell(tableView.cellForRow(at: indexPath!)!, indexPath: indexPath!)
            
        case .move:
            
            changeType = NSFetchedResultsChangeType.move
            
            if indexPath != newIndexPath {
                
                tableView.deleteRows(at: [indexPath!], with: .fade)
                tableView.insertRows(at: [newIndexPath!], with: .fade)
                
                configureCell(tableView.cellForRow(at: indexPath!)!, indexPath: indexPath!)
                
            } else {
                
                tableView.reloadRows(at: [indexPath!], with: .none)
                
            }
            
        }
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.endUpdates()
        
        // 1. All tests have been deleted
        if tableView.numberOfRows(inSection: 0) == 0 {
            
            selectedTestInTableView = nil
            
            performSegue(withIdentifier: Identifiers.addOrEditTestSegue, sender: nil)
            
            return
            
        }
        
        // 2. Editing or adding a test
        if (changeType == NSFetchedResultsChangeType.move) ||  (changeType == NSFetchedResultsChangeType.insert) {
            
            let firstRowIndexPath = IndexPath(row: 0, section: 0)
            
            tableView.selectRow(at: firstRowIndexPath, animated: false, scrollPosition: .top)
            
            return
            
        }
        
        // 3. Deleting a test
        if (changeType == NSFetchedResultsChangeType.delete) {
            
            selectRowForSelectedTest()
            
        }
        
        
        // 4. Set the changeType to nil
        changeType = nil
        
    }
    
}




