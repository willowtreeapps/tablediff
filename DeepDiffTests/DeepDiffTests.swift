//
//  DeepDiffTests.swift
//  DeepDiffTests
//
//  Created by Ian Terrell on 6/27/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import XCTest
import DeepDiff

class LCSDeepDiffTests: XCTestCase {
    func deepDiff(x: [Int], _ y: [Int]) -> (diff: [DiffStep<Int, Int>], updates: [Update<Int, Int>]) {
        return x.deepDiff(y, implementation: .lcs)
    }

    func testEmptySame() {
        let x: [Int] = []
        let (diff, updates) = deepDiff(x, x)
        XCTAssertEqual([], diff)
        XCTAssertEqual([], updates)
    }

    func testNonEmptySame() {
        let x: [Int] = [1, 2, 3]
        let (diff, updates) = deepDiff(x, x)
        XCTAssertEqual([], diff)
        XCTAssertEqual([], updates)
    }

    func testRandomNonEmptySame() {
        let n = 10
        (0..<n).forEach { _ in
            let x: [Int] = randomArray()
            let (diff, updates) = deepDiff(x, x)
            XCTAssertEqual([], diff)
            XCTAssertEqual([], updates)
        }
    }
}

class LCSWithMovesDeepDiffTests: XCTestCase {
    func deepDiff(x: [Int], _ y: [Int]) -> (diff: [DiffStep<Int, Int>], updates: [Update<Int, Int>]) {
        return x.deepDiff(y, implementation: .lcsWithMoves)
    }

    func testEmptySame() {
        let x: [Int] = []
        let (diff, updates) = deepDiff(x, x)
        XCTAssertEqual([], diff)
        XCTAssertEqual([], updates)
    }

    func testNonEmptySame() {
        let x: [Int] = [1, 2, 3]
        let (diff, updates) = deepDiff(x, x)
        XCTAssertEqual([], diff)
        XCTAssertEqual([], updates)
    }

    func testRandomNonEmptySame() {
        let n = 10
        (0..<n).forEach { _ in
            let x: [Int] = randomArray()
            let (diff, updates) = deepDiff(x, x)
            XCTAssertEqual([], diff)
            XCTAssertEqual([], updates)
        }
    }
}
