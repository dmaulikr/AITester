//
//  Test+CoreDataProperties.swift
//  AI Tester
//
//  Created by Andrei Sadovnicov on 13/04/16.
//  Copyright © 2016 Andrei Sadovnicov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Test {

    @NSManaged var lastUpdate: Date
    @NSManaged var lastRun: Date?
    @NSManaged var leftAgentUniqueId: String?
    @NSManaged var middleAgentUniqueId: String?
    @NSManaged var rightAgentUniqueId: String?
    @NSManaged var testDescription: String?
    @NSManaged var testName: String
    @NSManaged var messages: NSSet?

}
