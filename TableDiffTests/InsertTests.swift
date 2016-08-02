//
//  InsertTests.swift
//  TableDiff
//
//  Created by Ian Terrell on 6/27/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import XCTest
import TableDiff

class LCSInsertTests: XCTestCase {
    func tableDiff(x: [Int], _ y: [Int]) -> (diff: Set<DiffStep<Int>>, updates: Set<Int>) {
        return x.tableDiff(y, implementation: .lcs)
    }

    func testInsertHead() {
        let x: [Int] = [1, 2, 3]
        let y: [Int] = [0, 1, 2, 3]
        let (diff, updates) = tableDiff(x, y)
        XCTAssertEqual([DiffStep.insert(atIndex: 0)], diff)
        XCTAssertEqual([], updates)
    }

    func testInsertTail() {
        let x: [Int] = [1, 2, 3]
        let y: [Int] = [1, 2, 3, 0]
        let (diff, updates) = tableDiff(x, y)
        XCTAssertEqual([DiffStep.insert(atIndex: 3)], diff)
        XCTAssertEqual([], updates)
    }

    func testInsertMiddle() {
        let x: [Int] = [1, 2, 3]
        let y: [Int] = [1, 2, 0, 3]
        let (diff, updates) = tableDiff(x, y)
        XCTAssertEqual([DiffStep.insert(atIndex: 2)], diff)
        XCTAssertEqual([], updates)
    }

    func testInsertMultiple() {
        let x: [Int] = [1, 2, 3]
        let y: [Int] = [4, 1, 2, 5, 3, 6]
        let (diff, updates) = tableDiff(x, y)
        let expectedDiff: Set<DiffStep<Int>> = [
            DiffStep.insert(atIndex: 0),
            DiffStep.insert(atIndex: 3),
            DiffStep.insert(atIndex: 5),
        ]
        XCTAssertEqual(expectedDiff, diff)
        XCTAssertEqual([], updates)
    }

    func testInsertSame() {
        let x: [Int] = [1, 2, 3]
        let y: [Int] = [1, 2, 3, 1]
        var (diff, updates) = tableDiff(x, y)
        diff = trimMovesFromDiff(diff)
        let expectedDiff: Set<DiffStep<Int>> = [
            DiffStep.insert(atIndex: 3),
            ]
        XCTAssertEqual(expectedDiff, diff)
        XCTAssertEqual([], updates)
    }
}

class LCSWithMovesInsertTests: XCTestCase {
    func tableDiff(x: [Int], _ y: [Int]) -> (diff: Set<DiffStep<Int>>, updates: Set<Int>) {
        return x.tableDiff(y, implementation: .lcsWithMoves)
    }

    func testInsertHead() {
        let x: [Int] = [1, 2, 3]
        let y: [Int] = [0, 1, 2, 3]
        let (diff, updates) = tableDiff(x, y)
        XCTAssertEqual([DiffStep.insert(atIndex: 0)], diff)
        XCTAssertEqual([], updates)
    }

    func testInsertTail() {
        let x: [Int] = [1, 2, 3]
        let y: [Int] = [1, 2, 3, 0]
        let (diff, updates) = tableDiff(x, y)
        XCTAssertEqual([DiffStep.insert(atIndex: 3)], diff)
        XCTAssertEqual([], updates)
    }

    func testInsertMiddle() {
        let x: [Int] = [1, 2, 3]
        let y: [Int] = [1, 2, 0, 3]
        let (diff, updates) = tableDiff(x, y)
        XCTAssertEqual([DiffStep.insert(atIndex: 2)], diff)
        XCTAssertEqual([], updates)
    }

    func testInsertMultiple() {
        let x: [Int] = [1, 2, 3]
        let y: [Int] = [4, 1, 2, 5, 3, 6]
        let (diff, updates) = tableDiff(x, y)
        let expectedDiff: Set<DiffStep<Int>> = [
            DiffStep.insert(atIndex: 3),
            DiffStep.insert(atIndex: 0),
            DiffStep.insert(atIndex: 5),
            ]
        XCTAssertEqual(expectedDiff, diff)
        XCTAssertEqual([], updates)
    }

    func testInsertSame() {
        let x: [Int] = [1, 2, 3]
        let y: [Int] = [1, 2, 3, 1]
        var (diff, updates) = tableDiff(x, y)
        diff = trimMovesFromDiff(diff)
        let expectedDiff: Set<DiffStep<Int>> = [
            DiffStep.insert(atIndex: 3),
            ]
        XCTAssertEqual(expectedDiff, diff)
        XCTAssertEqual([], updates)
    }
}

class AllMovesInsertTests: XCTestCase {
    func tableDiff(x: [Int], _ y: [Int]) -> (diff: Set<DiffStep<Int>>, updates: Set<Int>) {
        return x.tableDiff(y, implementation: .allMoves)
    }

    func testInsertHead() {
        let x: [Int] = [1, 2, 3]
        let y: [Int] = [0, 1, 2, 3]
        var (diff, updates) = tableDiff(x, y)
        diff = trimMovesFromDiff(diff)
        XCTAssertEqual([DiffStep.insert(atIndex: 0)], diff)
        XCTAssertEqual([], updates)
    }

    func testInsertTail() {
        let x: [Int] = [1, 2, 3]
        let y: [Int] = [1, 2, 3, 0]
        var (diff, updates) = tableDiff(x, y)
        diff = trimMovesFromDiff(diff)
        XCTAssertEqual([DiffStep.insert(atIndex: 3)], diff)
        XCTAssertEqual([], updates)
    }

    func testInsertMiddle() {
        let x: [Int] = [1, 2, 3]
        let y: [Int] = [1, 2, 0, 3]
        var (diff, updates) = tableDiff(x, y)
        diff = trimMovesFromDiff(diff)
        XCTAssertEqual([DiffStep.insert(atIndex: 2)], diff)
        XCTAssertEqual([], updates)
    }

    func testInsertMultiple() {
        let x: [Int] = [1, 2, 3]
        let y: [Int] = [4, 1, 2, 5, 3, 6]
        var (diff, updates) = tableDiff(x, y)
        diff = trimMovesFromDiff(diff)
        let expectedDiff: Set<DiffStep<Int>> = [
            DiffStep.insert(atIndex: 0),
            DiffStep.insert(atIndex: 3),
            DiffStep.insert(atIndex: 5),
        ]
        XCTAssertEqual(expectedDiff, diff)
        XCTAssertEqual([], updates)
    }

    func testInsertSame() {
        let x: [Int] = [1, 2, 3]
        let y: [Int] = [1, 2, 3, 1]
        var (diff, updates) = tableDiff(x, y)
        diff = trimMovesFromDiff(diff)
        let expectedDiff: Set<DiffStep<Int>> = [
            DiffStep.insert(atIndex: 3),
            ]
        XCTAssertEqual(expectedDiff, diff)
        XCTAssertEqual([], updates)
    }
}
