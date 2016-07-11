//
//  UpdateTests.swift
//  DeepDiff
//
//  Created by Ian Terrell on 6/28/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import XCTest
import DeepDiff

class LCSUpdateTests: XCTestCase {
    func deepDiff(x: [Widget], _ y: [Widget]) -> (diff: [DiffStep<Widget, Int>], updates: [Update<Widget, Int>]) {
        return x.deepDiff(y, implementation: .lcs)
    }

    let a = Widget(id: "a", name: "Zoomatic", price: 200)
    let b = Widget(id: "b", name: "Zoomatic Mini", price: 100)
    let c = Widget(id: "c", name: "Zoomatic Pro", price: 400)

    func testUpdateSingle() {
        var a2 = a
        a2.name = "Zoomatic Classic"

        let x: [Widget] = [a, b, c]
        let y: [Widget] = [a2, b, c]
        let (_, updates) = deepDiff(x, y)
        XCTAssertEqual([Update<Widget, Int>(index: 0, newItem: a2)], updates)
    }
    
    func testUpdateMultiple() {
        var a2 = a
        a2.name = "Zoomatic Classic"

        var c2 = c
        c2.name = "Zoomatic Pro Plus"
        c2.price = 500

        let x: [Widget] = [a, b, c]
        let y: [Widget] = [a2, b, c2]
        let (_, updates) = deepDiff(x, y)
        let expected: [Update<Widget,Int>] = [
            Update<Widget, Int>(index: 0, newItem: a2),
            Update<Widget, Int>(index: 2, newItem: c2),
        ]
        XCTAssertEqual(expected, updates)
    }

    func testUpdateAndMove() {
        var a2 = a
        a2.name = "Zoomatic Classic"

        let x: [Widget] = [a, b, c]
        let y: [Widget] = [b, a2, c]
        let (_, updates) = deepDiff(x, y)
        XCTAssertEqual([Update<Widget, Int>(index: 1, newItem: a2)], updates)
    }
    
    func testPreUpdate() {
        var a2 = a
        a2.name = "Zoomatic Classic"
        
        let x: [Widget] = [a, b, c]
        let y: [Widget] = [b, a2, c]
        let (_, updates) = x.deepDiff(y, implementation: .lcs, updateStyle: .pre)
        XCTAssertEqual([Update<Widget, Int>(index: 0, newItem: a2)], updates)
    }
}

class LCSWithMovesUpdateTests: XCTestCase {
    func deepDiff(x: [Widget], _ y: [Widget]) -> (diff: [DiffStep<Widget, Int>], updates: [Update<Widget, Int>]) {
        return x.deepDiff(y, implementation: .lcsWithMoves)
    }

    let a = Widget(id: "a", name: "Zoomatic", price: 200)
    let b = Widget(id: "b", name: "Zoomatic Mini", price: 100)
    let c = Widget(id: "c", name: "Zoomatic Pro", price: 400)

    func testUpdateSingle() {
        var a2 = a
        a2.name = "Zoomatic Classic"

        let x: [Widget] = [a, b, c]
        let y: [Widget] = [a2, b, c]
        let (_, updates) = deepDiff(x, y)
        XCTAssertEqual([Update<Widget, Int>(index: 0, newItem: a2)], updates)
    }

    func testUpdateMultiple() {
        var a2 = a
        a2.name = "Zoomatic Classic"

        var c2 = c
        c2.name = "Zoomatic Pro Plus"
        c2.price = 500

        let x: [Widget] = [a, b, c]
        let y: [Widget] = [a2, b, c2]
        let (_, updates) = deepDiff(x, y)
        let expected: [Update<Widget,Int>] = [
            Update<Widget, Int>(index: 0, newItem: a2),
            Update<Widget, Int>(index: 2, newItem: c2),
            ]
        XCTAssertEqual(expected, updates)
    }

    func testUpdateAndMove() {
        var a2 = a
        a2.name = "Zoomatic Classic"

        let x: [Widget] = [a, b, c]
        let y: [Widget] = [b, a2, c]
        let (_, updates) = deepDiff(x, y)
        XCTAssertEqual([Update<Widget, Int>(index: 1, newItem: a2)], updates)
    }

    func testPreUpdate() {
        var a2 = a
        a2.name = "Zoomatic Classic"

        let x: [Widget] = [a, b, c]
        let y: [Widget] = [b, a2, c]
        let (_, updates) = x.deepDiff(y, implementation: .lcsWithMoves, updateStyle: .pre)
        XCTAssertEqual([Update<Widget, Int>(index: 0, newItem: a2)], updates)
    }
}
