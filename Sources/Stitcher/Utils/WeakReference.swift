//
//  WeakReference.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 26/2/24.
//

import Foundation

class WeakReference<Pointee: AnyObject> {
    
    private(set) weak var pointee: Pointee?
    
    var isReleased: Bool {
        pointee == nil
    }
    
    init(_ pointee: Pointee) {
        self.pointee = pointee
    }
    
    func release() {
        pointee = nil
    }
}
