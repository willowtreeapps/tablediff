//
//  UIKit+Diff.swift
//  TableDiff
//
//  Created by Kent White on 7/12/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

public extension UITableView {
    public func applyDiff(_ diff: Set<DiffStep<Int>>,
                          section: Int = 0,
                          insertRowAnimation: UITableViewRowAnimation = .automatic,
                          deleteRowAnimation: UITableViewRowAnimation = .automatic)
    {
        beginUpdates()
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
        endUpdates()
    }
    
    public func applyDiff(_ diff: Set<DiffStep<IndexPath>>,
                          insertRowAnimation: UITableViewRowAnimation = .automatic,
                          deleteRowAnimation: UITableViewRowAnimation = .automatic)
    {
        beginUpdates()
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
        endUpdates()
    }
}

public extension UICollectionView {
    public func applyDiff(_ diff: Set<DiffStep<Int>>,
                          section: Int = 0,
                          completion: ((Bool) -> Void)? = nil)
    {
        performBatchUpdates({
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
        }, completion: completion)
        
    }
    
    public func applyDiff(_ diff: Set<DiffStep<IndexPath>>, completion: ((Bool) -> Void)? = nil) {
        performBatchUpdates({
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
        }, completion: completion)
    }
}
