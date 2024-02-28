//
//  DependencyGroupRepresenting.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 28/2/24.
//

import Foundation

protocol DependencyGroupRepresenting {
    
    func dependencies() -> DependencyContainer.DependenciesRegistrar
}
