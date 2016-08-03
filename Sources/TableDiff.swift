//
//  TableDiff.swift
//  TableDiff
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
    associatedtype IdentifierType: Hashable
    var identifier: IdentifierType { get }
}

/// Represents a type that can be diffed with another instance in
/// order to find the instruction set to change it into the other.
public protocol SequenceDiffable: Identifiable, Hashable { }

/// Represents instructions necessary to move a sequence from its current
/// state into another state.
public enum DiffStep<Index: Hashable>: Hashable, CustomDebugStringConvertible {
    case insert(atIndex: Index)
    case delete(fromIndex: Index)
    case move(fromIndex: Index, toIndex: Index)

    public var hashValue: Int {
        switch self {
        case insert(let i):
            return 100000000 + i.hashValue
        case delete(let i):
            return 200000000 + i.hashValue
        case move(let from, _):
            return 300000000 + from.hashValue
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
        }
    }
}

public func ==<Index>(lhs: DiffStep<Index>, rhs: DiffStep<Index>) -> Bool {
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

public enum UpdateIndicesStyle {
    case pre
    case post
}

public enum Implementation {
    case lcs
    case lcsWithMoves
    case allMoves
}

public extension CollectionType where Self.Generator.Element: SequenceDiffable, Self.Index: Hashable, Self.Index: BidirectionalIndexType {
    /// Creates a deep diff between two sequences.
    public func tableDiff(b: Self, implementation: Implementation = .allMoves, updateStyle: UpdateIndicesStyle = .pre) ->
        (diff: Set<DiffStep<Self.Index>>,
        updates: Set<Self.Index>)
    {
        switch implementation {
        case .lcs:
            return lcsTableDiff(b, processMoves: false, updateStyle: updateStyle)
        case .lcsWithMoves:
            return lcsTableDiff(b, processMoves: true, updateStyle: updateStyle)
        case .allMoves:
            return allMovesTableDiff(b, updateStyle: updateStyle)
        }
    }
}
