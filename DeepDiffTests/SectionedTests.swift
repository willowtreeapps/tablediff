//
//  SectionedTests.swift
//  DeepDiff
//
//  Created by Kent White on 7/12/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation
import XCTest
import DeepDiff

class SectionedTests: XCTestCase {
    let sectionA = WidgetSection(identifier: "a", name: "The Best Section")
    let sectionB = WidgetSection(identifier: "b", name: "The Worst Section")
    
    let a = Widget(identifier: "a", name: "Zoomatic", price: 200)
    let b = Widget(identifier: "b", name: "Zoomatic Mini", price: 100)
    let c = Widget(identifier: "c", name: "Zoomatic Pro", price: 400)
    
    let d = Widget(identifier: "d", name: "Slomatic", price: 300)
    let e = Widget(identifier: "e", name: "Slomatic Mini", price: 907)
    let f = Widget(identifier: "f", name: "Slomatic Pro", price: 546)
    
    func testInSectionMoves() {
        let x = ExampleDataSource(sections: [sectionA, sectionB], elements: [[a, b, c], [d, e, f]])
        let y = ExampleDataSource(sections: [sectionA, sectionB], elements: [[a, b, c], [d, f, e]])
        let (diff, _) = x.tableDiff(x, y)
        XCTAssertEqual([SectionedDiffStep.move(fromIndex: NSIndexPath(forRow: 1, inSection: 1), toIndex: NSIndexPath(forRow: 2, inSection: 1)),
            SectionedDiffStep.move(fromIndex: NSIndexPath(forRow: 2, inSection: 1), toIndex: NSIndexPath(forRow: 1, inSection: 1))], diff)
    }
    
    func testBetweenSectionMove() {
        let x = ExampleDataSource(sections: [sectionA, sectionB], elements: [[a, b, c], [d, e, f]])
        let y = ExampleDataSource(sections: [sectionA, sectionB], elements: [[f, b, c], [d, e, a]])
        let (diff, _) = x.tableDiff(x, y)
        
        XCTAssertEqual([SectionedDiffStep.move(fromIndex: NSIndexPath(forRow: 0, inSection: 0), toIndex: NSIndexPath(forRow: 2, inSection: 1)),
            SectionedDiffStep.move(fromIndex: NSIndexPath(forRow: 2, inSection: 1), toIndex: NSIndexPath(forRow: 0, inSection: 0))], diff)
    }
    
    func testDeleteSection() {
        let x = ExampleDataSource(sections: [sectionA, sectionB], elements: [[a, b, c], [d, e, f]])
        let y = ExampleDataSource(sections: [sectionA], elements: [[a, b, c]])
        var (diff, _) = x.tableDiff(x, y)
        diff = trimFromSectionedDiff(diff)
        XCTAssertEqual([SectionedDiffStep.deleteSection(fromIndex: 1)], diff)
    }
    
    func testInsertSection() {
        let x = ExampleDataSource(sections: [sectionA, sectionB], elements: [[a, b, c], [d, e, f]])
        let y = ExampleDataSource(sections: [sectionA], elements: [[a, b, c]])
        var (diff, _) = x.tableDiff(x, y)
        diff = trimFromSectionedDiff(diff)
        XCTAssertEqual([SectionedDiffStep.deleteSection(fromIndex: 1)], diff)
    }
    
    func testMoveSection() {
        let x = ExampleDataSource(sections: [sectionA, sectionB], elements: [[a, b, c], [d, e, f]])
        let y = ExampleDataSource(sections: [sectionB, sectionA], elements: [[d, e, f], [a, b, c]])
        var (diff, _) = x.tableDiff(x, y)
        diff = trimFromSectionedDiff(diff)
        XCTAssertEqual([SectionedDiffStep.moveSection(fromIndex: 0, toIndex: 1), SectionedDiffStep.moveSection(fromIndex: 1, toIndex: 0)], diff)
    }
}

class LCSSectionedTests: XCTestCase {
    let sectionA = WidgetSection(identifier: "a", name: "The Best Section")
    let sectionB = WidgetSection(identifier: "b", name: "The Worst Section")
    
    let a = Widget(identifier: "a", name: "Zoomatic", price: 200)
    let b = Widget(identifier: "b", name: "Zoomatic Mini", price: 100)
    let c = Widget(identifier: "c", name: "Zoomatic Pro", price: 400)
    
    let d = Widget(identifier: "d", name: "Slomatic", price: 300)
    let e = Widget(identifier: "e", name: "Slomatic Mini", price: 907)
    let f = Widget(identifier: "f", name: "Slomatic Pro", price: 546)
    
    func testDeleteSection() {
        let x = ExampleDataSource(sections: [sectionA], elements: [[a, b, c]])
        let y = ExampleDataSource(sections: [sectionA, sectionB], elements: [[a, b, c], [d, e, f]])
        var (diff, _) = x.tableDiff(x, y, implementation: .lcs)
        diff = trimFromSectionedDiff(diff)
        XCTAssertEqual([SectionedDiffStep.insertSection(atIndex: 1)], diff)
    }
    
    func testInsertSection() {
        let x = ExampleDataSource(sections: [sectionA, sectionB], elements: [[a, b, c], [d, e, f]])
        let y = ExampleDataSource(sections: [sectionA], elements: [[a, b, c]])
        var (diff, _) = x.tableDiff(x, y, implementation: .lcs)
        diff = trimFromSectionedDiff(diff)
        XCTAssertEqual([SectionedDiffStep.deleteSection(fromIndex: 1)], diff)
    }
    
    func testMoveSection() {
        let x = ExampleDataSource(sections: [sectionA, sectionB], elements: [[a, b, c], [d, e, f]])
        let y = ExampleDataSource(sections: [sectionB, sectionA], elements: [[d, e, f], [a, b, c]])
        var (diff, _) = x.tableDiff(x, y, implementation: .lcs)
        diff = trimFromSectionedDiff(diff)
        XCTAssertEqual([SectionedDiffStep.deleteSection(fromIndex: 0), SectionedDiffStep.insertSection(atIndex: 1)], diff)
    }
    
    func testComplexSections() {
        let x = ExampleDataSource(sections: [sectionA, sectionB], elements: [[f, b, c], [d, e]])
        let y = ExampleDataSource(sections: [sectionA, sectionB], elements: [[b], [c, d, e, a]])
        var (diff, _) = x.tableDiff(x, y, implementation: .lcs)
        diff = trimFromSectionedDiff(diff)
        XCTAssertEqual([SectionedDiffStep.delete(fromIndex: NSIndexPath(forRow: 0, inSection: 0)), SectionedDiffStep.delete(fromIndex: NSIndexPath(forRow: 2, inSection: 0)), SectionedDiffStep.insert(atIndex: NSIndexPath(forRow: 0, inSection: 1)), SectionedDiffStep.insert(atIndex: NSIndexPath(forRow: 3, inSection: 1))], diff)
    }
}