//
//  InjectionError.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 25/12/21.
//

import Foundation

public struct InjectionError<StitcherError: Error>: Error {
    let cause: StitcherError
}
