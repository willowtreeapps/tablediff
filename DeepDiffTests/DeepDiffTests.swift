//
//  DeepDiffTests.swift
//  DeepDiffTests
//
//  Created by Ian Terrell on 6/27/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import XCTest
import DeepDiff

class EmptyTests: XCTestCase {
    func testEmptySame() {
        let x: [Int] = []

        for impl in allImplementations {
            let (diff, updates) = x.deepDiff(x, implementation: impl)
            XCTAssertEqual([], diff)
            XCTAssertEqual([], updates)
        }
    }

    func testNonEmptySame() {
        let x: [Int] = [1, 2, 3]

        for impl in allImplementations {
            let (diff, updates) = x.deepDiff(x, implementation: impl)
            XCTAssertEqual([], diff)
            XCTAssertEqual([], updates)
        }
    }

    func testRandomNonEmptySame() {
        let n = 10
        (0..<n).forEach { _ in
            let x: [Int] = randomArray()

            for impl in allImplementations {
                let (diff, updates) = x.deepDiff(x, implementation: impl)
                XCTAssertEqual([], diff)
                XCTAssertEqual([], updates)
            }
        }
    }
}
