//
//  Extensions.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 15/3/24.
//

import Foundation

extension Array {
    
    func slice(
        at sliceIndex: Int,
        outOf total: Int
    ) -> ArraySlice<Element> {
        
        guard !self.isEmpty, sliceIndex < total else {
            return []
        }
        
        let sliceSize = Int(floor(Double(count) / Double(total)))
        let start = sliceIndex * sliceSize
        var end = start + sliceSize
        
        if sliceIndex == total - 1 {
            end = endIndex
        }
        
        return self[start..<end]
    }
}
