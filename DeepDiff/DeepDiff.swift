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
    case delete(fromIndex: Index)
    case move(fromIndex: Index, toIndex: Index)
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
}

public func ==<T, Index>(lhs: Update<T,Index>, rhs: Update<T,Index>) -> Bool {
    return lhs.index == rhs.index && lhs.newItem == rhs.newItem
}

public extension CollectionType where Self.Generator.Element: SequenceDiffable {
    
    /// Creates a deep diff between two sequences.
    public func deepDiff(b: Self) ->
        (diff: [DiffStep<Self.Generator.Element, Self.Index>],
        updates: [Update<Self.Index, Self.Generator.Element>])
    {
        let a = self
        let table = buildTable(a, b)
        for i in 1...table.count {
            print(table[i - 1])
        }
        buildDiff(table, a, b)
        
        // IMPLEMENT ME!
        return (diff: [], updates: [])
    }

    /// Apply a diff to this sequence
    public func apply(diff diff: [DiffStep<Self.Generator.Element, Self.Index>],
                       updates: [Update<Self.Index, Self.Generator.Element>]) -> Self
    {
        return self
    }
    
    func buildTable(a: Self, _ b: Self) -> [[Int]] {
        //refactor this to not use underestimate count for none collections
        var table = Array(count: a.underestimateCount() + 1, repeatedValue: Array(count: b.underestimateCount() + 1, repeatedValue: 0))
        for (i, firstElement) in a.enumerate() {
            for (j, secondElement) in b.enumerate() {
                if firstElement == secondElement {
                    table[i+1][j+1] = table[i][j] + 1
                } else {
                    table[i+1][j+1] = max(table[i][j+1], table[i+1][j])
                }
            }
        }
        return table
    }
    
    func buildDiff(table: [[Int]], _ x: Self, _ y: Self) -> [DiffStep<Self.Generator.Element, Self.Index>] {
        return []
    }
}

