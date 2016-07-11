//
//  LCS.swift
//  DeepDiff
//
//  Created by Ian Terrell on 7/11/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation

extension CollectionType where Self.Generator.Element: SequenceDiffable, Self.Index: BidirectionalIndexType {
    func lcsTableDiff(b: Self, processMoves: Bool, updateStyle: UpdateIndicesStyle) ->
        (diff: [DiffStep<Self.Generator.Element, Self.Index>],
        updates: [Update<Self.Generator.Element, Self.Index>])
    {
        let a = self
        let (table, updates) = buildTable(a, b, updateStyle: updateStyle)
        var diff = buildDiff(table, a, b, a.endIndex, b.endIndex, Int(a.count.toIntMax()), Int(b.count.toIntMax()))
        if processMoves {
            diff = processDiff(diff)
        }
        return (diff: diff, updates: updates)
    }

    func buildTable(a: Self, _ b: Self, updateStyle: UpdateIndicesStyle) -> ([[Int]], [Update<Self.Generator.Element, Self.Index>]) {
        var table = Array(count: Int(a.count.toIntMax()) + 1, repeatedValue: Array(count: Int(b.count.toIntMax()) + 1, repeatedValue: 0))
        var updates: [Update<Self.Generator.Element, Self.Index>] = []
        var indexA = a.startIndex
        for (i, firstElement) in a.enumerate() {
            var indexB = b.startIndex
            for (j, secondElement) in b.enumerate() {
                if firstElement.identifier == secondElement.identifier {
                    if firstElement != secondElement {
                        print("Indices a: \(indexA) b: \(indexB)")
                        updates.append(Update.init(index: (updateStyle == .pre) ? indexA : indexB, newItem: secondElement))
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
        var dict: [Self.Generator.Element.IdentifierType: DiffStep<Self.Generator.Element, Self.Index>] = [:]
        for step in diff {
            guard let stepValue = step.value else {
                continue
            }
            var foundIdx: Self.Index?
            if let prevStep = dict[stepValue.identifier] {
                guard let prevStepValue = prevStep.value else {
                    dict[stepValue.identifier] = nil
                    continue
                }
                if step != prevStep &&  stepValue.identifier == prevStepValue.identifier {
                    if prevStep.idx == step.idx {
                        if stepValue == prevStepValue{
                            // This is where we would account for a DiffSteps that are insert and delete at the same index for the same object
                            newDiff.append(step)
                            continue
                        }
                    } else {
                        foundIdx = prevStep.idx
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
                }
                dict[stepValue.identifier] = nil
            } else {
                dict[stepValue.identifier] = step
            }
        }
        for step in dict {
            newDiff.append(step.1)
        }
        return newDiff
    }
}