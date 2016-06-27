//
//  DeleteTests.swift
//  DeepDiff
//
//  Created by Ian Terrell on 6/27/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import XCTest
import DeepDiff

class DeleteTests: XCTestCase {

    func testDeleteHead() {
        let x: [Int] = [0, 1, 2, 3]
        let y: [Int] = [1, 2, 3]
        let (diff, updates) = x.deepDiff(y)
        XCTAssertEqual([DiffStep.delete(fromIndex: 0)], diff)
        XCTAssertEqual([], updates)
    }

    func testDeleteTail() {
        let x: [Int] = [1, 2, 3, 0]
        let y: [Int] = [1, 2, 3]
        let (diff, updates) = x.deepDiff(y)
        XCTAssertEqual([DiffStep.delete(fromIndex: 3)], diff)
        XCTAssertEqual([], updates)
    }

    func testDeletetMiddle() {
        let x: [Int] = [1, 2, 0, 3]
        let y: [Int] = [1, 2, 3]
        let (diff, updates) = x.deepDiff(y)
        XCTAssertEqual([DiffStep.delete(fromIndex: 2)], diff)
        XCTAssertEqual([], updates)
    }

    func testDeleteMultiple() {
        let x: [Int] = [4, 1, 2, 5, 3, 6]
        let y: [Int] = [1, 2, 3]
        let (diff, updates) = x.deepDiff(y)
        let expectedDiff: [DiffStep<Int,Int>] = [
            DiffStep.delete(fromIndex: 0),
            DiffStep.delete(fromIndex: 2),
            DiffStep.delete(fromIndex: 3),
        ]
        XCTAssertEqual(expectedDiff, diff)
        XCTAssertEqual([], updates)
    }

}
