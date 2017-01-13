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

extension BidirectionalCollection where Self.Iterator.Element: SequenceDiffable, Self.Index: Hashable {
    func lcsTableDiff(_ b: Self, processMoves: Bool) -> (diff: Set<DiffStep<Self.Index>>, updates: Set<Self.Index>) {
        let a = self
        let (table, updates) = buildTable(a, b)
        if processMoves {
            let diff: [ItemDiffStep<Self.Iterator.Element, Self.Index>] = buildDiff(table, a, b, a.endIndex, b.endIndex, Int(a.count.toIntMax()), Int(b.count.toIntMax()))
            return (processDiff(diff), updates)
        } else {
            let diff: [DiffStep<Self.Index>] = buildDiff(table, a, b, a.endIndex, b.endIndex, Int(a.count.toIntMax()), Int(b.count.toIntMax()))
            return (Set(diff), updates)
        }
    }

    func buildTable(_ a: Self, _ b: Self) -> ([[Int]], Set<Self.Index>) {
        var table = Array(repeating: Array(repeating: 0, count: Int(b.count.toIntMax()) + 1), count: Int(a.count.toIntMax()) + 1)
        var updates: Set<Self.Index> = []
        var indexA = a.startIndex
        for (i, firstElement) in a.enumerated() {
            var indexB = b.startIndex
            for (j, secondElement) in b.enumerated() {
                if firstElement.identifier == secondElement.identifier {
                    if firstElement != secondElement {
                        updates.insert(indexB)
                    }
                    table[i+1][j+1] = table[i][j] + 1
                } else {
                    table[i+1][j+1] = Swift.max(table[i][j+1], table[i+1][j])
                }
                indexB = b.index(after: indexB)
            }
            indexA = a.index(after: indexA)
        }
        return (table, updates)
    }

    func buildDiff(_ table: [[Int]], _ x: Self, _ y: Self, _ i: Index, _ j: Index, _ ii: Int, _ jj: Int) -> [DiffStep<Self.Index>] {
        if ii == 0 && jj == 0 {
            return []
        } else if ii == 0 {
            return buildDiff(table, x, y, i, y.index(before: j), ii, jj - 1) +
                [DiffStep.insert(atIndex: y.index(before: j))]
        } else if jj == 0 {
            return buildDiff(table, x, y, x.index(before: i), j, ii - 1, jj) +
                [DiffStep.delete(fromIndex: x.index(before: i))]
        } else if table[ii][jj] == table[ii][jj - 1] {
            return buildDiff(table, x, y, i, y.index(before: j), ii, jj - 1) +
                [DiffStep.insert(atIndex: y.index(before: j))]
        } else if table[ii][jj] == table[ii-1][jj] {
            return buildDiff(table, x, y, x.index(before: i), j, ii - 1, jj) +
                [DiffStep.delete(fromIndex: x.index(before: i))]
        } else {
            return buildDiff(table, x, y, x.index(before: i), y.index(before: j), ii - 1, jj - 1)
        }
    }

    func buildDiff(_ table: [[Int]], _ x: Self, _ y: Self, _ i: Index, _ j: Index, _ ii: Int, _ jj: Int) -> [ItemDiffStep<Self.Iterator.Element, Self.Index>] {
        if ii == 0 && jj == 0 {
            return[]
        } else if ii == 0 {
            return buildDiff(table, x, y, i, y.index(before: j), ii, jj - 1) +
                [ItemDiffStep(item: y[y.index(before: j)], step: DiffStep.insert(atIndex: y.index(before: j)))]
        } else if jj == 0 {
            return buildDiff(table, x, y, x.index(before: i), j, ii - 1, jj) +
                [ItemDiffStep(item: x[x.index(before: i)], step: DiffStep.delete(fromIndex: x.index(before: i)))]
        } else if table[ii][jj] == table[ii][jj - 1] {
            return buildDiff(table, x, y, i, y.index(before: j), ii, jj - 1) +
                [ItemDiffStep(item: y[y.index(before: j)], step: DiffStep.insert(atIndex: y.index(before: j)))]
        } else if table[ii][jj] == table[ii-1][jj] {
            return buildDiff(table, x, y, x.index(before: i), j, ii - 1, jj) +
                [ItemDiffStep(item: x[x.index(before: i)], step: DiffStep.delete(fromIndex: x.index(before: i)))]
        } else {
            return buildDiff(table, x, y, x.index(before: i), y.index(before: j), ii - 1, jj - 1)
        }
    }

    func processDiff(_ diff: [ItemDiffStep<Self.Iterator.Element, Self.Index>]) -> Set<DiffStep<Self.Index>>  {
        var newDiff: Set<DiffStep<Self.Index>> = []
        var dict: [Self.Iterator.Element: ItemDiffStep<Self.Iterator.Element, Self.Index>] = [:]
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
