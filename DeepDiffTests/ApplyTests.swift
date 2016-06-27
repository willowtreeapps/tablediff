//
//  ApplyTests.swift
//  DeepDiff
//
//  Created by Ian Terrell on 6/27/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import XCTest

class ApplyTests: XCTestCase {

    func testApply() {
        let x: [Int] = [1, 2, 3]
        let y: [Int] = [0, 1, 2, 3]
        let (diff, updates) = x.deepDiff(y)
        XCTAssertEqual(y, x.apply(diff: diff, updates: updates))
    }

    func testRandomApply() {
        let n = 10
        (0..<n).forEach { _ in
            let x = randomArray()
            let y = randomArray()
            let (diff, updates) = x.deepDiff(y)
            XCTAssertEqual(y, x.apply(diff: diff, updates: updates))
        }
    }

}
