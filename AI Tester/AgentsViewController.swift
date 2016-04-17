//
//  AgentsViewController.swift
//  AI Tester
//
//  Created by Andrei Sadovnicov on 04/04/16.
//  Copyright © 2016 Andrei Sadovnicov. All rights reserved.
//

import UIKit
import CoreData

// MARK: - CLASS
class AgentsViewController: UITableViewController {

    // MARK: - PROPERTIES
    
    // MARK: - Core data manager
    var coreDataManager: CoreDataManager!
    var fetchedResultsController: NSFetchedResultsController!
    let agentEntityName = "Agent"

    // MARK: - Manage row selection when deleting agents
    var changeType: NSFetchedResultsChangeType!
    var selectedAgentInTableView: Agent!
    var swipeToDeleteGestureStarted = false
    
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
        
        performSegueWithIdentifier(Identifiers.addOrEditAgentSegue, sender: selectedAgentInTableView)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        coreDataManager.saveContext()
        
    }
    
    
    // MARK: - @IBActions
    @IBAction func addAgentButtonTapped(sender: UIBarButtonItem) {
        
        let newAgent = coreDataManager.insertNewAgent()
        
        performSegueWithIdentifier(Identifiers.addOrEditAgentSegue, sender: newAgent)
        
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Identifiers.agentCell, forIndexPath: indexPath)

        configureCell(cell, indexPath: indexPath)

        return cell
    }
    
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        
        let agent = fetchedResultsController.objectAtIndexPath(indexPath) as! Agent
        
        cell.textLabel?.text = agent.agentName
        cell.detailTextLabel?.text = agent.agentDescription
        
    }
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            
            guard let agentToDelete = fetchedResultsController.objectAtIndexPath(indexPath) as? Agent else { return }
            
            coreDataManager.deleteAgent(agentToDelete)
            
            
        }
        
    }
    

    // MARK: - Table view delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let selectedAgent = fetchedResultsController.objectAtIndexPath(indexPath) as? Agent else { return }
        
        performSegueWithIdentifier(Identifiers.addOrEditAgentSegue, sender: selectedAgent)
        
        selectedAgentInTableView = selectedAgent
        
    }
    
    override func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
        
        swipeToDeleteGestureStarted = true
        
    }
    
    override func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {

        if (swipeToDeleteGestureStarted) && (changeType != NSFetchedResultsChangeType.Delete) {
            
            swipeToDeleteGestureStarted = false
            
            selectRowForSelectedAgent()
            
        }
        
    }
    
    

    // MARK: - Select row for selected agent
    func selectRowForSelectedAgent() {
        
        if let selectedAgent = selectedAgentInTableView {
            
            let indexPathOfSelectedAgent = fetchedResultsController.indexPathForObject(selectedAgent)
            
            if indexPathOfSelectedAgent == nil {
                
                selectedAgentInTableView = nil
                
                performSegueWithIdentifier(Identifiers.addOrEditAgentSegue, sender: nil)
                
            } else {
                
                tableView.selectRowAtIndexPath(indexPathOfSelectedAgent, animated: false, scrollPosition: .None)
                
            }
            
        }
        
    }
    
    
    // MARK: - Prepare for segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == Identifiers.addOrEditAgentSegue {
            
            // Instantiate new AddOrEditAgentViewController
            let navigationController = segue.destinationViewController as! UINavigationController
            let storyboard = navigationController.storyboard!
            
            if sender == nil {
                
                let blankViewController = storyboard.instantiateViewControllerWithIdentifier(Identifiers.blankViewControllerStoryboardId) as! BlankViewController
                navigationController.viewControllers[0] = blankViewController
                
            } else {
                
                let addOrEditAgentViewController = storyboard.instantiateViewControllerWithIdentifier(Identifiers.addAgentStoryboardId) as! AddOrEditAgentViewController
                navigationController.viewControllers[0] = addOrEditAgentViewController
                
                // Pass the data to the new AddAgentViewController
                addOrEditAgentViewController.coreDataManager = coreDataManager
                addOrEditAgentViewController.agent = sender as! Agent
                
            }

        }
        
    }
 

}


// MARK: - EXTENSIONS

// MARK: - NSFetchedResults controller
extension AgentsViewController: NSFetchedResultsControllerDelegate {
    
    func initializeFetchedResultsController() {
        
        let request = NSFetchRequest(entityName: agentEntityName)
        
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
            
            selectedAgentInTableView = anObject as! Agent
            
            
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
        
        // 1. All agents have been deleted
        if tableView.numberOfRowsInSection(0) == 0 {
            
            selectedAgentInTableView = nil
            
            performSegueWithIdentifier(Identifiers.addOrEditAgentSegue, sender: nil)
            
            return
            
        }
        
        // 2. Editing or adding an agent
        if (changeType == NSFetchedResultsChangeType.Move) ||  (changeType == NSFetchedResultsChangeType.Insert) {
            
            let firstRowIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            
            tableView.selectRowAtIndexPath(firstRowIndexPath, animated: false, scrollPosition: .Top)
            
            return
            
        }
        
        // 3. Deleting an agent
        if (changeType == NSFetchedResultsChangeType.Delete) {
            
            selectRowForSelectedAgent()
            
        }
        
        
        // 4. Set the changeType to nil
        changeType = nil
        
    }
    
}




















