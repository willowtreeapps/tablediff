//
//  MoveTests.swift
//  DeepDiff
//
//  Created by Ian Terrell on 6/28/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import XCTest
import DeepDiff

class LCSMoveTests: XCTestCase {
    func deepDiff(x: [Int], _ y: [Int]) -> (diff: [DiffStep<Int, Int>], updates: [Update<Int, Int>]) {
        return x.deepDiff(y, implementation: .lcs)
    }

    func testMoveHead() {
        let x: [Int] = [0, 1, 2, 3]
        let y: [Int] = [1, 2, 3, 0]
        let (diff, updates) = deepDiff(x, y)
        let expectedDiff: [DiffStep<Int,Int>] = [
            DiffStep.delete(fromIndex: 0, item: 0),
            DiffStep.insert(atIndex: 3, item: 0),
            ]
        XCTAssertEqual(expectedDiff, diff)
        XCTAssertEqual([], updates)
    }

    func testMoveTail() {
        let x: [Int] = [1, 2, 3, 0]
        let y: [Int] = [0, 1, 2, 3]
        let (diff, updates) = deepDiff(x, y)
        let expectedDiff: [DiffStep<Int,Int>] = [
            DiffStep.insert(atIndex: 0, item: 0),
            DiffStep.delete(fromIndex: 3, item: 0),
            ]
        XCTAssertEqual(expectedDiff, diff)
        XCTAssertEqual([], updates)
    }

    func testMoveMiddle() {
        let x: [Int] = [1, 2, 0, 3]
        let y: [Int] = [1, 0, 2, 3]
        let (diff, updates) = deepDiff(x, y)
        let expectedDiff: [DiffStep<Int,Int>] = [
            DiffStep.delete(fromIndex: 1, item: 2),
            DiffStep.insert(atIndex: 2, item: 2),
            ]
        XCTAssertEqual(expectedDiff, diff)
        XCTAssertEqual([], updates)
    }

    // These won't pass until we resolve the issue with same index and same value being to difficult to transfer to move
    func testMoveMultiple() {
        let x: [Int] = [1, 2, 3]
        let y: [Int] = [3, 2, 1]
        let (diff, updates) = deepDiff(x, y)
        let expectedDiff: [DiffStep<Int,Int>] = [
            DiffStep.delete(fromIndex: 0, item: 1),
            DiffStep.delete(fromIndex: 1, item: 2),
            DiffStep.insert(atIndex: 1, item: 2),
            DiffStep.insert(atIndex: 2, item: 1),
            ]
        XCTAssertEqual(expectedDiff, diff)
        XCTAssertEqual([], updates)
    }
    
    func testComplexMove() {
        let x: [Int] = [342, 604, 390, 870, 745]
        let y: [Int] = [870, 604, 745, 390, 342]
        let (diff, updates) = deepDiff(x, y)
        let expectedDiff: [DiffStep<Int,Int>] = [
            DiffStep.delete(fromIndex: 0, item: 342),
            DiffStep.delete(fromIndex: 1, item: 604),
            DiffStep.delete(fromIndex: 2, item: 390),
            DiffStep.insert(atIndex: 1, item: 604),
            DiffStep.insert(atIndex: 3, item: 390),
            DiffStep.insert(atIndex: 4, item: 342),
        ]
        XCTAssertEqual(expectedDiff, diff)
        XCTAssertEqual([], updates)
    }
}

class LCSWithMovesMoveTests: XCTestCase {
    func deepDiff(x: [Int], _ y: [Int]) -> (diff: [DiffStep<Int, Int>], updates: [Update<Int, Int>]) {
        return x.deepDiff(y, implementation: .lcsWithMoves)
    }

    func testMoveHead() {
        let x: [Int] = [0, 1, 2, 3]
        let y: [Int] = [1, 2, 3, 0]
        let (diff, updates) = deepDiff(x, y)
        XCTAssertEqual([DiffStep.move(fromIndex: 0, toIndex: 3)], diff)
        XCTAssertEqual([], updates)
    }

    func testMoveTail() {
        let x: [Int] = [1, 2, 3, 0]
        let y: [Int] = [0, 1, 2, 3]
        let (diff, updates) = deepDiff(x, y)
        XCTAssertEqual([DiffStep.move(fromIndex: 3, toIndex: 0)], diff)
        XCTAssertEqual([], updates)
    }

    func testMoveMiddle() {
        let x: [Int] = [1, 2, 0, 3]
        let y: [Int] = [1, 0, 2, 3]
        let (diff, updates) = deepDiff(x, y)
        XCTAssertEqual([DiffStep.move(fromIndex: 1, toIndex: 2)], diff)
        XCTAssertEqual([], updates)
    }

    // These won't pass until we resolve the issue with same index and same value being to difficult to transfer to move
    func testMoveMultiple() {
        let x: [Int] = [1, 2, 3]
        let y: [Int] = [3, 2, 1]
        let (diff, updates) = deepDiff(x, y)
        let expectedDiff: [DiffStep<Int,Int>] = [
            DiffStep.insert(atIndex: 1, item: 2),
            DiffStep.move(fromIndex: 0, toIndex: 2),
            DiffStep.delete(fromIndex: 1, item: 2),
            ]
        XCTAssertEqual(expectedDiff, diff)
        XCTAssertEqual([], updates)
    }

    func testComplexMove() {
        let x: [Int] = [342, 604, 390, 870, 745]
        let y: [Int] = [870, 604, 745, 390, 342]
        let (diff, updates) = deepDiff(x, y)
        let expectedDiff: [DiffStep<Int,Int>] = [
            DiffStep.insert(atIndex: 1, item: 604),
            DiffStep.move(fromIndex: 2, toIndex: 3),
            DiffStep.move(fromIndex: 0, toIndex: 4),
            DiffStep.delete(fromIndex: 1, item: 604),
            ]
        XCTAssertEqual(expectedDiff, diff)
        XCTAssertEqual([], updates)
    }
}
