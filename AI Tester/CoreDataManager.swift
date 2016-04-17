//
//  CoreDataManager.swift
//  AI Tester
//
//  Created by Andrei Sadovnicov on 04/04/16.
//  Copyright © 2016 Andrei Sadovnicov. All rights reserved.
//

import Foundation
import CoreData

// MARK: - CLASS
class CoreDataManager: NSObject {
    
    // MARK: - PROPERTIES
    
    // MARK: - Managed object context
    var managedObjectContext: NSManagedObjectContext
    
    // MARK: - Entity names
    let agentEntityName = "Agent"
    let testEntityName = "Test"
    let sampleDataStatusEntityName = "SampleDataStatus"
    let messageEntityName = "Message"
    
    // MARK: - Keys
    let agentNameKey = "agentName"
    let messageDateKey = "messageDate"
    
    // MARK: - INITIALIZERS
    init(managedObjectContext: NSManagedObjectContext) {
        
        self.managedObjectContext = managedObjectContext
        
        super.init()
        
        
    }
    
    
    // MARK: - METHODS
    
    // MARK: - Save managed object context
    func saveContext () {
        
        if managedObjectContext.hasChanges {
            
            do {
                
                try managedObjectContext.save()
                
            } catch let error as NSError {
                
                // Better to crash rather than save corrupted data.
                fatalError(error.localizedDescription)
                
            }
        }
    }
    
}


// MARK: - EXTENSIONS

// MARK: - AI Agents
extension CoreDataManager {
    
    func insertNewAgent() -> Agent {
        
        let agentEntity = NSEntityDescription.entityForName(agentEntityName, inManagedObjectContext: managedObjectContext)!
        let agent = Agent(entity: agentEntity, insertIntoManagedObjectContext: managedObjectContext)
        
        let uniqueId = NSUUID().UUIDString
        agent.uniqueId = uniqueId
        
        agent.lastUpdate = NSDate()
        
        return agent
        
    }
    
    func deleteAgent(agent: Agent) {
        
        managedObjectContext.deleteObject(agent)
        
    }
    
    
    func numberOfAgents() -> Int {
        
        let fetchRequest = NSFetchRequest(entityName: agentEntityName)
        
        let numberOfAgents = managedObjectContext.countForFetchRequest(fetchRequest, error: nil)
        
        return numberOfAgents
        
    }
    
    
    func agentsSortedByName() -> [Agent]? {
        
        let fetchRequest = NSFetchRequest(entityName: agentEntityName)
        let sortByNameDescriptor = NSSortDescriptor(key: agentNameKey, ascending: true)
        fetchRequest.sortDescriptors = [sortByNameDescriptor]
        
        var agents: [Agent]?
        
        do {
            
            agents = try managedObjectContext.executeFetchRequest(fetchRequest) as? [Agent]
            
        } catch {
            
            return nil
            
        }
        
        return agents
        
    }
    
    func fetchAgentForUniqueId(uniqueId: String) -> Agent? {
        
        var agent: Agent?
        
        let agentForUniqueIdFetchRequest = NSFetchRequest(entityName: agentEntityName)
        
        agentForUniqueIdFetchRequest.predicate = NSPredicate(format: "uniqueId == %@", uniqueId)
        
        do {
            
            let agents = try managedObjectContext.executeFetchRequest(agentForUniqueIdFetchRequest) as! [Agent]
            
            guard agents.count > 0 else { return nil }
            
            agent = agents[0]
            
            
        } catch {
            
            // Better to crash than to have corrupted data.
            fatalError("Error fetching pin.")
            
        }
        
        return agent
    
    }
    
    
}


// MARK: - Import sample data
extension CoreDataManager {
    
    func importSampleData() {
        
        let sampleDataStatus = fetchSampleDataStatus()
        
        guard sampleDataStatus == nil else { return }
        
        let sampleData = ApiAiSampleData()
        
        let sampleAgents = sampleData.sampleAgents()
        
        for sampleAgent in sampleAgents {
            
            insertNewAgentWithSampleData(sampleAgent)
            
        }
        
        insertNewTest()
        
        insertSampleDataStatus()
        
    }
    
    
    func insertNewAgentWithSampleData(sampleAgentDictionary: [String: String]) {
        
        let agentEntity = NSEntityDescription.entityForName(agentEntityName, inManagedObjectContext: managedObjectContext)!
        let agent = Agent(entity: agentEntity, insertIntoManagedObjectContext: managedObjectContext)
        
        agent.agentName = sampleAgentDictionary[SampleAgentsDictionaryKeys.agentName]!
        agent.agentDescription = sampleAgentDictionary[SampleAgentsDictionaryKeys.agentDescription]!
        agent.clientAccessToken = sampleAgentDictionary[SampleAgentsDictionaryKeys.clientAccessToken]!
        
        let uniqueId = NSUUID().UUIDString
        agent.uniqueId = uniqueId
        
        agent.lastUpdate = NSDate()

        
    }
    
    
    
    func insertSampleDataStatus() {
        
        let sampleDataStatusEntity = NSEntityDescription.entityForName(sampleDataStatusEntityName, inManagedObjectContext: managedObjectContext)!
        
        let _ = SampleDataStatus(entity: sampleDataStatusEntity, insertIntoManagedObjectContext: managedObjectContext)
        
    }
    
    
    func fetchSampleDataStatus() -> SampleDataStatus? {
        
        var sampleDataStatus: SampleDataStatus?
        
        let sampleDataStatusFetchRequest = NSFetchRequest(entityName: sampleDataStatusEntityName)
        
        do {
            
            let results = try managedObjectContext.executeFetchRequest(sampleDataStatusFetchRequest) as! [SampleDataStatus]
            
            guard results.count > 0 else { return nil }
            
            sampleDataStatus = results[0]
            
        } catch {
            
            // Better to crash than to have corrupted data.
            fatalError("Error fetching pin.")
            
        }
        
        return sampleDataStatus
        
    }
    
    
}



// MARK: - AI Tests
extension CoreDataManager {
    
    func insertNewTest() -> Test {
        
        let testEntity = NSEntityDescription.entityForName(testEntityName, inManagedObjectContext: managedObjectContext)!
        
        let test = Test(entity: testEntity, insertIntoManagedObjectContext: managedObjectContext)
        
        test.lastUpdate = NSDate()
        
        return test
        
    }
    
    
    func deleteTest(test: Test) {
        
        managedObjectContext.deleteObject(test)
        
    }
    
}


// MARK: - AI Messages
extension CoreDataManager {
    
    func insertMessage(agent agent: Agent, test: Test, chatPosition: String, messageText: String, senderId: String) {
        
        let messageEntity = NSEntityDescription.entityForName(messageEntityName, inManagedObjectContext: managedObjectContext)!
        
        let message = Message(entity: messageEntity, insertIntoManagedObjectContext: managedObjectContext)
        
        message.agent = agent
        message.test = test
        message.chatPosition = chatPosition
        message.messageText = messageText
        message.senderId = senderId
        message.messageDate = NSDate()

    }
    
    
    func deleteMessagesForTest(test: Test) {
        
        guard let messages = test.messages else { return }
        
        guard messages.count > 0 else { return }
        
        for message in messages {
            
            managedObjectContext.deleteObject(message as! NSManagedObject)
            
        }
        
    }
    
    
    func fetchMessagesForTest(test: Test, agent: Agent, chatPosition: String) -> [Message]? {
        
        let fetchRequest = NSFetchRequest(entityName: messageEntityName)
        
        let sortByNameDescriptor = NSSortDescriptor(key: messageDateKey, ascending: true)
        fetchRequest.sortDescriptors = [sortByNameDescriptor]
        
        fetchRequest.predicate = NSPredicate(format: "test == %@ AND agent ==  %@ AND chatPosition == %@", test, agent, chatPosition)
        
        var messages: [Message]?
        
        do {
            
            messages = try managedObjectContext.executeFetchRequest(fetchRequest) as? [Message]
            
        } catch {
            
            return nil
            
        }
        
        return messages
        
        
    }
    
}


