//
//  Agent+CoreDataProperties.swift
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

extension Agent {

    @NSManaged var agentDescription: String?
    @NSManaged var agentName: String
    @NSManaged var clientAccessToken: String?
    @NSManaged var lastUpdate: Date
    @NSManaged var uniqueId: String
    @NSManaged var messages: NSSet?

}
