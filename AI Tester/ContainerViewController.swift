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
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        underKeyboardLayoutConstraint.setup(keyboardHeightLayoutConstraint, view: view, bottomLayoutGuide: bottomLayoutGuide)
        
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        test.lastRun = NSDate()
        
        coreDataManager.saveContext()
    }
    

    // MARK: - Black status bar
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        
        return UIStatusBarStyle.Default
        
    }
    
    
    // MARK: - @IBActions
    func testsButtonTapped() {
        
        view.endEditing(true)
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func sendButtonTapped(sender: AnyObject) {
        
        guard let textToSend = inputTextField.text else { return }
        guard !textToSend.isEmpty else { return }
        guard Reachability.isConnectedToNetwork() else { showNoInternetAlert(); return }
        
        inputTextField.text = ""
        
        let userInfoDictionary: [NSObject: AnyObject] = [Notifications.messageTextKey: textToSend, Notifications.messageDateKey: NSDate()]
        
        NSNotificationCenter.defaultCenter().postNotificationName(Notifications.inputTextFieldNotification, object: nil, userInfo: userInfoDictionary)
        
    }
    
    
    // MARK: - Storyboard segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
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
    
    func passAgentToChatViewController(agentUniqueId: String?, segue: UIStoryboardSegue, chatPosition: String) {
        
        let navigationController = segue.destinationViewController as! UINavigationController
        
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
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
}


// MARK: - EXTENSIONS

// MARK: - UITextField delegate
extension ContainerViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        sendButtonTapped(self)
        
        return true
        
    }
    
}



















