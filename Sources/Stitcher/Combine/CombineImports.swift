//
//  CombineImports.swift
//
//
//  Created by Αθανάσιος Κεφαλάς on 12/3/24.
//

#if canImport(Combine)
import Combine

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
