//
//  DeepDiffTests.swift
//  DeepDiffTests
//
//  Created by Ian Terrell on 6/27/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import XCTest
@testable import DeepDiff

extension Int: SequenceDiffable {
    public func identifiedSame(other: Int) -> Bool {
        return self == other
    }
}

class DeepDiffTests: XCTestCase {
    
    func testEmpty() {
        let x: [Int] = []
        let y: [Int] = []
        let (diff, updates) = x.deepDiff(y)
        XCTAssertEqual([], diff)
        XCTAssertEqual([], updates)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
