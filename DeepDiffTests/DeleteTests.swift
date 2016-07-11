//
//  DeleteTests.swift
//  DeepDiff
//
//  Created by Ian Terrell on 6/27/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import XCTest
import DeepDiff

class LCSDeleteTests: XCTestCase {
    func deepDiff(x: [Int], _ y: [Int]) -> (diff: [DiffStep<Int, Int>], updates: [Update<Int, Int>]) {
        return x.deepDiff(y, implementation: .lcs)
    }

    func testDeleteHead() {
        let x: [Int] = [0, 1, 2, 3]
        let y: [Int] = [1, 2, 3]
        let (diff, updates) = deepDiff(x, y)
        XCTAssertEqual([DiffStep.delete(fromIndex: 0, item: 0)], diff)
        XCTAssertEqual([], updates)
    }

    func testDeleteTail() {
        let x: [Int] = [1, 2, 3, 0]
        let y: [Int] = [1, 2, 3]
        let (diff, updates) = deepDiff(x, y)
        XCTAssertEqual([DiffStep.delete(fromIndex: 3, item: 0)], diff)
        XCTAssertEqual([], updates)
    }

    func testDeleteMiddle() {
        let x: [Int] = [1, 2, 0, 3]
        let y: [Int] = [1, 2, 3]
        let (diff, updates) = deepDiff(x, y)
        XCTAssertEqual([DiffStep.delete(fromIndex: 2, item: 0)], diff)
        XCTAssertEqual([], updates)
    }

    func testDeleteMultiple() {
        let x: [Int] = [4, 1, 2, 5, 3, 6]
        let y: [Int] = [1, 2, 3]
        let (diff, updates) = deepDiff(x, y)
        let expectedDiff: [DiffStep<Int,Int>] = [
            DiffStep.delete(fromIndex: 0, item: 4),
            DiffStep.delete(fromIndex: 3, item: 5),
            DiffStep.delete(fromIndex: 5, item: 6),
        ]
        XCTAssertEqual(expectedDiff, diff)
        XCTAssertEqual([], updates)
    }

}

class LCSWithMovesDeleteTests: XCTestCase {
    func deepDiff(x: [Int], _ y: [Int]) -> (diff: [DiffStep<Int, Int>], updates: [Update<Int, Int>]) {
        return x.deepDiff(y, implementation: .lcsWithMoves)
    }

    func testDeleteHead() {
        let x: [Int] = [0, 1, 2, 3]
        let y: [Int] = [1, 2, 3]
        let (diff, updates) = deepDiff(x, y)
        XCTAssertEqual([DiffStep.delete(fromIndex: 0, item: 0)], diff)
        XCTAssertEqual([], updates)
    }

    func testDeleteTail() {
        let x: [Int] = [1, 2, 3, 0]
        let y: [Int] = [1, 2, 3]
        let (diff, updates) = deepDiff(x, y)
        XCTAssertEqual([DiffStep.delete(fromIndex: 3, item: 0)], diff)
        XCTAssertEqual([], updates)
    }

    func testDeleteMiddle() {
        let x: [Int] = [1, 2, 0, 3]
        let y: [Int] = [1, 2, 3]
        let (diff, updates) = deepDiff(x, y)
        XCTAssertEqual([DiffStep.delete(fromIndex: 2, item: 0)], diff)
        XCTAssertEqual([], updates)
    }

    func testDeleteMultiple() {
        let x: [Int] = [4, 1, 2, 5, 3, 6]
        let y: [Int] = [1, 2, 3]
        let (diff, updates) = deepDiff(x, y)
        let expectedDiff: [DiffStep<Int,Int>] = [
            DiffStep.delete(fromIndex: 3, item: 5),
            DiffStep.delete(fromIndex: 0, item: 4),
            DiffStep.delete(fromIndex: 5, item: 6),
            ]
        XCTAssertEqual(expectedDiff, diff)
        XCTAssertEqual([], updates)
    }
    
}
