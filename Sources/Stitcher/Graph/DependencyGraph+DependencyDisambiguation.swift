//
//  DependencyGraph+DependencyDisambiguation.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 5/4/22.
//

import Foundation

extension DependencyGraph {
    
    func determineDependencyByPriority(in matches: [Dependency]) -> Dependency? {
        let sortedMatches = matches
            .map({ (priority: $0.priority, dependency: $0) })
            .sorted(by: { $0.priority > $1.priority })
        
        guard sortedMatches.count > 1 else {
            return sortedMatches.first?.dependency
        }
        
        if sortedMatches[0].priority == sortedMatches[1].priority {
            return nil
        } else {
            return sortedMatches.first?.dependency
        }
    }
}
