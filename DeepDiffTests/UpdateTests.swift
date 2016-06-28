//
//  UpdateTests.swift
//  DeepDiff
//
//  Created by Ian Terrell on 6/28/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import XCTest
import DeepDiff

class UpdateTests: XCTestCase {

    let a = Widget(id: "a", name: "Zoomatic", price: 200)
    let b = Widget(id: "b", name: "Zoomatic Mini", price: 100)
    let c = Widget(id: "c", name: "Zoomatic Pro", price: 400)

    func testUpdateSingle() {
        var a2 = a
        a2.name = "Zoomatic Classic"

        let x: [Widget] = [a, b, c]
        let y: [Widget] = [a2, b, c]
        let (diff, updates) = x.deepDiff(y)
        XCTAssertEqual([], diff)
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
        let (diff, updates) = x.deepDiff(y)
        XCTAssertEqual([], diff)

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
        let (diff, updates) = x.deepDiff(y)
        XCTAssertEqual([DiffStep<Widget, Int>.move(fromIndex: 0, toIndex: 1)], diff)
        XCTAssertEqual([Update<Widget, Int>(index: 1, newItem: a2)], updates)
    }
}
