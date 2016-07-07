//
//  DeepDif.swift
//  DeepDiff
//
//  Created by Kent White on 6/27/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation

/// Represents whether two instances are the same without being equal.
///
/// For instance, perhaps a struct has been updated, but represents the same
/// logical entity in a data store. In that case, they may have the same id
/// but not the same contents.
public protocol Identifiable {
    func identifiedSame(other: Self) -> Bool
}

/// Represents a type that can be diffed with another instance in
/// order to find the instruction set to change it into the other.
public protocol SequenceDiffable: Identifiable, Equatable {

}

/// Represents instructions necessary to move a sequence from its current
/// state into another state.
public enum DiffStep<T: Equatable, Index: Equatable>: Equatable {
    case insert(atIndex: Index, item: T)
    case delete(fromIndex: Index, item: T)
    case move(fromIndex: Index, toIndex: Index)
    
    var isInsertion: Bool {
        switch(self) {
        case .insert:
            return true
        default:
            return false
        }
    }
    
    public var idx: Index {
        switch(self) {
        case .insert(let i, _):
            return i
        case .delete(let i, _):
            return i
        case .move(let from, _):
            return from
        }
    }
    public var value: T? {
        switch(self) {
        case .insert(_, let item):
            return item
        case .delete(_, let item):
            return item
        default:
            return nil
        }
    }
}

public func ==<T, Index>(lhs: DiffStep<T,Index>, rhs: DiffStep<T,Index>) -> Bool {
    switch (lhs, rhs) {
    case (let .insert(atIndex: lhsIndex, item: lhsItem), let .insert(atIndex: rhsIndex, item: rhsItem)):
        return lhsIndex == rhsIndex && lhsItem == rhsItem
    case (let .delete(fromIndex: lhsIndex), let .delete(fromIndex: rhsIndex)):
        return lhsIndex == rhsIndex
    case (let .move(fromIndex: lhsFromIndex, toIndex: lhsToIndex), let .move(fromIndex: rhsFromIndex, toIndex: rhsToIndex)):
        return lhsFromIndex == rhsFromIndex && lhsToIndex == rhsToIndex
    default:
        return false
    }
}

/// Represents an update instruction, where the item at the given index should
/// be updated with the new contents.
///
/// oldItem.identifier == newItem.identifier
public struct Update<T: Equatable, Index: Equatable>: Equatable {
    let index: Index
    let newItem: T

    public init(index: Index, newItem: T) {
        self.index = index
        self.newItem = newItem
    }
}

public func ==<T, Index>(lhs: Update<T,Index>, rhs: Update<T,Index>) -> Bool {
    return lhs.index == rhs.index && lhs.newItem == rhs.newItem
}

public enum UpdateIndicesStyle {
    case pre
    case post
}

public extension CollectionType where Self.Generator.Element: SequenceDiffable, Self.Index: BidirectionalIndexType {
    /// Creates a deep diff between two sequences.
    public func deepDiff(b: Self, updateStyle: UpdateIndicesStyle = .post) ->
        (diff: [DiffStep<Self.Generator.Element, Self.Index>],
        updates: [Update<Self.Generator.Element, Self.Index>])
    {
        let a = self
        let (table, updates) = buildTable(a, b, updateStyle: updateStyle)
        let diff = buildDiff(table, a, b, a.endIndex, b.endIndex, Int(a.count.toIntMax()), Int(b.count.toIntMax()))
        let processedDiff = processDiff(diff)
        return (diff: processedDiff, updates: updates)
    }

    /// Apply a diff to this sequence
    public func apply(diff diff: [DiffStep<Self.Generator.Element, Self.Index>],
                       updates: [Update<Self.Generator.Element, Self.Index>]) -> Self
        
    {
        return self
    }
    
    func buildTable(a: Self, _ b: Self, updateStyle: UpdateIndicesStyle) -> ([[Int]], [Update<Self.Generator.Element, Self.Index>]) {
        var table = Array(count: Int(a.count.toIntMax()) + 1, repeatedValue: Array(count: Int(b.count.toIntMax()) + 1, repeatedValue: 0))
        var updates: [Update<Self.Generator.Element, Self.Index>] = []
        var indexA = a.startIndex
        for (i, firstElement) in a.enumerate() {
            var indexB = b.startIndex
            for (j, secondElement) in b.enumerate() {
                if firstElement.identifiedSame(secondElement) {
                    if firstElement != secondElement {
                        updates.append(Update.init(index: updateStyle == .pre ? indexA: indexB, newItem: secondElement))
                    }
                    table[i+1][j+1] = table[i][j] + 1
                } else {
                    table[i+1][j+1] = max(table[i][j+1], table[i+1][j])
                }
                indexB = indexB.successor()
            }
            indexA = indexA.successor()
        }
        return (table, updates)
    }
    
    func buildDiff(table: [[Int]], _ x: Self, _ y: Self, _ i: Index, _ j: Index, _ ii: Int, _ jj: Int) -> [DiffStep<Self.Generator.Element, Self.Index>] {
        if ii == 0 && jj == 0 {
            return[]
        } else if ii == 0 {
            return buildDiff(table, x, y, i, j.predecessor(), ii, jj - 1) + [DiffStep.insert(atIndex: j.predecessor(), item: y[j.predecessor()])]
        } else if jj == 0 {
            return buildDiff(table, x, y, i.predecessor(), j, ii - 1, jj) + [DiffStep.delete(fromIndex: i.predecessor(), item: x[i.predecessor()])]
        } else if table[ii][jj] == table[ii][jj - 1] {
            return buildDiff(table, x, y, i, j.predecessor(), ii, jj - 1) + [DiffStep.insert(atIndex: j.predecessor(), item: y[j.predecessor()])]
        } else if table[ii][jj] == table[ii-1][jj] {
            return buildDiff(table, x, y, i.predecessor(), j, ii - 1, jj) + [DiffStep.delete(fromIndex: i.predecessor(), item: x[i.predecessor()])]
        } else {
            return buildDiff(table, x, y, i.predecessor(), j.predecessor(), ii - 1, jj - 1)
        }
    }
    
    // Can be improved with getting rid of the elements once we are done with them and also using a hash table implementation
    func processDiff(diff: [DiffStep<Self.Generator.Element, Self.Index>]) -> [DiffStep<Self.Generator.Element, Self.Index>]  {
        var newDiff: [DiffStep<Self.Generator.Element, Self.Index>] = []
        for step in diff {
            guard let stepValue = step.value else {
                continue
            }
            var foundIdx: Self.Index?
            for step2 in diff {
                guard let step2Value = step2.value else {
                    continue
                }
                if step2 != step &&  step2Value.identifiedSame(stepValue) {
                    if step.idx == step2.idx {
                        if step2Value == stepValue{
                            // This is where we would account for a DiffSteps that are insert and delete at the same index for the same object
                            break
                        }
                    } else {
                        foundIdx = step2.idx
                    }
                    break
                }
            }
            
            if let foundIdx = foundIdx {
                if step.isInsertion {
                    if newDiff.indexOf(DiffStep.move(fromIndex: foundIdx, toIndex: step.idx)) == nil {
                        newDiff.append(DiffStep.move(fromIndex: foundIdx, toIndex:step.idx))
                    }
                } else {
                    if newDiff.indexOf(DiffStep.move(fromIndex: step.idx, toIndex: foundIdx)) == nil {
                        newDiff.append(DiffStep.move(fromIndex: step.idx, toIndex: foundIdx))
                    }
                }
            } else {
                newDiff.append(step)
            }
        }
        return newDiff
    }
}
