//
//  Message+CoreDataProperties.swift
//  AI Tester
//
//  Created by Andrei Sadovnicov on 14/04/16.
//  Copyright © 2016 Andrei Sadovnicov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Message {

    @NSManaged var chatPosition: String
    @NSManaged var messageDate: NSDate
    @NSManaged var messageText: String
    @NSManaged var senderId: String
    @NSManaged var agent: Agent
    @NSManaged var test: Test

}
