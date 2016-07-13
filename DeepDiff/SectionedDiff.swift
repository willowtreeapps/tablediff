//
//  SectionedDiff.swift
//  DeepDiff
//
//  Created by Kent White on 7/13/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation

/// Represents instructions necessary to move a sequence from its current
/// state into another state.
public enum SectionedDiffStep: Hashable, CustomDebugStringConvertible {
    case insert(atIndex: NSIndexPath)
    case delete(fromIndex: NSIndexPath)
    case move(fromIndex: NSIndexPath, toIndex: NSIndexPath)
    case insertSection(atIndex: Int)
    case deleteSection(fromIndex: Int)
    case moveSection(fromIndex: Int, toIndex: Int)
    
    public var hashValue: Int {
        switch self {
        case insert(let i):
            return 100000000 + i.hashValue
        case delete(let i):
            return 200000000 + i.hashValue
        case move(let from, _):
            return 300000000 + from.hashValue
        default:
            return -1 //I don't think these are going to matter but i havent really thought about it
        }
    }
    
    public var debugDescription: String {
        switch self {
        case insert(let index):
            return "Insert \(index)"
        case delete(let index):
            return "Delete \(index)"
        case move(let from, let to):
            return "Move \(from) -> \(to)"
        case insertSection(let index):
            return "Insert section \(index)"
        case deleteSection(let index):
            return "Delete section \(index)"
        case moveSection(let from, let to):
            return "Move section \(from) to \(to)"
        }
        
    }
}

public func ==(lhs: SectionedDiffStep, rhs: SectionedDiffStep) -> Bool {
    switch (lhs, rhs) {
    case (let .insert(atIndex: lhsIndex), let .insert(atIndex: rhsIndex)):
        return lhsIndex == rhsIndex
    case (let .delete(fromIndex: lhsIndex), let .delete(fromIndex: rhsIndex)):
        return lhsIndex == rhsIndex
    case (let .move(fromIndex: lhsFromIndex, toIndex: lhsToIndex), let .move(fromIndex: rhsFromIndex, toIndex: rhsToIndex)):
        return lhsFromIndex == rhsFromIndex && lhsToIndex == rhsToIndex
    default:
        return false
    }
}

public protocol SectionedCollectionConvertible {
    associatedtype Section: SequenceDiffable
    associatedtype Element: SequenceDiffable
    func toSectionedCollection() -> [SectionedCollectionElement<Section, Element>]
}

public enum SectionedCollectionElement<Section: SequenceDiffable, Element: SequenceDiffable>: SequenceDiffable {
    case section(Section)
    case element(Element)
    public var identifier: String {
        switch self {
        case let .section(section):
            return "section-\(section.identifier)"
        case let .element(element):
            return "element-\(element.identifier)"
        }
    }
    
    public var hashValue: Int {
        return identifier.hashValue
    }
}

public func ==<Section, Element>(lhs: SectionedCollectionElement<Section, Element>, rhs: SectionedCollectionElement<Section, Element>) -> Bool {
    switch (lhs, rhs) {
    case (let .section(lhsSection), let .section(rhsSection)):
        return lhsSection == rhsSection
    case (let .element(lhsElement), let .element(rhsElement)):
        return lhsElement == rhsElement
    default:
        return false
    }
}

public extension SectionedCollectionConvertible {
    public func tableDiff(a: [SectionedCollectionElement<Section, Element>], b: [SectionedCollectionElement<Section, Element>], implementation: Implementation = .allMoves, updateStyle: UpdateIndicesStyle = .pre) -> (diff: Set<SectionedDiffStep>, updates: Set<NSIndexPath>)
    {
        var sectionIndices: [Int] = []
        for (index, element) in a.enumerate() {
            if case .section(_) = element {
                sectionIndices.append(index)
            }
        }
        switch implementation {
        case .lcs:
            let (diff, updates) = a.lcsTableDiff(b, processMoves: false, updateStyle: updateStyle)
            return toIndexPaths(diff, updates: updates, sections: sectionIndices)
        case .lcsWithMoves:
            let (diff, updates) = a.lcsTableDiff(b, processMoves: true, updateStyle: updateStyle)
            return toIndexPaths(diff, updates: updates, sections: sectionIndices)
        case .allMoves:
            let (diff, updates) = a.allMovesTableDiff(b, updateStyle: updateStyle)
            return toIndexPaths(diff, updates: updates, sections: sectionIndices)
        }
    }
    
    func toIndexPaths(diff: Set<DiffStep<Int>>, updates: Set<Int>, sections: [Int]) -> (diff: Set<SectionedDiffStep>, updates: Set<NSIndexPath>) {
        var indexPathDiffs: Set<SectionedDiffStep> = []
        var indexPathUpdates: Set<NSIndexPath> = []
        for step in diff {
            switch step {
            case .insert(let index):
                let newStep = SectionedDiffStep.insert(atIndex: makeIndexPath(index, sectionIndices: sections))
                indexPathDiffs.insert(newStep)
                break
            case .delete(let index):
                let newStep = SectionedDiffStep.delete(fromIndex: makeIndexPath(index, sectionIndices: sections))
                indexPathDiffs.insert(newStep)
                break
            case .move(let from, let to):
                let newStep = SectionedDiffStep.move(fromIndex: makeIndexPath(from, sectionIndices: sections), toIndex: makeIndexPath(to, sectionIndices: sections))
                indexPathDiffs.insert(newStep)
                break
            }
        }
        
        for step in updates {
            indexPathUpdates.insert(makeIndexPath(step, sectionIndices: sections))
        }
        return (diff:indexPathDiffs, updates: indexPathUpdates)
    }
    
    func makeIndexPath(target: Int, sectionIndices: [Int]) -> NSIndexPath {
        for (index, sectionIndex) in sectionIndices.enumerate() {
            if target < sectionIndex {
                return NSIndexPath(forRow: target - (sectionIndices[index - 1] + index), inSection: index - 1)
            }
        }
        return NSIndexPath(forRow: target - (sectionIndices[sectionIndices.count - 1] + sectionIndices.count - 1), inSection: sectionIndices.count - 1)
    }
}

