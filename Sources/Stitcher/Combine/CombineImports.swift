//
//  CombineImports.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 12/3/24.
//

#if canImport(Combine)
import Combine
import OpenCombine

//    platforms: [
//        .iOS(.v13),
//        .macOS(.v10_15),
//        .macCatalyst(.v13),
//        .tvOS(.v13),
//        .watchOS(.v6),
//        .visionOS(.v1)
//    ],

// @available(iOS 13.0, macOS 10.15, macCatalyst 13.0, tvOS 13.0, watchOS 6.0, visionOS 1.0, *)

public typealias PassthroughSubject = Combine.PassthroughSubject
public typealias AnyCancellable = Combine.AnyCancellable
public typealias AnyPublisher = Combine.AnyPublisher
public typealias Publisher = Combine.Publisher

#else
import OpenCombine

public typealias PassthroughSubject = OpenCombine.PassthroughSubject
public typealias AnyCancellable = OpenCombine.AnyCancellable
public typealias AnyPublisher = OpenCombine.AnyPublisher
public typealias Publisher = OpenCombine.Publisher

#endif
