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
protocol Identifiable {
    func identifiedSame(other: Self) -> Bool
}

/// Represents a type that can be diffed with another instance in
/// order to find the instruction set to change it into the other.
protocol SequenceDiffable: Identifiable, Equatable/*, Indexable*/ {
    associatedtype Index
}

/// Represents instructions necessary to move a sequence from its current
/// state into another state.
public enum DiffStep<T, Index> {
    case insert(atIndex: Index, item: T)
    case delete(fromIndex: Index)
    case move(fromIndex: Index, toIndex: Index)
}

/// Represents an update instruction, where the item at the given index should
/// be updated with the new contents.
///
/// oldItem.identifier == newItem.identifier
struct Update<Index, T> {
    let index: Index
    let newItem: T
}

extension SequenceType where Self.Generator.Element: SequenceDiffable {
    
    /// Creates a deep diff between two sequences.
    func deepDiff(a: Self, b: Self) ->
        (diff: [DiffStep<Self.Generator.Element, Self.Generator.Element.Index>],
        updates: [Update<Self.Generator.Element.Index, Self.Generator.Element>])
    {
        let table = buildTable(a, b)
        for i in 1...table.count {
            print(table[i - 1])
        }
        buildDiff(table, a, b)
        
        // IMPLEMENT ME!
        return (diff: [], updates: [])
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
    
    func buildDiff(table: [[Int]], _ x: Self, _ y: Self) -> [DiffStep<Self.Generator.Element, Self.Generator.Element.Index>] {
        return []
    }
}


protocol SequenceDiffableSection {
    associatedtype Identifier: SequenceDiffable
    associatedtype Element: SequenceDiffable
    
    var identifier: Identifier { get }
    var elements: [Element] { get }
}

struct SectionedCollection<S: SequenceDiffableSection where S.Identifier.Index == Int, S.Element.Index == NSIndexPath>: SequenceType {
    var sections: [S]
    
    func generate() -> SectionedCollectionGenerator<S> {
        return SectionedCollectionGenerator<S>(sections: sections)
    }
}

struct SectionedCollectionGenerator<Section: SequenceDiffableSection>: GeneratorType {
    let sections: [Section]
    
    init(sections: [Section]) {
        self.sections = sections
    }
    
    func next() -> SectionedCollectionElement<Section.Identifier, Section.Element>? {
        // IMPLEMENT ME!
        return .section(sections.first!.identifier)
    }
}

enum SectionedCollectionElement<SectionIdentifier, Element where SectionIdentifier: SequenceDiffable, Element: SequenceDiffable> {
    case section(SectionIdentifier)
    case element(Element)
}
