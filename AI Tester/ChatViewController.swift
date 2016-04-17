//
//  ChatViewController.swift
//  AI Tester
//
//  Created by Andrei Sadovnicov on 12/04/16.
//  Copyright © 2016 Andrei Sadovnicov. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import ApiAI
import SwiftyJSON

// MARK: - CLASS
class ChatViewController: JSQMessagesViewController {

    // MARK: - PROPERTIES
    
    // MARK: - Agent
    var agentUniqueId: String?
    var agent: Agent?
    
    // MARK: - Test
    var test: Test!
    
    // MARK: - Core data manager
    var coreDataManager: CoreDataManager!
    
    // MARK: - Api.ai
    lazy var apiAi = ApiAI()
    
    // MARK: - Api.ai responses
    let emptySpeechResponse = "=Sorry, I don't have an answer.="
    let errorSpeechResponse = "=Something is wrong. Please check if you use a correct Client Access Token, as well if you are connected to internet.="
    
    // MARK: - Chat position
    var chatPosition: String!
    
    // MARK: - Messages
    var messages = [JSQMessage]()
    let aiTester = "aiTester"
    
    // MARK: - Message bubbles
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    // MARK: - Container view controller
    var containerViewController: ContainerViewController!
    
    // MARK: - METHODS
    
    // MARK: - View controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let agentUniqueId = agentUniqueId {
            
            if let agentForUniqueId = coreDataManager.fetchAgentForUniqueId(agentUniqueId) {
                
                agent = agentForUniqueId
                
            }
            
        }
        
        configureChat()
        
        loadPreviousMessages()
        
        setupApiAi()
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didReiveInputTextFieldNotification(_:)), name: Notifications.inputTextFieldNotification, object: nil)
        
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }
    
    // MARK: - @IBActions
    @IBAction func testsButtonTapped(sender: UIBarButtonItem) {
        
        containerViewController.testsButtonTapped()
        
    }
    
    
    // MARK: - Message data
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        return messages[indexPath.item]
        
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messages.count
        
    }

    func addMessage(id: String, text: String) {
        
        let message = JSQMessage(senderId: id, displayName: "", text: text)
        
        messages.append(message)
        
        coreDataManager.insertMessage(agent: agent!, test: test, chatPosition: chatPosition, messageText: text, senderId: id)

    }
    
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        addMessage(senderId, text: text)
        
        finishSendingMessage()
        
        
    }
    
    func didReiveInputTextFieldNotification(notification: NSNotification) {
        
        guard agent != nil else { return }
        
        guard let userInfo = notification.userInfo else { return }
        guard let messageText = userInfo[Notifications.messageTextKey] as? String else { return }
        guard let messageDate = userInfo[Notifications.messageDateKey] as? NSDate else { return }
        
        didPressSendButton(nil, withMessageText: messageText, senderId: senderId, senderDisplayName: senderDisplayName, date: messageDate)
        
        getAnswerFromApiAiForText(messageText)
    }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
    
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            
            return outgoingBubbleImageView
            
        } else {
            
            return incomingBubbleImageView
            
        }
        
    }
    
    func loadPreviousMessages() {
        
        guard agent != nil else { return }
        
        guard let previousMessages = test.messages else { return }
        guard previousMessages.count > 0 else { return }
        
        let savedMessages = coreDataManager.fetchMessagesForTest(test, agent: agent!, chatPosition: chatPosition)!
        
        for savedMessage in savedMessages {
            
            let message = JSQMessage(senderId: savedMessage.senderId, displayName: "", text: savedMessage.messageText)
            
            messages.append(message)
            
        }
        
        
        finishReceivingMessage()
        
    }
    
    
    // MARK: - Remove avatars support
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        return nil
        
    }
    
    
    // MARK: - Set text color
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            
            cell.textView!.textColor = UIColor.whiteColor()
            
        } else {
            
            cell.textView!.textColor = UIColor.blackColor()
            
        }
        
        cell.textView.linkTextAttributes = [
            NSForegroundColorAttributeName: UIColor.blueColor(),
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue
        ]
        
        return cell
    }
    
    // MARK: - Chat configuration
    func configureChat() {
        
        // Set chat title
        title = agent?.agentName
        
        senderId = aiTester
        senderDisplayName = ""
        
        // Set bubbles
        setupBubbles()
        
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
        
        // No input bar
        inputToolbar.removeFromSuperview()
        
    }
    
    func setupBubbles() {
        
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        
        collectionView.collectionViewLayout.messageBubbleLeftRightMargin = 40.0
        
    }
    
    
    
}


// MARK: - EXTENSIONS

// MARK: - Api.ai methods
extension ChatViewController {
    
    func setupApiAi() {
        
        guard agent != nil else { return }
        
        let configuration = AIDefaultConfiguration()
        
        if let clientAccessToken = agent?.clientAccessToken {
            
            configuration.clientAccessToken = clientAccessToken
            
        } else {
            
            configuration.clientAccessToken = ""
            
        }
        
        apiAi.configuration = configuration
        apiAi.lang = "en"
        
    }
    
    
    func getAnswerFromApiAiForText(text: String) {
        
        let request = apiAi.textRequest()
        request.query = text
        
        request.setCompletionBlockSuccess({ request, response in
            
            let json = JSON(response)
            
            let apiAiAnswer = json["result"]["fulfillment"]["speech"].stringValue
            
            dispatch_async(dispatch_get_main_queue()) {
                
                if apiAiAnswer == "" {
                    
                    self.addMessage(self.agentUniqueId!, text: self.emptySpeechResponse)
                    
                } else {
                    
                    self.addMessage(self.agentUniqueId!, text: apiAiAnswer)
                }
                
                self.finishReceivingMessage()
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                self.showTypingIndicator = false
                
            }
            
            }, failure: { request, error in
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    
                    self.showTypingIndicator = false
                    
                    self.addMessage(self.agentUniqueId!, text: self.errorSpeechResponse)
                    
                    self.finishReceivingMessage()
                }
                
                
        })
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        showTypingIndicator = true
        
        apiAi.enqueue(request)
        
    }

}














