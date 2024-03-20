//
//  Pipeline.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 12/3/24.
//

import Foundation
import OpenCombine
import OpenCombineDispatch

#if canImport(Combine)
import Combine
#endif

protocol Pipeline {
    associatedtype Output
    
    var erasedProvider: Any { get }
}

// MARK: Pipeline + CollectByCount

extension Pipeline {
    
    public func collect(
        _ count: Int
    ) -> AnyPipeline<Array<Output>> {
        
#if canImport(Combine)
        
        if #available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *),
           let provider = erasedProvider as? Combine.AnyPublisher<Output, Never> {
            return provider
                .collect(count)
                .erasedToAnyPipeline()
        }

#endif
        if let provider = erasedProvider as? OpenCombine.AnyPublisher<Output, Never> {
            return provider
                .collect(count)
                .erasedToAnyPipeline()
        }
        
        return AnyPipeline()
    }
}

// MARK: Pipeline + Debounce

extension Pipeline {
    
    func debounce(
        for dueTime: TimeInterval,
        schedulerQos: DispatchQoS
    ) -> AnyPipeline<Output> {
        
#if canImport(Combine)
        
        if #available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *),
           let provider = erasedProvider as? Combine.AnyPublisher<Output, Never> {
            return provider
                .debounce(
                    for: DispatchQueue.SchedulerTimeType.Stride(floatLiteral: dueTime),
                    scheduler: DispatchQueue.global(
                        qos: schedulerQos.qosClass
                    )
                )
                .erasedToAnyPipeline()
        }

#endif
        if let provider = erasedProvider as? OpenCombine.AnyPublisher<Output, Never> {
            return provider
                .debounce(
                    for: DispatchQueue.OCombine.SchedulerTimeType.Stride(floatLiteral: dueTime),
                    scheduler: DispatchQueue.global(
                        qos: schedulerQos.qosClass
                    ).ocombine
                )
                .erasedToAnyPipeline()
        }
        
        return AnyPipeline()
    }
}

// MARK: Pipeline + Sink

extension Pipeline {
    
    func sink(
        receiveValue: @escaping (Output) -> Void
    ) -> AnyPipelineCancellable {
        
#if canImport(Combine)
        
        if #available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *),
           let provider = erasedProvider as? Combine.AnyPublisher<Output, Never> {
            return AnyPipelineCancellable(provider.sink(receiveValue: receiveValue))
        }

#endif
        if let provider = erasedProvider as? OpenCombine.AnyPublisher<Output, Never> {
            return AnyPipelineCancellable(provider.sink(receiveValue: receiveValue))
        }
        
        return AnyPipelineCancellable()
    }
}
