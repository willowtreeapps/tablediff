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
    associatedtype IdentifierType: Hashable
    var identifier: IdentifierType { get }
}

/// Represents a type that can be diffed with another instance in
/// order to find the instruction set to change it into the other.
public protocol SequenceDiffable: Identifiable, Equatable {
}

/// Represents instructions necessary to move a sequence from its current
/// state into another state.
public enum DiffStep<T: Equatable, Index: Equatable>: Equatable, CustomDebugStringConvertible {
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

    public var debugDescription: String {
        switch self {
        case insert(let index, let item):
            return "Insert \(index) (\(item))"
        case delete(let index, _):
            return "Delete \(index)"
        case move(let from, let to):
            return "Move \(from) -> \(to)"
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

public enum Implementation {
    case lcs
    case lcsWithMoves
}

public extension CollectionType where Self.Generator.Element: SequenceDiffable, Self.Index: BidirectionalIndexType {
    /// Creates a deep diff between two sequences.
    public func deepDiff(b: Self, implementation: Implementation = .lcsWithMoves, updateStyle: UpdateIndicesStyle = .post) ->
        (diff: [DiffStep<Self.Generator.Element, Self.Index>],
        updates: [Update<Self.Generator.Element, Self.Index>])
    {
        switch implementation {
        case .lcs:
            return lcsTableDiff(b, processMoves: false, updateStyle: updateStyle)
        case .lcsWithMoves:
            return lcsTableDiff(b, processMoves: true, updateStyle: updateStyle)
        }
    }
}
