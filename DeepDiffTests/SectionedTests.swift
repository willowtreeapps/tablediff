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
    
    func testInSectionMove() {
        let x: [SectionedCollectionElement<WidgetSection, Widget>] = [SectionedCollectionElement<WidgetSection, Widget>.section(sectionA), SectionedCollectionElement<WidgetSection, Widget>.element(a), SectionedCollectionElement<WidgetSection, Widget>.element(b), SectionedCollectionElement<WidgetSection, Widget>.element(c), SectionedCollectionElement<WidgetSection, Widget>.section(sectionB), SectionedCollectionElement<WidgetSection, Widget>.element(d), SectionedCollectionElement<WidgetSection, Widget>.element(e), SectionedCollectionElement<WidgetSection, Widget>.element(f),]
        
        let y: [SectionedCollectionElement<WidgetSection, Widget>] = [SectionedCollectionElement<WidgetSection, Widget>.section(sectionA), SectionedCollectionElement<WidgetSection, Widget>.element(a), SectionedCollectionElement<WidgetSection, Widget>.element(b), SectionedCollectionElement<WidgetSection, Widget>.element(c), SectionedCollectionElement<WidgetSection, Widget>.section(sectionB), SectionedCollectionElement<WidgetSection, Widget>.element(d), SectionedCollectionElement<WidgetSection, Widget>.element(f), SectionedCollectionElement<WidgetSection, Widget>.element(e),]
        let converter = Converter()
        let (diff, _) = converter.tableDiff(x, b: y)
        
        XCTAssertEqual([SectionedDiffStep.move(fromIndex: NSIndexPath(forRow: 1, inSection: 1), toIndex: NSIndexPath(forRow: 2, inSection: 1)),
            SectionedDiffStep.move(fromIndex: NSIndexPath(forRow: 2, inSection: 1), toIndex: NSIndexPath(forRow: 1, inSection: 1))], diff)
    }
    
    func testBetweenSectionSwap() {
        let x: [SectionedCollectionElement<WidgetSection, Widget>] = [SectionedCollectionElement<WidgetSection, Widget>.section(sectionA), SectionedCollectionElement<WidgetSection, Widget>.element(a), SectionedCollectionElement<WidgetSection, Widget>.element(b), SectionedCollectionElement<WidgetSection, Widget>.element(c), SectionedCollectionElement<WidgetSection, Widget>.section(sectionB), SectionedCollectionElement<WidgetSection, Widget>.element(d), SectionedCollectionElement<WidgetSection, Widget>.element(e), SectionedCollectionElement<WidgetSection, Widget>.element(f),]
        
        let y: [SectionedCollectionElement<WidgetSection, Widget>] = [SectionedCollectionElement<WidgetSection, Widget>.section(sectionA), SectionedCollectionElement<WidgetSection, Widget>.element(f), SectionedCollectionElement<WidgetSection, Widget>.element(b), SectionedCollectionElement<WidgetSection, Widget>.element(c), SectionedCollectionElement<WidgetSection, Widget>.section(sectionB), SectionedCollectionElement<WidgetSection, Widget>.element(d), SectionedCollectionElement<WidgetSection, Widget>.element(e), SectionedCollectionElement<WidgetSection, Widget>.element(a),]
        let converter = Converter()
        let (diff, _) = converter.tableDiff(x, b: y)
        
        XCTAssertEqual([SectionedDiffStep.move(fromIndex: NSIndexPath(forRow: 0, inSection: 0), toIndex: NSIndexPath(forRow: 2, inSection: 1)),
            SectionedDiffStep.move(fromIndex: NSIndexPath(forRow: 2, inSection: 1), toIndex: NSIndexPath(forRow: 0, inSection: 0))], diff)
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
        let x: [SectionedCollectionElement<WidgetSection, Widget>] = [SectionedCollectionElement<WidgetSection, Widget>.section(sectionA), SectionedCollectionElement<WidgetSection, Widget>.element(a), SectionedCollectionElement<WidgetSection, Widget>.element(b), SectionedCollectionElement<WidgetSection, Widget>.element(c), SectionedCollectionElement<WidgetSection, Widget>.section(sectionB), SectionedCollectionElement<WidgetSection, Widget>.element(d), SectionedCollectionElement<WidgetSection, Widget>.element(e), SectionedCollectionElement<WidgetSection, Widget>.element(f),]
        
        let y: [SectionedCollectionElement<WidgetSection, Widget>] = [SectionedCollectionElement<WidgetSection, Widget>.section(sectionA), SectionedCollectionElement<WidgetSection, Widget>.element(a), SectionedCollectionElement<WidgetSection, Widget>.element(b), SectionedCollectionElement<WidgetSection, Widget>.element(c),]
        let converter = Converter()
        var (diff, _) = converter.tableDiff(x, b: y, implementation: .lcs)
        diff = trimFromSectionedDiff(diff)
        XCTAssertEqual([SectionedDiffStep.deleteSection(fromIndex: 1)], diff)
    }
    
    func testInsertSection() {
        let x: [SectionedCollectionElement<WidgetSection, Widget>] = [SectionedCollectionElement<WidgetSection, Widget>.section(sectionB), SectionedCollectionElement<WidgetSection, Widget>.element(d), SectionedCollectionElement<WidgetSection, Widget>.element(e), SectionedCollectionElement<WidgetSection, Widget>.element(f),]
        
        let y: [SectionedCollectionElement<WidgetSection, Widget>] = [SectionedCollectionElement<WidgetSection, Widget>.section(sectionA), SectionedCollectionElement<WidgetSection, Widget>.element(a), SectionedCollectionElement<WidgetSection, Widget>.element(b), SectionedCollectionElement<WidgetSection, Widget>.element(c), SectionedCollectionElement<WidgetSection, Widget>.section(sectionB), SectionedCollectionElement<WidgetSection, Widget>.element(d), SectionedCollectionElement<WidgetSection, Widget>.element(e), SectionedCollectionElement<WidgetSection, Widget>.element(f),]
        let converter = Converter()
        var (diff, _) = converter.tableDiff(x, b: y, implementation: .lcs)
        diff = trimFromSectionedDiff(diff)
        XCTAssertEqual([SectionedDiffStep.insertSection(atIndex: 0)], diff)
    }
    
    func testMoveSection() {
        let x: [SectionedCollectionElement<WidgetSection, Widget>] = [SectionedCollectionElement<WidgetSection, Widget>.section(sectionA), SectionedCollectionElement<WidgetSection, Widget>.element(f), SectionedCollectionElement<WidgetSection, Widget>.element(b), SectionedCollectionElement<WidgetSection, Widget>.element(c), SectionedCollectionElement<WidgetSection, Widget>.section(sectionB), SectionedCollectionElement<WidgetSection, Widget>.element(d), SectionedCollectionElement<WidgetSection, Widget>.element(e), SectionedCollectionElement<WidgetSection, Widget>.element(a),]
        
        let y: [SectionedCollectionElement<WidgetSection, Widget>] = [SectionedCollectionElement<WidgetSection, Widget>.section(sectionB), SectionedCollectionElement<WidgetSection, Widget>.element(d), SectionedCollectionElement<WidgetSection, Widget>.element(e), SectionedCollectionElement<WidgetSection, Widget>.element(a), SectionedCollectionElement<WidgetSection, Widget>.section(sectionA), SectionedCollectionElement<WidgetSection, Widget>.element(f), SectionedCollectionElement<WidgetSection, Widget>.element(b), SectionedCollectionElement<WidgetSection, Widget>.element(c), ]
        let converter = Converter()
        var (diff, _) = converter.tableDiff(x, b: y, implementation: .lcsWithMoves)
        diff = trimFromSectionedDiff(diff)
        
        XCTAssertEqual([SectionedDiffStep.moveSection(fromIndex: 0, toIndex: 1)], diff)
    }
}