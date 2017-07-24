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
        
        let agentEntity = NSEntityDescription.entity(forEntityName: agentEntityName, in: managedObjectContext)!
        let agent = Agent(entity: agentEntity, insertInto: managedObjectContext)
        
        let uniqueId = UUID().uuidString
        agent.uniqueId = uniqueId
        
        agent.lastUpdate = Date()
        
        return agent
        
    }
    
    func deleteAgent(_ agent: Agent) {
        
        managedObjectContext.delete(agent)
        
    }
    
    
    func numberOfAgents() -> Int {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: agentEntityName)
        
        if let numberOfAgents = try? managedObjectContext.count(for: fetchRequest) {
            
            return numberOfAgents
            
        } else {
            
            return 0
            
        }
        
    }
    
    
    func agentsSortedByName() -> [Agent]? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: agentEntityName)
        let sortByNameDescriptor = NSSortDescriptor(key: agentNameKey, ascending: true)
        fetchRequest.sortDescriptors = [sortByNameDescriptor]
        
        var agents: [Agent]?
        
        do {
            
            agents = try managedObjectContext.fetch(fetchRequest) as? [Agent]
            
        } catch {
            
            return nil
            
        }
        
        return agents
        
    }
    
    func fetchAgentForUniqueId(_ uniqueId: String) -> Agent? {
        
        var agent: Agent?
        
        let agentForUniqueIdFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: agentEntityName)
        
        agentForUniqueIdFetchRequest.predicate = NSPredicate(format: "uniqueId == %@", uniqueId)
        
        do {
            
            let agents = try managedObjectContext.fetch(agentForUniqueIdFetchRequest) as! [Agent]
            
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
        
        _ = insertNewTest()
        
        insertSampleDataStatus()
        
    }
    
    
    func insertNewAgentWithSampleData(_ sampleAgentDictionary: [String: String]) {
        
        let agentEntity = NSEntityDescription.entity(forEntityName: agentEntityName, in: managedObjectContext)!
        let agent = Agent(entity: agentEntity, insertInto: managedObjectContext)
        
        agent.agentName = sampleAgentDictionary[SampleAgentsDictionaryKeys.agentName]!
        agent.agentDescription = sampleAgentDictionary[SampleAgentsDictionaryKeys.agentDescription]!
        agent.clientAccessToken = sampleAgentDictionary[SampleAgentsDictionaryKeys.clientAccessToken]!
        
        let uniqueId = UUID().uuidString
        agent.uniqueId = uniqueId
        
        agent.lastUpdate = Date()

        
    }
    
    
    
    func insertSampleDataStatus() {
        
        let sampleDataStatusEntity = NSEntityDescription.entity(forEntityName: sampleDataStatusEntityName, in: managedObjectContext)!
        
        let _ = SampleDataStatus(entity: sampleDataStatusEntity, insertInto: managedObjectContext)
        
    }
    
    
    func fetchSampleDataStatus() -> SampleDataStatus? {
        
        var sampleDataStatus: SampleDataStatus?
        
        let sampleDataStatusFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: sampleDataStatusEntityName)
        
        do {
            
            let results = try managedObjectContext.fetch(sampleDataStatusFetchRequest) as! [SampleDataStatus]
            
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
        
        let testEntity = NSEntityDescription.entity(forEntityName: testEntityName, in: managedObjectContext)!
        
        let test = Test(entity: testEntity, insertInto: managedObjectContext)
        
        test.lastUpdate = Date()
        
        return test
        
    }
    
    
    func deleteTest(_ test: Test) {
        
        managedObjectContext.delete(test)
        
    }
    
}


// MARK: - AI Messages
extension CoreDataManager {
    
    func insertMessage(agent: Agent, test: Test, chatPosition: String, messageText: String, senderId: String) {
        
        let messageEntity = NSEntityDescription.entity(forEntityName: messageEntityName, in: managedObjectContext)!
        
        let message = Message(entity: messageEntity, insertInto: managedObjectContext)
        
        message.agent = agent
        message.test = test
        message.chatPosition = chatPosition
        message.messageText = messageText
        message.senderId = senderId
        message.messageDate = Date()

    }
    
    
    func deleteMessagesForTest(_ test: Test) {
        
        guard let messages = test.messages else { return }
        
        guard messages.count > 0 else { return }
        
        for message in messages {
            
            managedObjectContext.delete(message as! NSManagedObject)
            
        }
        
    }
    
    
    func fetchMessagesForTest(_ test: Test, agent: Agent, chatPosition: String) -> [Message]? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: messageEntityName)
        
        let sortByNameDescriptor = NSSortDescriptor(key: messageDateKey, ascending: true)
        fetchRequest.sortDescriptors = [sortByNameDescriptor]
        
        fetchRequest.predicate = NSPredicate(format: "test == %@ AND agent ==  %@ AND chatPosition == %@", test, agent, chatPosition)
        
        var messages: [Message]?
        
        do {
            
            messages = try managedObjectContext.fetch(fetchRequest) as? [Message]
            
        } catch {
            
            return nil
            
        }
        
        return messages
        
        
    }
    
}


