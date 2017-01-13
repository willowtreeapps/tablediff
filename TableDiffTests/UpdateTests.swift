//
//  UpdateTests.swift
//  TableDiff
//
//  Created by Ian Terrell on 6/28/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import XCTest
import TableDiff

class UpdateTests: XCTestCase {
    let a = Widget(identifier: "a", name: "Zoomatic", price: 200)
    let b = Widget(identifier: "b", name: "Zoomatic Mini", price: 100)
    let c = Widget(identifier: "c", name: "Zoomatic Pro", price: 400)

    func testUpdateSingle() {
        var a2 = a
        a2.name = "Zoomatic Classic"

        let x: [Widget] = [a, b, c]
        let y: [Widget] = [a2, b, c]
        for impl in allImplementations {
            let (_, updates) = x.tableDiff(y, implementation: impl)
            XCTAssertEqual(Set<Int>([0]), updates)
        }
    }

    func testUpdateMultiple() {
        var a2 = a
        a2.name = "Zoomatic Classic"

        var c2 = c
        c2.name = "Zoomatic Pro Plus"
        c2.price = 500

        let x: [Widget] = [a, b, c]
        let y: [Widget] = [a2, b, c2]

        for impl in allImplementations {
            let (_, updates) = x.tableDiff(y, implementation: impl)
            XCTAssertEqual([0, 2], updates)
        }
    }

    func testUpdateAndMove() {
        var a2 = a
        a2.name = "Zoomatic Classic"

        let x: [Widget] = [a, b, c]
        let y: [Widget] = [b, a2, c]

        for impl in allImplementations {
            let (_, updates) = x.tableDiff(y, implementation: impl)
            XCTAssertEqual([1], updates)
        }
    }

    func testMoveAndUpdate() {
        var a2 = a
        a2.name = "Zoomatic Classic"

        let x: [Widget] = [a, b, c]
        let y: [Widget] = [b, a2, c]
        for impl in allImplementations {
            let (_, updates) = x.tableDiff(y, implementation: impl)
            XCTAssertEqual([1], updates)
        }
    }
}
