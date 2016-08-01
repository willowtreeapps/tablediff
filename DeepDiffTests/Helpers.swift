//
//  Helpers.swift
//  DeepDiff
//
//  Created by Ian Terrell on 6/27/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation
import DeepDiff

let allImplementations: [DeepDiff.Implementation] = [.lcs, .lcsWithMoves, .allMoves]

extension Int: SequenceDiffable {
    public var identifier: Int { return self }
}

struct Widget: SequenceDiffable {
    let identifier: String
    var name: String
    var price: Int

    var hashValue: Int {
        return identifier.hashValue
    }
}

func ==(lhs: Widget, rhs: Widget) -> Bool {
    return lhs.identifier == rhs.identifier && lhs.name == rhs.name && lhs.price == rhs.price
}

struct WidgetSection: SequenceDiffable {
    let identifier: String
    let name: String
    
    var hashValue: Int {
        return identifier.hashValue
    }
}

func ==(lhs: WidgetSection, rhs: WidgetSection) -> Bool {
    return lhs.identifier == rhs.identifier && lhs.name == rhs.name
}

struct ExampleDataSource: SectionedCollectionConvertible {
    typealias Section = WidgetSection
    typealias Element = Widget
    var sections: [Section]
    var elements: [[Element]]
    
    func toSectionedCollection() -> ([SectionedCollectionElement<Section, Element>], SectionIndices: [Int]) {
        var sectionedCollection: [SectionedCollectionElement<Section, Element>] = []
        var sectionIndices: [Int] = []
        for (index, sectionElements) in elements.enumerate() {
            let section = SectionedCollectionElement<Section, Element>.section(sections[index])
            sectionIndices.append(sectionedCollection.count)
            sectionedCollection.append(section)
            for element in sectionElements {
                sectionedCollection.append(SectionedCollectionElement<Section, Element>.element(element))
            }
        }
        return (sectionedCollection, sectionIndices)
    }
}

func randomArray(minSize: Int = 0, maxSize: Int = 100, minValue: Int = 0, maxValue: Int = 1000) -> [Int] {
    let count = UInt32(minSize) + arc4random_uniform(UInt32(maxSize-minSize))
    return (0..<count).map { _ in minValue + Int(arc4random_uniform(UInt32(maxValue - minValue))) }
}

extension CollectionType {
    func shuffled() -> [Generator.Element] {
        var list = Array(self)
        list.shuffle()
        return list
    }
}

extension MutableCollectionType where Index == Int {
    mutating func shuffle() {
        guard count > 1 else {
            return
        }

        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}
