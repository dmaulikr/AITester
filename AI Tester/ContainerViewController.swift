//
//  ContainerViewController.swift
//  AI Tester
//
//  Created by Andrei Sadovnicov on 12/04/16.
//  Copyright © 2016 Andrei Sadovnicov. All rights reserved.
//

import UIKit
import UnderKeyboard

class ContainerViewController: UIViewController {

    // MARK: - PROPERTIES
    
    // MARK: - Core data manager
    var coreDataManager: CoreDataManager!
    
    // MARK: - Agents
    var leftAgentUniqueId: String?
    var middleAgentUniqueId: String?
    var rightAgentUniqueId: String?
    
    // MARK: - Test
    var test: Test!
    
    // MARK: - @IBOutlets
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    
    // MARK: - Keyboard management
    let underKeyboardLayoutConstraint = UnderKeyboardLayoutConstraint()
    
    // MARK: - METHODS
    
    // MARK: - View controller life cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        underKeyboardLayoutConstraint.setup(keyboardHeightLayoutConstraint, view: view, bottomLayoutGuide: bottomLayoutGuide)
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        test.lastRun = Date()
        
        coreDataManager.saveContext()
    }
    

    // MARK: - Black status bar
    override var preferredStatusBarStyle : UIStatusBarStyle {
        
        return UIStatusBarStyle.default
        
    }
    
    
    // MARK: - @IBActions
    func testsButtonTapped() {
        
        view.endEditing(true)
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func sendButtonTapped(_ sender: AnyObject) {
        
        guard let textToSend = inputTextField.text else { return }
        guard !textToSend.isEmpty else { return }
        guard Reachability.isConnectedToNetwork() else { showNoInternetAlert(); return }
        
        inputTextField.text = ""
        
        let userInfoDictionary: [AnyHashable: Any] = [Notifications.messageTextKey: textToSend, Notifications.messageDateKey: Date()]
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: Notifications.inputTextFieldNotification), object: nil, userInfo: userInfoDictionary)
        
    }
    
    
    // MARK: - Storyboard segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Identifiers.containerToLeftChatSegue {
            
            passAgentToChatViewController(leftAgentUniqueId, segue: segue, chatPosition: ChatPositions.leftChat)
            
        }
        
        
        if segue.identifier == Identifiers.containerToMiddleChatSegue {
            
            passAgentToChatViewController(middleAgentUniqueId, segue: segue, chatPosition: ChatPositions.middleChat)
            
        }
        
        
        if segue.identifier == Identifiers.containerToRightChatSegue {
            
            passAgentToChatViewController(rightAgentUniqueId, segue: segue, chatPosition: ChatPositions.rightChat)
            
        }
        
    }
    
    func passAgentToChatViewController(_ agentUniqueId: String?, segue: UIStoryboardSegue, chatPosition: String) {
        
        let navigationController = segue.destination as! UINavigationController
        
        let chatViewController = navigationController.topViewController as! ChatViewController
        
        chatViewController.agentUniqueId = agentUniqueId
        chatViewController.coreDataManager = coreDataManager
        chatViewController.chatPosition = chatPosition
        chatViewController.test = test
        
        chatViewController.containerViewController = self
        
    }
    
    
    // MARK: - No internet alert
    func showNoInternetAlert() {
        
        let title = NSLocalizedString("No internet", comment: "")
        let message = NSLocalizedString("There seem to be no internet connection. Please turn on the internet on your device and try again.", comment: "")
        let cancelButtonTitle = NSLocalizedString("Dismiss", comment: "")
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}


// MARK: - EXTENSIONS

// MARK: - UITextField delegate
extension ContainerViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        sendButtonTapped(self)
        
        return true
        
    }
    
}



















