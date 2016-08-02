//
//  LCS.swift
//  TableDiff
//
//  Created by Ian Terrell on 7/11/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation

struct ItemDiffStep<T: SequenceDiffable, Index: Hashable> {
    let item: T
    let step: DiffStep<Index>
}

extension DiffStep {
    var idx: Index {
        switch self {
        case .insert(let i):
            return i
        case .delete(let i):
            return i
        case .move(let from, _):
            return from
        }
    }

    var isInsertion: Bool {
        switch self {
        case .insert:
            return true
        default:
            return false
        }
    }
}

extension CollectionType where Self.Generator.Element: SequenceDiffable, Self.Index: Hashable, Self.Index: BidirectionalIndexType {
    func lcsTableDiff(b: Self, processMoves: Bool, updateStyle: UpdateIndicesStyle) ->
        (diff: Set<DiffStep<Self.Index>>,
        updates: Set<Self.Index>)
    {
        let a = self
        let (table, updates) = buildTable(a, b, updateStyle: updateStyle)
        if processMoves {
            let diff: [ItemDiffStep<Self.Generator.Element, Self.Index>] = buildDiff(table, a, b, a.endIndex, b.endIndex, Int(a.count.toIntMax()), Int(b.count.toIntMax()))
            return (processDiff(diff), updates)
        } else {
            let diff: [DiffStep<Self.Index>] = buildDiff(table, a, b, a.endIndex, b.endIndex, Int(a.count.toIntMax()), Int(b.count.toIntMax()))
            return (Set(diff), updates)
        }
    }

    func buildTable(a: Self, _ b: Self, updateStyle: UpdateIndicesStyle) -> ([[Int]], Set<Self.Index>) {
        var table = Array(count: Int(a.count.toIntMax()) + 1, repeatedValue: Array(count: Int(b.count.toIntMax()) + 1, repeatedValue: 0))
        var updates: Set<Self.Index> = []
        var indexA = a.startIndex
        for (i, firstElement) in a.enumerate() {
            var indexB = b.startIndex
            for (j, secondElement) in b.enumerate() {
                if firstElement.identifier == secondElement.identifier {
                    if firstElement != secondElement {
                        print("Indices a: \(indexA) b: \(indexB)")
                        updates.insert(updateStyle == .pre ? indexA : indexB)
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

    func buildDiff(table: [[Int]], _ x: Self, _ y: Self, _ i: Index, _ j: Index, _ ii: Int, _ jj: Int) -> [DiffStep<Self.Index>] {
        if ii == 0 && jj == 0 {
            return []
        } else if ii == 0 {
            return buildDiff(table, x, y, i, j.predecessor(), ii, jj - 1) +
                [DiffStep.insert(atIndex: j.predecessor())]
        } else if jj == 0 {
            return buildDiff(table, x, y, i.predecessor(), j, ii - 1, jj) +
                [DiffStep.delete(fromIndex: i.predecessor())]
        } else if table[ii][jj] == table[ii][jj - 1] {
            return buildDiff(table, x, y, i, j.predecessor(), ii, jj - 1) +
                [DiffStep.insert(atIndex: j.predecessor())]
        } else if table[ii][jj] == table[ii-1][jj] {
            return buildDiff(table, x, y, i.predecessor(), j, ii - 1, jj) +
                [DiffStep.delete(fromIndex: i.predecessor())]
        } else {
            return buildDiff(table, x, y, i.predecessor(), j.predecessor(), ii - 1, jj - 1)
        }
    }

    func buildDiff(table: [[Int]], _ x: Self, _ y: Self, _ i: Index, _ j: Index, _ ii: Int, _ jj: Int) -> [ItemDiffStep<Self.Generator.Element, Self.Index>] {
        if ii == 0 && jj == 0 {
            return[]
        } else if ii == 0 {
            return buildDiff(table, x, y, i, j.predecessor(), ii, jj - 1) +
                [ItemDiffStep(item: y[j.predecessor()], step: DiffStep.insert(atIndex: j.predecessor()))]
        } else if jj == 0 {
            return buildDiff(table, x, y, i.predecessor(), j, ii - 1, jj) +
                [ItemDiffStep(item: x[i.predecessor()], step: DiffStep.delete(fromIndex: i.predecessor()))]
        } else if table[ii][jj] == table[ii][jj - 1] {
            return buildDiff(table, x, y, i, j.predecessor(), ii, jj - 1) +
                [ItemDiffStep(item: y[j.predecessor()], step: DiffStep.insert(atIndex: j.predecessor()))]
        } else if table[ii][jj] == table[ii-1][jj] {
            return buildDiff(table, x, y, i.predecessor(), j, ii - 1, jj) +
                [ItemDiffStep(item: x[i.predecessor()], step: DiffStep.delete(fromIndex: i.predecessor()))]
        } else {
            return buildDiff(table, x, y, i.predecessor(), j.predecessor(), ii - 1, jj - 1)
        }
    }

    func processDiff(diff: [ItemDiffStep<Self.Generator.Element, Self.Index>]) -> Set<DiffStep<Self.Index>>  {
        var newDiff: Set<DiffStep<Self.Index>> = []
        var dict: [Self.Generator.Element: ItemDiffStep<Self.Generator.Element, Self.Index>] = [:]
        for d in diff {
            let stepValue = d.item
            let step = d.step

            var foundIdx: Self.Index?
            if let prev = dict[stepValue] {
                let prevStepValue = prev.item
                let prevStep = prev.step
                if step != prevStep && stepValue.identifier == prevStepValue.identifier {
                    if prevStep.idx == step.idx {
                        if stepValue == prevStepValue{
                            newDiff.insert(step)
                            continue
                        }
                    } else {
                        foundIdx = prevStep.idx
                    }
                }
                if let foundIdx = foundIdx {
                    if step.isInsertion {
                        newDiff.insert(DiffStep.move(fromIndex: foundIdx, toIndex:step.idx))
                    } else {
                        newDiff.insert(DiffStep.move(fromIndex: step.idx, toIndex: foundIdx))
                    }
                }
                dict[stepValue] = nil
            } else {
                dict[stepValue] = d
            }
        }
        for (_, d) in dict {
            newDiff.insert(d.step)
        }
        return newDiff
    }
}
