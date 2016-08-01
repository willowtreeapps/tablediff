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
            return "Insert row \(index.row) section \(index.section)"
        case delete(let index):
            return "Delete row \(index.row) section \(index.section)"
        case move(let from, let to):
            return "Move row \(from.row) section \(from.section) -> row \(to.row) section \(to.section)"
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
    case (let .insertSection(lhsIndex), let .insertSection(rhsIndex)):
        return lhsIndex == rhsIndex
    case (let .deleteSection(lhsIndex), let .deleteSection(rhsIndex)):
        return lhsIndex == rhsIndex
    case (let .moveSection(fromIndex: lhsFromIndex, toIndex: lhsToIndex), let .moveSection(fromIndex: rhsFromIndex, toIndex: rhsToIndex)):
        return lhsFromIndex == rhsFromIndex && lhsToIndex == rhsToIndex
    default:
        return false
    }
}

public protocol SectionedCollectionConvertible {
    associatedtype Section: SequenceDiffable
    associatedtype Element: SequenceDiffable
    func toSectionedCollection() -> ([SectionedCollectionElement<Section, Element>], SectionIndices: [Int])
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
    public func tableDiff<Convertible: SectionedCollectionConvertible>(a: Convertible, _ b:Convertible, implementation: Implementation = .allMoves, updateStyle: UpdateIndicesStyle = .pre) -> (diff: Set<SectionedDiffStep>, updates: Set<NSIndexPath>)
    {
        let (x, preIndices) = a.toSectionedCollection()
        let (y, postIndices) = b.toSectionedCollection()
        switch implementation {
        case .lcs:
            let (diff, updates) = x.lcsTableDiff(y, processMoves: false, updateStyle: updateStyle)
            return toIndexPaths(diff, updates: updates, preSections: preIndices, postSections: postIndices)
        case .lcsWithMoves:
            let (diff, updates) = x.lcsTableDiff(y, processMoves: true, updateStyle: updateStyle)
            return toIndexPaths(diff, updates: updates, preSections: preIndices, postSections: postIndices)
        case .allMoves:
            let (diff, updates) = x.allMovesTableDiff(y, updateStyle: updateStyle)
            return toIndexPaths(diff, updates: updates, preSections: preIndices, postSections: postIndices)
        }
    }
    
    func toIndexPaths(diff: Set<DiffStep<Int>>, updates: Set<Int>, preSections: [Int], postSections: [Int], updateStyle: UpdateIndicesStyle = .pre) -> (diff: Set<SectionedDiffStep>, updates: Set<NSIndexPath>) {
        var indexPathDiffs: Set<SectionedDiffStep> = []
        var indexPathUpdates: Set<NSIndexPath> = []
        for step in diff {
            switch step {
            case .insert(let index):
                if let index = postSections.indexOf(index) {
                    indexPathDiffs.insert(SectionedDiffStep.insertSection(atIndex: index))
                } else {
                    let newStep = SectionedDiffStep.insert(atIndex: makeIndexPath(index, sectionIndices: postSections))
                    indexPathDiffs.insert(newStep)
                }
                
            case .delete(let index):
                if let index = preSections.indexOf(index) {
                    indexPathDiffs.insert(SectionedDiffStep.deleteSection(fromIndex: index))
                } else {
                    let newStep = SectionedDiffStep.delete(fromIndex: makeIndexPath(index, sectionIndices: preSections))
                    indexPathDiffs.insert(newStep)
                }
            case .move(let from, let to):
                if let from = preSections.indexOf(from), let to = preSections.indexOf(to) {
                    indexPathDiffs.insert(SectionedDiffStep.moveSection(fromIndex: from, toIndex: to))
                } else {
                    let newStep = SectionedDiffStep.move(fromIndex: makeIndexPath(from, sectionIndices: preSections), toIndex: makeIndexPath(to, sectionIndices: preSections))
                    indexPathDiffs.insert(newStep)
                }
            }
        }
        
        //need to account for updating a section
        for step in updates {
            if updateStyle == .pre {
                indexPathUpdates.insert(makeIndexPath(step, sectionIndices: preSections))
            } else {
                indexPathUpdates.insert(makeIndexPath(step, sectionIndices: postSections))
            }
            
        }
        return (diff:indexPathDiffs, updates: indexPathUpdates)
    }
    
    func makeIndexPath(target: Int, sectionIndices: [Int]) -> NSIndexPath {
        var prevSectionIndex: Int = 0
        for (index, sectionIndex) in sectionIndices.enumerate() {
            if target > sectionIndex {
                prevSectionIndex = index
            } else {
                return NSIndexPath(forRow: target - (sectionIndices[prevSectionIndex] + prevSectionIndex + 1), inSection: prevSectionIndex)
            }
        }
        if sectionIndices.count == 0 {
            return NSIndexPath(forRow: target, inSection: 0)
        }
        return NSIndexPath(forRow: target - (sectionIndices[sectionIndices.count - 1] + sectionIndices.count - 1), inSection: prevSectionIndex)
    }
}

public func trimFromSectionedDiff(diff: Set<SectionedDiffStep>) -> Set<SectionedDiffStep> {
    var diff = diff
    var deletes: Set<SectionedDiffStep> = []
    var inserts: Set<SectionedDiffStep> = []
    var moves: Set<SectionedDiffStep> = []
    var deleteSections: [Int] = []
    var insertSections: [Int] = []
    var moveSections: [(Int, Int)] = []
    
    for step in diff {
        switch step {
        case .delete(_):
            deletes.insert(step)
        case .insert(_):
            inserts.insert(step)
        case .move(_, _):
            moves.insert(step)
        case .deleteSection(let index):
            deleteSections.append(index)
        case .insertSection(let index):
            insertSections.append(index)
        case .moveSection(let from , let to):
            moveSections.append((from, to))
        }
    }
    
    for section in deleteSections {
        for delete in deletes {
            if case .delete(let index) = delete where index.section == section {
                diff.remove(delete)
                deletes.remove(delete)
            }
        }
    }
    
    for section in insertSections {
        for insert in inserts {
            if case .insert(let index) = insert where index.section == section {
                diff.remove(insert)
                inserts.remove(insert)
            }
        }
    }
    
    for section in moveSections {
        for move in moves {
            if case .move(let from, let to) = move where from.row == to.row && section.0 == from.section && section.1 == to.section {
                diff.remove(move)
                moves.remove(move)
            }
        }
    }
    
    return diff
}
