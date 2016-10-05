//
//  MoveTests.swift
//  TableDiff
//
//  Created by Ian Terrell on 6/28/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import XCTest
import TableDiff

class LCSMoveTests: XCTestCase {
    func tableDiff(_ x: [Int], _ y: [Int]) -> (diff: Set<DiffStep<Int>>, updates: Set<Int>) {
        return x.tableDiff(y, implementation: .lcs)
    }

    func testMoveHead() {
        let x: [Int] = [0, 1, 2, 3]
        let y: [Int] = [1, 2, 3, 0]
        let (diff, updates) = tableDiff(x, y)
        let expectedDiff: Set<DiffStep<Int>> = [
            DiffStep.delete(fromIndex: 0),
            DiffStep.insert(atIndex: 3),
            ]
        XCTAssertEqual(expectedDiff, diff)
        XCTAssertEqual([], updates)
    }

    func testMoveTail() {
        let x: [Int] = [1, 2, 3, 0]
        let y: [Int] = [0, 1, 2, 3]
        let (diff, updates) = tableDiff(x, y)
        let expectedDiff: Set<DiffStep<Int>> = [
            DiffStep.insert(atIndex: 0),
            DiffStep.delete(fromIndex: 3),
            ]
        XCTAssertEqual(expectedDiff, diff)
        XCTAssertEqual([], updates)
    }

    func testMoveMiddle() {
        let x: [Int] = [1, 2, 0, 3]
        let y: [Int] = [1, 0, 2, 3]
        let (diff, updates) = tableDiff(x, y)
        let expectedDiff: Set<DiffStep<Int>> = [
            DiffStep.delete(fromIndex: 1),
            DiffStep.insert(atIndex: 2),
            ]
        XCTAssertEqual(expectedDiff, diff)
        XCTAssertEqual([], updates)
    }

    // These won't pass until we resolve the issue with same index and same value being to difficult to transfer to move
    func testMoveMultiple() {
        let x: [Int] = [1, 2, 3]
        let y: [Int] = [3, 2, 1]
        let (diff, updates) = tableDiff(x, y)
        let expectedDiff: Set<DiffStep<Int>> = [
            DiffStep.delete(fromIndex: 0),
            DiffStep.delete(fromIndex: 1),
            DiffStep.insert(atIndex: 1),
            DiffStep.insert(atIndex: 2),
            ]
        XCTAssertEqual(expectedDiff, diff)
        XCTAssertEqual([], updates)
    }

    func testComplexMove() {
        let x: [Int] = [342, 604, 390, 870, 745]
        let y: [Int] = [870, 604, 745, 390, 342]
        let (diff, updates) = tableDiff(x, y)
        let expectedDiff: Set<DiffStep<Int>> = [
            DiffStep.delete(fromIndex: 0),
            DiffStep.delete(fromIndex: 1),
            DiffStep.delete(fromIndex: 2),
            DiffStep.insert(atIndex: 1),
            DiffStep.insert(atIndex: 3),
            DiffStep.insert(atIndex: 4),
        ]
        XCTAssertEqual(expectedDiff, diff)
        XCTAssertEqual([], updates)
    }
}

class LCSWithMovesMoveTests: XCTestCase {
    func tableDiff(_ x: [Int], _ y: [Int]) -> (diff: Set<DiffStep<Int>>, updates: Set<Int>) {
        return x.tableDiff(y, implementation: .lcsWithMoves)
    }

    func testMoveHead() {
        let x: [Int] = [0, 1, 2, 3]
        let y: [Int] = [1, 2, 3, 0]
        let (diff, updates) = tableDiff(x, y)
        XCTAssertEqual([DiffStep.move(fromIndex: 0, toIndex: 3)], diff)
        XCTAssertEqual([], updates)
    }

    func testMoveTail() {
        let x: [Int] = [1, 2, 3, 0]
        let y: [Int] = [0, 1, 2, 3]
        let (diff, updates) = tableDiff(x, y)
        XCTAssertEqual([DiffStep.move(fromIndex: 3, toIndex: 0)], diff)
        XCTAssertEqual([], updates)
    }

    func testMoveMiddle() {
        let x: [Int] = [1, 2, 0, 3]
        let y: [Int] = [1, 0, 2, 3]
        let (diff, updates) = tableDiff(x, y)
        XCTAssertEqual([DiffStep.move(fromIndex: 1, toIndex: 2)], diff)
        XCTAssertEqual([], updates)
    }

    // These won't pass until we resolve the issue with same index and same value being to difficult to transfer to move
    func testMoveMultiple() {
        let x: [Int] = [1, 2, 3]
        let y: [Int] = [3, 2, 1]
        let (diff, updates) = tableDiff(x, y)
        let expectedDiff: Set<DiffStep<Int>> = [
            DiffStep.insert(atIndex: 1),
            DiffStep.move(fromIndex: 0, toIndex: 2),
            DiffStep.delete(fromIndex: 1),
            ]
        XCTAssertEqual(expectedDiff, diff)
        XCTAssertEqual([], updates)
    }

    func testComplexMove() {
        let x: [Int] = [342, 604, 390, 870, 745]
        let y: [Int] = [870, 604, 745, 390, 342]
        let (diff, updates) = tableDiff(x, y)
        let expectedDiff: Set<DiffStep<Int>> = [
            DiffStep.insert(atIndex: 1),
            DiffStep.move(fromIndex: 2, toIndex: 3),
            DiffStep.move(fromIndex: 0, toIndex: 4),
            DiffStep.delete(fromIndex: 1),
            ]
        XCTAssertEqual(expectedDiff, diff)
        XCTAssertEqual([], updates)
    }
}


class AllMovesMoveTests: XCTestCase {
    func tableDiff(_ x: [Int], _ y: [Int]) -> (diff: Set<DiffStep<Int>>, updates: Set<Int>) {
        return x.tableDiff(y, implementation: .allMoves)
    }

    func testMoveHead() {
        let x: [Int] = [0, 1, 2, 3]
        let y: [Int] = [1, 2, 3, 0]
        var (diff, updates) = tableDiff(x, y)
        diff = trimMovesFromDiff(diff)
        let expectedDiff: Set<DiffStep<Int>> = [
            DiffStep.move(fromIndex: 0, toIndex: 3),
            DiffStep.move(fromIndex: 1, toIndex: 0),
            DiffStep.move(fromIndex: 2, toIndex: 1),
            DiffStep.move(fromIndex: 3, toIndex: 2),
            ]
        XCTAssertEqual(expectedDiff, diff)
        XCTAssertEqual([], updates)
    }

    func testMoveTail() {
        let x: [Int] = [1, 2, 3, 0]
        let y: [Int] = [0, 1, 2, 3]
        var (diff, updates) = tableDiff(x, y)
        diff = trimMovesFromDiff(diff)
        let expectedDiff: Set<DiffStep<Int>> = [
            DiffStep.move(fromIndex: 0, toIndex: 1),
            DiffStep.move(fromIndex: 1, toIndex: 2),
            DiffStep.move(fromIndex: 2, toIndex: 3),
            DiffStep.move(fromIndex: 3, toIndex: 0),
            ]
        XCTAssertEqual(expectedDiff, diff)
        XCTAssertEqual([], updates)
    }

    func testMoveMiddle() {
        let x: [Int] = [1, 2, 0, 3]
        let y: [Int] = [1, 0, 2, 3]
        var (diff, updates) = tableDiff(x, y)
        diff = trimMovesFromDiff(diff)
        let expectedDiff: Set<DiffStep<Int>> = [
            DiffStep.move(fromIndex: 1, toIndex: 2),
            DiffStep.move(fromIndex: 2, toIndex: 1),
            ]
        XCTAssertEqual(expectedDiff, diff)
        XCTAssertEqual([], updates)
    }

    // These won't pass until we resolve the issue with same index and same value being to difficult to transfer to move
    func testMoveMultiple() {
        let x: [Int] = [1, 2, 3]
        let y: [Int] = [3, 2, 1]
        var (diff, updates) = tableDiff(x, y)
        diff = trimMovesFromDiff(diff)
        let expectedDiff: Set<DiffStep<Int>> = [
            DiffStep.move(fromIndex: 0, toIndex: 2),
            DiffStep.move(fromIndex: 2, toIndex: 0),
            ]
        XCTAssertEqual(expectedDiff, diff)
        XCTAssertEqual([], updates)
    }

    func testRandomMoves() {
        let n = 10
        for _ in 0..<n {
            let x = randomArray()
            let y = x.shuffled()
            let (diff, updates) = x.tableDiff(y)
            for d in diff {
                switch d {
                case .move:
                    continue
                default:
                    XCTFail("Should only have move instructions")
                }
            }
            XCTAssertEqual([], updates)
        }
    }

    func testComplexMove() {
        let x: [Int] = [342, 604, 390, 870, 745]
        let y: [Int] = [870, 604, 745, 390, 342]
        let (diff, updates) = x.tableDiff(y)
        let expectedDiff: Set<DiffStep<Int>> = [
            DiffStep.move(fromIndex: 0, toIndex: 4),
            DiffStep.move(fromIndex: 2, toIndex: 3),
            DiffStep.move(fromIndex: 3, toIndex: 0),
            DiffStep.move(fromIndex: 4, toIndex: 2),
        ]
        XCTAssertEqual(expectedDiff, diff)
        XCTAssertEqual([], updates)
    }
}
