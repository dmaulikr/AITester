//
//  ApiAiSampleData.swift
//  AI Tester
//
//  Created by Andrei Sadovnicov on 13/04/16.
//  Copyright © 2016 Andrei Sadovnicov. All rights reserved.
//

import Foundation

struct ApiAiSampleData {
    
    // MARK: - Sample agents dictionaries
    let testAgent1Dictionary = [
        SampleAgentsDictionaryKeys.agentName: "Pizza Agent",
        SampleAgentsDictionaryKeys.agentDescription: "Agent designed for order pizza.",
        SampleAgentsDictionaryKeys.clientAccessToken: "a42137c5d0574f3988f046aed1f92475",
    ]
    
    let testAgent2Dictionary = [
        SampleAgentsDictionaryKeys.agentName: "Trained agent",
        SampleAgentsDictionaryKeys.agentDescription: "Agent capable to greet and suggest search engines.",
        SampleAgentsDictionaryKeys.clientAccessToken: "353886bf28e848ae891dc04fb216aba7",
    ]
    
    let testAgent3Dictionary = [
        SampleAgentsDictionaryKeys.agentName: "Untrained agent",
        SampleAgentsDictionaryKeys.agentDescription: "This is an agent who is untrained.",
        SampleAgentsDictionaryKeys.clientAccessToken: "fc8e168c32e249de8b705c7863bde8db",
    ]
    
    
    // MARK: - Array with sample agents
    func sampleAgents() -> [[String: String]] {
        
        return [testAgent1Dictionary, testAgent2Dictionary, testAgent3Dictionary]
        
    }
    
    
    
    
}