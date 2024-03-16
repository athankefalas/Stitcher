//
//  IndexingKeyTests.swift
//  
//
//  Created by Αθανάσιος Κεφαλάς on 1/3/24.
//

import XCTest
@testable import Stitcher

final class IndexingKeyTests: XCTestCase {

    func test_indexingKey_name() {
        let name = "A"
        let locator = DependencyLocator.name(name)
        let proposal = DependencyLocator.MatchProposal(byName: name)
        XCTAssert(locator.indexingKeys().count == 1)
        XCTAssert(locator.indexingKeys().contains(proposal.indexingKey))
    }
    
    func test_indexingKey_type() {
        let locator = DependencyLocator.type(Alpha.self)
        let proposal = DependencyLocator.MatchProposal(byType: Alpha.self)
        XCTAssert(locator.indexingKeys().count == 1)
        XCTAssert(locator.indexingKeys().contains(proposal.indexingKey))
    }
    
    func test_indexingKey_typeAndProtocol() {
        let locator = DependencyLocator.type(Alpha.self, LetterClassImplementing.self)
        let typeProposal = DependencyLocator.MatchProposal(byType: Alpha.self)
        let protocolProposal = DependencyLocator.MatchProposal(byType: LetterClassImplementing.self)
        
        XCTAssert(locator.indexingKeys().count == 2)
        XCTAssert(locator.indexingKeys().contains(typeProposal.indexingKey))
        XCTAssert(locator.indexingKeys().contains(protocolProposal.indexingKey))
    }
    
    func test_indexingKey_value() {
        let value = "A"
        let locator = DependencyLocator.value(value)
        let proposal = DependencyLocator.MatchProposal(byValue: value)
        XCTAssert(locator.indexingKeys().count == 1)
        XCTAssert(locator.indexingKeys().contains(proposal.indexingKey))
    }

}
