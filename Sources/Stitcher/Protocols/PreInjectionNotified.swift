//
//  PreInjectionNotified.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 27/2/22.
//

import Foundation

/// A type that should be notified just before an instance of it is injected.
public protocol PreInjectionNotified {
    
    func willInject()
}
