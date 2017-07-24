//
//  AddOrEditAgentViewController.swift
//  AI Tester
//
//  Created by Andrei Sadovnicov on 04/04/16.
//  Copyright © 2016 Andrei Sadovnicov. All rights reserved.
//

import UIKit

// MARK: - CLASS
class AddOrEditAgentViewController: UIViewController {

    // MARK: - PROPERTIES
    
    // MARK: - @IBOutlets
    @IBOutlet weak var agentNameTextField: UITextField!
    @IBOutlet weak var agentDescriptionTextField: UITextField!
    @IBOutlet weak var clientAccessTokenTextField: UITextField!
    @IBOutlet weak var lastUpdateTextField: UITextField!
    
    // MARK: - Core data
    var coreDataManager: CoreDataManager!
    var agent: Agent!
    
    
    
    // MARK: - METHODS
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Agent Info"
        
        populateTextFields()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textInTextFieldsChanged), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        coreDataManager.saveContext()
        
        NotificationCenter.default.removeObserver(self)
        
    }
    

    
    // MARK: - Populate text fields
    func populateTextFields() {
        
        agentNameTextField.text = agent.agentName
        agentDescriptionTextField.text = agent.agentDescription
        clientAccessTokenTextField.text = agent.clientAccessToken
        
    }
    
    // MARK: - Text in text fields changed
    func textInTextFieldsChanged() {
        
        saveAgentInfo()
        
    }
    
    
    // MARK: - Save agent info
    func saveAgentInfo() {
        
        agent.lastUpdate = Date()
        agent.agentName = agentNameTextField.text!
        agent.agentDescription = agentDescriptionTextField.text
        agent.clientAccessToken = clientAccessTokenTextField.text

    }
    
    
    // MARK: - Dismiss keyboard
    func dismissKeyboard() {
        
        view.endEditing(true)
        
    }
    
}









