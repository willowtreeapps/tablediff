//
//  AllMoves.swift
//  TableDiff
//
//  Created by Ian Terrell on 7/11/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation

extension CollectionType where Self.Generator.Element: SequenceDiffable, Self.Index: Hashable, Self.Index: BidirectionalIndexType {
    func allMovesTableDiff(other: Self, updateStyle: UpdateIndicesStyle) ->
        (diff: Set<DiffStep<Self.Index>>,
        updates: Set<Self.Index>)
    {
        var a_cache: [Self.Generator.Element.IdentifierType: (item: Self.Generator.Element, indices: [Self.Index])] = [:]
        var a_index = self.startIndex
        for a in self {
            a_cache[a.identifier] = a_cache[a.identifier] ?? (item: a, indices: [])
            a_cache[a.identifier]?.indices.append(a_index)
            a_index = a_index.successor()
        }

        var b_cache: [Self.Generator.Element.IdentifierType: (item: Self.Generator.Element, indices: [Self.Index])] = [:]
        var b_index = self.startIndex
        for b in other {
            b_cache[b.identifier] = b_cache[b.identifier] ?? (item: b, indices: [])
            b_cache[b.identifier]?.indices.append(b_index)
            b_index = b_index.successor()
        }

        var diff: Set<DiffStep<Self.Index>> = []
        var updates: Set<Self.Index> = []
        for (id, cache) in a_cache {
            let (item, indices) = cache
            var b_indices = b_cache[id]?.indices ?? []
            let moves = Array(zip(indices,b_indices))
            for (from, to) in moves {
                if from != to {
                    diff.insert(.move(fromIndex: from, toIndex: to))
                }

                let newItem = b_cache[id]!.item
                if item != newItem {
                    let index = updateStyle == .pre ? from : to
                    updates.insert(index)
                }
            }

            for i in moves.count..<indices.count {
                diff.insert(.delete(fromIndex: indices[i]))
            }

            b_indices.removeFirst(min(moves.count, b_indices.count))
            if b_indices.isEmpty {
                b_cache.removeValueForKey(id)
            } else {
                b_cache[id]?.indices = b_indices
            }
        }

        for (id, cache) in b_cache {
            let (_, indices) = cache
            for i in 0..<indices.count {
                diff.insert(.insert(atIndex: indices[i]))
            }

            b_cache.removeValueForKey(id)
        }

        return (diff: diff, updates: updates)
    }
}

/// Trims some extra move steps from a diff. This will trim unnecessary moves made by most
/// inserts and deletes, but will not trim all unnecessary moves made by other moves.
///
/// - Note: It is safe to pass superfluous move commands to TableView and CollectionView, so this 
///   function is not necessary for the UI. It is provided as a convenience for debugging.
public func trimMovesFromDiff(diff: Set<DiffStep<Int>>) -> Set<DiffStep<Int>> {
    var diff = diff
    var deletes: [Int] = []
    var inserts: [Int] = []
    var moves: Set<DiffStep<Int>> = []

    for d in diff {
        switch d {
        case .delete(let i):
            deletes.append(i)
        case .insert(let i):
            inserts.append(i)
        case .move:
            diff.remove(d)
            moves.insert(d)
        }
    }

    func count(indices: [Int]) -> [Int:Int] {
        let indices = indices.sort()
        var byIndex: [Int:Int] = [:]
        var count = 0
        for i in indices {
            count += 1
            byIndex[i] = count
        }
        return byIndex
    }

    var deletesByIndex = count(deletes)
    var insertsByIndex = count(inserts)

    func countAtIndex(inout counts: [Int:Int], index: Int) -> Int {
        var i = index
        var count = counts[index]
        while count == nil && i >= 0 {
            i -= 1
            count = counts[i]
        }
        for j in i..<index {
            counts[j] = (count ?? 0)
        }
        return (count ?? 0)
    }

    for d in moves {
        switch d {
        case .move(let from, let to):
            let nDeleted = countAtIndex(&deletesByIndex, index: from)
            let nInserted = countAtIndex(&insertsByIndex, index: to)
            if from - nDeleted + nInserted != to {
                diff.insert(d)
            }
        default:
            fatalError()
        }
    }
    
    return diff
}
