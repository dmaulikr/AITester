//
//  AddOrEditTestViewController.swift
//  AI Tester
//
//  Created by Andrei Sadovnicov on 04/04/16.
//  Copyright © 2016 Andrei Sadovnicov. All rights reserved.
//

import UIKit

// MARK: - CLASS
class AddOrEditTestViewController: UIViewController {

    // MARK: - PROPERTIES
    
    // MARK: - @IBOutlets
    @IBOutlet weak var testNameTextField: UITextField!
    @IBOutlet weak var testDescriptionTextField: UITextField!
    @IBOutlet weak var lastRunTextField: UITextField!
    @IBOutlet weak var agentsPickerView: UIPickerView!
    
    // MARK: - Core data
    var coreDataManager: CoreDataManager!
    var test: Test!
    var agents: [Agent]!
    
    // MARK: - No agent
    let nullAgentText = "None"
    let nullAgentRow = 0
    
    // MARK: - Picker view components
    let leftComponent = 0
    let middleComponent = 1
    let rightComponent = 2
    
    // MARK: - Date formatter
    var dateFormatter: NSDateFormatter!
    
    // MARK: - METHODS
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Test Info"
        
        populateTextFields()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        agents = coreDataManager.agentsSortedByName()
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(textInTextFieldsChanged), name: UITextFieldTextDidChangeNotification, object: nil)
        
       selectAgentsInPickerViewForTest(test)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
        coreDataManager.saveContext()
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }

    
    // MARK: - @IBActions
    @IBAction func runTestButtonTapped(sender: UIButton) {
        
        performSegueWithIdentifier(Identifiers.testToRunTestSegue, sender: nil)
        
    }
    
    
    @IBAction func deleteTestHistoryButtonTapped(sender: UIButton) {
        
        showDeleteHistoryAlert()
        
    }
    
    
    // MARK: - Populate text fields
    func populateTextFields() {
        
        testNameTextField.text = test.testName
        testDescriptionTextField.text = test.testDescription

        if let lastRunDate = test.lastRun {
            
            let dateString = dateFormatter.stringFromDate(lastRunDate)
            
            lastRunTextField.text = dateString
            
        }
        
    }
    
    // MARK: - Text in text fields changed
    func textInTextFieldsChanged() {
        
        saveTestTextInfo()
        
    }
    
    
    // MARK: - Save test text info
    func saveTestTextInfo() {
        
        test.lastUpdate = NSDate()
        test.testName = testNameTextField.text!
        test.testDescription = testDescriptionTextField.text
        
    }
    
    
    // MARK: - Dismiss keyboard
    func dismissKeyboard() {
        
        view.endEditing(true)
        
    }
    
    
    // MARK: - Prepare for segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == Identifiers.testToRunTestSegue {
            
            let containerViewController = segue.destinationViewController as! ContainerViewController
            
                containerViewController.leftAgentUniqueId = test.leftAgentUniqueId
                containerViewController.middleAgentUniqueId = test.middleAgentUniqueId
                containerViewController.rightAgentUniqueId = test.rightAgentUniqueId
            
                containerViewController.test = test
            
                containerViewController.coreDataManager = coreDataManager
        }
        
    }
    

}


// MARK: - EXTENSIONS

// MARK: - UIPickerViewDataSource
extension AddOrEditTestViewController: UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        return 3
        
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        // There will be always one row for a case that there is no agent
        let numberOfRowsInPickerView = coreDataManager.numberOfAgents() + 1
        
        return numberOfRowsInPickerView
        
    }
    
}


// MARK: - UIPickerViewDelegate
extension AddOrEditTestViewController: UIPickerViewDelegate {
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if row == 0 {
            
            return nullAgentText
            
        }
        
        guard agents != nil else { return nil }
        
        let agentName = agents[row - 1].agentName
        
        return agentName
        
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        test.lastUpdate = NSDate()
        
        guard agents.count > 0 else { return }
        
        switch component {
            
        case leftComponent:
            
            if row == 0 {
                test.leftAgentUniqueId = nil
            } else {
                test.leftAgentUniqueId = agents[row - 1].uniqueId
            }
            
            
        case middleComponent:
            
            if row == 0 {
                test.middleAgentUniqueId = nil
            } else {
                test.middleAgentUniqueId = agents[row - 1].uniqueId
            }
            
            
        case rightComponent:
            
            if row == 0 {
                test.rightAgentUniqueId = nil
            } else {
                test.rightAgentUniqueId = agents[row - 1].uniqueId
            }
            
            
        default:
            
            return
            
        }
        
        
    }
    
    
}

// MARK: - UIPickerView selection
extension AddOrEditTestViewController {
    
    func selectAgentsInPickerViewForTest(test: Test) {
        
        // Left component
        if let leftSelectedAgentUniqueId = test.leftAgentUniqueId {
            
            selectRowForAgentWithUniqueId(leftSelectedAgentUniqueId, inComponent: leftComponent)
            
        } else {
            selectNullAgentRow(inComponent: leftComponent)
        }
        
        
        
        // Middle component
        if let middleSelectedAgentUniqueId = test.middleAgentUniqueId {
            
            selectRowForAgentWithUniqueId(middleSelectedAgentUniqueId, inComponent: middleComponent)
            
        } else {
            selectNullAgentRow(inComponent: middleComponent)
        }
        
        
        
        // Right component
        if let rightSelectedAgentUniqueId = test.rightAgentUniqueId {
            
            selectRowForAgentWithUniqueId(rightSelectedAgentUniqueId, inComponent: rightComponent)
            
        } else {
            selectNullAgentRow(inComponent: rightComponent)
        }
        
    }
    
    
    func selectNullAgentRow(inComponent component: Int) {
        
        agentsPickerView.selectRow(nullAgentRow, inComponent: component, animated: false)
        
    }
    
    func selectRowForAgentWithUniqueId(uniqueId: String, inComponent component: Int) {
        
        if let indexOfSelectedAgent = indexOfSelectedAgentWithUniqueId(uniqueId) {
            
            agentsPickerView.selectRow(indexOfSelectedAgent + 1, inComponent: component, animated: false)
            
        } else {
            
            selectNullAgentRow(inComponent: component)
            
        }
        
    }
    
    
    
    func indexOfSelectedAgentWithUniqueId(uniqueId: String) -> Int? {
        
        if let selectedAgent = coreDataManager.fetchAgentForUniqueId(uniqueId) {
            
            return agents.indexOf(selectedAgent)
            
        } else {
            
            return nil
            
        }
        
    }
    
    
}


extension AddOrEditTestViewController {

    func showDeleteHistoryAlert() {
        let title = NSLocalizedString("Delete test history", comment: "")
        let message = NSLocalizedString("Are you sure you want to delete this test's history?", comment: "")
        let cancelButtonTitle = NSLocalizedString("Cancel", comment: "")
        let otherButtonTitle = NSLocalizedString("Delete", comment: "")
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // Create the actions.
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel) { _ in
            
        }
        
        let otherAction = UIAlertAction(title: otherButtonTitle, style: .Destructive) { _ in
            self.coreDataManager.deleteMessagesForTest(self.test)
        }
        
        // Add the actions.
        alertController.addAction(cancelAction)
        alertController.addAction(otherAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
}
















