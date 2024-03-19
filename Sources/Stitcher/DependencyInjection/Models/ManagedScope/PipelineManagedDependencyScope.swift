//
//  PipelineManagedDependencyScope.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 12/3/24.
//

import Foundation

class PipelineManagedDependencyScope: ManagedDependencyScopeProviding {
    
    private let pipeline: AnyPipeline<Void>
    
    init(pipeline: AnyPipeline<Void>) {
        self.pipeline = pipeline
    }
    
    func onScopeInvalidated(perform action: @escaping () -> Void) -> ManagedDependencyScopeReceipt {
        return pipeline.sink(receiveValue: action)
    }
}
