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
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
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
        
        performSegue(withIdentifier: Identifiers.addOrEditAgentSegue, sender: selectedAgentInTableView)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        coreDataManager.saveContext()
        
    }
    
    
    // MARK: - @IBActions
    @IBAction func addAgentButtonTapped(_ sender: UIBarButtonItem) {
        
        let newAgent = coreDataManager.insertNewAgent()
        
        performSegue(withIdentifier: Identifiers.addOrEditAgentSegue, sender: newAgent)
        
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.agentCell, for: indexPath)

        configureCell(cell, indexPath: indexPath)

        return cell
    }
    
    
    func configureCell(_ cell: UITableViewCell, indexPath: IndexPath) {
        
        let agent = fetchedResultsController.object(at: indexPath) as! Agent
        
        cell.textLabel?.text = agent.agentName
        cell.detailTextLabel?.text = agent.agentDescription
        
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            guard let agentToDelete = fetchedResultsController.object(at: indexPath) as? Agent else { return }
            
            coreDataManager.deleteAgent(agentToDelete)
            
            
        }
        
    }
    

    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let selectedAgent = fetchedResultsController.object(at: indexPath) as? Agent else { return }
        
        performSegue(withIdentifier: Identifiers.addOrEditAgentSegue, sender: selectedAgent)
        
        selectedAgentInTableView = selectedAgent
        
    }
    
    override func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        
        swipeToDeleteGestureStarted = true
        
    }
    
    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {

        if (swipeToDeleteGestureStarted) && (changeType != NSFetchedResultsChangeType.delete) {
            
            swipeToDeleteGestureStarted = false
            
            selectRowForSelectedAgent()
            
        }
        
    }
    
    

    // MARK: - Select row for selected agent
    func selectRowForSelectedAgent() {
        
        if let selectedAgent = selectedAgentInTableView {
            
            let indexPathOfSelectedAgent = fetchedResultsController.indexPath(forObject: selectedAgent)
            
            if indexPathOfSelectedAgent == nil {
                
                selectedAgentInTableView = nil
                
                performSegue(withIdentifier: Identifiers.addOrEditAgentSegue, sender: nil)
                
            } else {
                
                tableView.selectRow(at: indexPathOfSelectedAgent, animated: false, scrollPosition: .none)
                
            }
            
        }
        
    }
    
    
    // MARK: - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Identifiers.addOrEditAgentSegue {
            
            // Instantiate new AddOrEditAgentViewController
            let navigationController = segue.destination as! UINavigationController
            let storyboard = navigationController.storyboard!
            
            if sender == nil {
                
                let blankViewController = storyboard.instantiateViewController(withIdentifier: Identifiers.blankViewControllerStoryboardId) as! BlankViewController
                navigationController.viewControllers[0] = blankViewController
                
            } else {
                
                let addOrEditAgentViewController = storyboard.instantiateViewController(withIdentifier: Identifiers.addAgentStoryboardId) as! AddOrEditAgentViewController
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
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: agentEntityName)
        
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
            
            selectedAgentInTableView = anObject as! Agent
            
            
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
        
        // 1. All agents have been deleted
        if tableView.numberOfRows(inSection: 0) == 0 {
            
            selectedAgentInTableView = nil
            
            performSegue(withIdentifier: Identifiers.addOrEditAgentSegue, sender: nil)
            
            return
            
        }
        
        // 2. Editing or adding an agent
        if (changeType == NSFetchedResultsChangeType.move) ||  (changeType == NSFetchedResultsChangeType.insert) {
            
            let firstRowIndexPath = IndexPath(row: 0, section: 0)
            
            tableView.selectRow(at: firstRowIndexPath, animated: false, scrollPosition: .top)
            
            return
            
        }
        
        // 3. Deleting an agent
        if (changeType == NSFetchedResultsChangeType.delete) {
            
            selectRowForSelectedAgent()
            
        }
        
        
        // 4. Set the changeType to nil
        changeType = nil
        
    }
    
}




















