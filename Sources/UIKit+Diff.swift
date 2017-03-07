//
//  UIKit+Diff.swift
//  TableDiff
//
//  Created by Kent White on 7/12/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

public extension UITableView {
    public func apply(diff: Set<DiffStep<Int>>,
                      section: Int = 0,
                      insertRowAnimation: UITableViewRowAnimation = .automatic,
                      deleteRowAnimation: UITableViewRowAnimation = .automatic)
    {
        beginUpdates()
        applyWithoutBatch(diff: diff,
                          section: section,
                          insertRowAnimation: insertRowAnimation,
                          deleteRowAnimation: deleteRowAnimation)
        endUpdates()
    }

    public func updateVisible(rows updates: Set<Int>, _ callback: (Int) -> Void) {
        guard let visibleRows = indexPathsForVisibleRows?.map({ $0.row }) else {
            return
        }
        updates.intersection(Set(visibleRows)).forEach(callback)
    }

    public func apply(diff: (diff: Set<DiffStep<Int>>, updates: Set<Int>),
                      section: Int = 0,
                      insertRowAnimation insert: UITableViewRowAnimation = .automatic,
                      deleteRowAnimation delete: UITableViewRowAnimation = .automatic,
                      updateVisibleRow: (Int) -> Void)
    {
        apply(diff: diff.diff, section: section, insertRowAnimation: insert, deleteRowAnimation: delete)
        updateVisible(rows: diff.updates, updateVisibleRow)
    }
    
    public func apply(diff: Set<DiffStep<IndexPath>>,
                      insertRowAnimation: UITableViewRowAnimation = .automatic,
                      deleteRowAnimation: UITableViewRowAnimation = .automatic)
    {
        beginUpdates()
        self.applyWithoutBatch(diff: diff,
                               insertRowAnimation: insertRowAnimation,
                               deleteRowAnimation: deleteRowAnimation)
        endUpdates()
    }

    @objc(updateVisibleRowByIndexPaths::)
    public func updateVisible(rows updates: Set<IndexPath>, _ callback: (IndexPath) -> Void) {
        guard let visibleRows = indexPathsForVisibleRows else {
            return
        }
        updates.intersection(Set(visibleRows)).forEach(callback)
    }

    public func apply(diff: (diff: Set<DiffStep<IndexPath>>, updates: Set<IndexPath>),
                      insertRowAnimation insert: UITableViewRowAnimation = .automatic,
                      deleteRowAnimation delete: UITableViewRowAnimation = .automatic,
                      updateVisibleRow: (IndexPath) -> Void)
    {
        apply(diff: diff.diff, insertRowAnimation: insert, deleteRowAnimation: delete)
        updateVisible(rows: diff.updates, updateVisibleRow)
    }

    public func applyWithoutBatch(diff: Set<DiffStep<Int>>, section: Int,
                                  insertRowAnimation: UITableViewRowAnimation = .automatic,
                                  deleteRowAnimation: UITableViewRowAnimation = .automatic) {
        var insertionIndexPaths: [IndexPath] = []
        var deletionIndexPaths: [IndexPath] = []
        for step in diff {
            switch step {
            case .insert(let index):
                insertionIndexPaths.append(IndexPath(row: index, section: section))
            case .delete(let index):
                deletionIndexPaths.append(IndexPath(row: index, section: section))
            case .move(let from, let to):
                moveRow(at: IndexPath(row: from, section: section),
                        to: IndexPath(row: to, section: section))
            }
        }
        insertRows(at: insertionIndexPaths, with: insertRowAnimation)
        deleteRows(at: deletionIndexPaths, with: deleteRowAnimation)
    }

    public func applyWithoutBatch(diff: Set<DiffStep<IndexPath>>,
                                  insertRowAnimation: UITableViewRowAnimation = .automatic,
                                  deleteRowAnimation: UITableViewRowAnimation = .automatic) {
        var insertionIndexPaths: [IndexPath] = []
        var deletionIndexPaths: [IndexPath] = []
        for step in diff {
            switch step {
            case .insert(let index):
                insertionIndexPaths.append(index)
            case .delete(let index):
                deletionIndexPaths.append(index)
            case .move(let from, let to):
                moveRow(at: from, to: to)
            }
        }
        insertRows(at: insertionIndexPaths, with: insertRowAnimation)
        deleteRows(at: deletionIndexPaths, with: deleteRowAnimation)
    }
}

public extension UICollectionView {
    public func applyWithoutBatch(diff: Set<DiffStep<Int>>, section: Int) {
        var insertionIndexPaths: [IndexPath] = []
        var deletionIndexPaths: [IndexPath] = []
        for step in diff {
            switch step {
            case .insert(let i):
                insertionIndexPaths.append(IndexPath(row: i, section: section))
            case .delete(let i):
                deletionIndexPaths.append(IndexPath(row: i, section: section))
            case .move(let fromIndex, let toIndex):
                self.moveItem(at: IndexPath(row: fromIndex, section: section),
                              to: IndexPath(row: toIndex, section: section))
            }
        }
        self.insertItems(at: insertionIndexPaths)
        self.deleteItems(at: deletionIndexPaths)
    }

    public func applyWithoutBatch(diff: Set<DiffStep<IndexPath>>) {
        var insertionIndexPaths: [IndexPath] = []
        var deletionIndexPaths: [IndexPath] = []
        for step in diff {
            switch step {
            case .insert(let i):
                insertionIndexPaths.append(i)
            case .delete(let i):
                deletionIndexPaths.append(i)
            case .move(let fromIndex, let toIndex):
                self.moveItem(at: fromIndex, to: toIndex)
            }
        }
        self.insertItems(at: insertionIndexPaths)
        self.deleteItems(at: deletionIndexPaths)
    }

    public func apply(diff: Set<DiffStep<Int>>,
                      section: Int = 0,
                      completion: ((Bool) -> Void)? = nil)
    {
        performBatchUpdates({
            self.applyWithoutBatch(diff: diff, section: section)
        }, completion: completion)
        
    }

    public func updateVisible(items updates: Set<Int>, _ callback: (Int) -> Void) {
        let visibleItems = indexPathsForVisibleItems.map({ $0.row })
        updates.intersection(Set(visibleItems)).forEach(callback)
    }

    public func apply(diff: (diff: Set<DiffStep<Int>>, updates: Set<Int>),
                      section: Int = 0,
                      completion: ((Bool) -> Void)? = nil,
                      updateVisibleItem: (Int) -> Void)
    {
        apply(diff: diff.diff, section: section, completion: completion)
        updateVisible(items: diff.updates, updateVisibleItem)
    }

    public func apply(diff: Set<DiffStep<IndexPath>>, completion: ((Bool) -> Void)? = nil) {
        performBatchUpdates({
            self.applyWithoutBatch(diff: diff)
        }, completion: completion)
    }

    @objc(updateVisibleItemsByIndexPath::)
    public func updateVisible(items updates: Set<IndexPath>, _ callback: (IndexPath) -> Void) {
        updates.intersection(Set(indexPathsForVisibleItems)).forEach(callback)
    }

    public func apply(diff: (diff: Set<DiffStep<IndexPath>>, updates: Set<IndexPath>),
                      completion: ((Bool) -> Void)? = nil,
                      updateVisibleItem: (IndexPath) -> Void)
    {
        apply(diff: diff.diff, completion: completion)
        updateVisible(items: diff.updates, updateVisibleItem)
    }
}
