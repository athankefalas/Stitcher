//
//  DependencyContainerError.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 6/3/22.
//

import Foundation

public enum DependencyContainerError: Error {
    case containerMergeFailed
    
    // Validation Errors
    case unsatisfiableRequirement(Requirement)
    case ambiguousDependencyDetected(Requirement)
    
    // Injection Errors
    case missingDependency(String)
    case ambiguousDependency(String)
}
