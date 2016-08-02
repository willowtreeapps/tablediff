//
//  UIKit+Diff.swift
//  TableDiff
//
//  Created by Kent White on 7/12/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

public extension UITableView {
    public func applyDiff(diff: Set<DiffStep<Int>>,
                          section: Int = 0,
                          insertRowAnimation: UITableViewRowAnimation = .Automatic,
                          deleteRowAnimation: UITableViewRowAnimation = .Automatic)
    {
        beginUpdates()
        var insertionIndexPaths: [NSIndexPath] = []
        var deletionIndexPaths: [NSIndexPath] = []
        for step in diff {
            switch step {
            case .insert(let index):
                insertionIndexPaths.append(NSIndexPath(forRow: index, inSection: section))
            case .delete(let index):
                deletionIndexPaths.append(NSIndexPath(forRow: index, inSection: section))
            case .move(let from, let to):
                moveRowAtIndexPath(NSIndexPath(forRow: from, inSection: section),
                                   toIndexPath: NSIndexPath(forRow: to, inSection: section))
            }
        }
        insertRowsAtIndexPaths(insertionIndexPaths, withRowAnimation: insertRowAnimation)
        deleteRowsAtIndexPaths(deletionIndexPaths, withRowAnimation: deleteRowAnimation)
        endUpdates()
    }
    
    public func applyDiff(diff: Set<DiffStep<NSIndexPath>>,
                          insertRowAnimation: UITableViewRowAnimation = .Automatic,
                          deleteRowAnimation: UITableViewRowAnimation = .Automatic)
    {
        beginUpdates()
        var insertionIndexPaths: [NSIndexPath] = []
        var deletionIndexPaths: [NSIndexPath] = []
        for step in diff {
            switch step {
            case .insert(let index):
                insertionIndexPaths.append(index)
            case .delete(let index):
                deletionIndexPaths.append(index)
            case .move(let from, let to):
                moveRowAtIndexPath(from, toIndexPath: to)
            }
        }
        insertRowsAtIndexPaths(insertionIndexPaths, withRowAnimation: insertRowAnimation)
        deleteRowsAtIndexPaths(deletionIndexPaths, withRowAnimation: deleteRowAnimation)
        endUpdates()
    }
}

public extension UICollectionView {
    public func applyDiff(diff: Set<DiffStep<Int>>,
                          section: Int = 0,
                          completion: ((Bool) -> Void)? = nil)
    {
        performBatchUpdates({
            var insertionIndexPaths: [NSIndexPath] = []
            var deletionIndexPaths: [NSIndexPath] = []
            for step in diff {
                switch step {
                case .insert(let i):
                    insertionIndexPaths.append(NSIndexPath(forRow: i, inSection: section))
                case .delete(let i):
                    deletionIndexPaths.append(NSIndexPath(forRow: i, inSection: section))
                case .move(let fromIndex, let toIndex):
                    self.moveItemAtIndexPath(NSIndexPath(forRow: fromIndex, inSection: section),
                        toIndexPath: NSIndexPath(forRow: toIndex, inSection: section))
                }
            }
            self.insertItemsAtIndexPaths(insertionIndexPaths)
            self.deleteItemsAtIndexPaths(deletionIndexPaths)
        }, completion: completion)
        
    }
    
    public func applyDiff(diff: Set<DiffStep<NSIndexPath>>, completion: ((Bool) -> Void)? = nil) {
        performBatchUpdates({
            var insertionIndexPaths: [NSIndexPath] = []
            var deletionIndexPaths: [NSIndexPath] = []
            for step in diff {
                switch step {
                case .insert(let i):
                    insertionIndexPaths.append(i)
                case .delete(let i):
                    deletionIndexPaths.append(i)
                case .move(let fromIndex, let toIndex):
                    self.moveItemAtIndexPath(fromIndex, toIndexPath: toIndex)
                }
            }
            self.insertItemsAtIndexPaths(insertionIndexPaths)
            self.deleteItemsAtIndexPaths(deletionIndexPaths)
        }, completion: completion)
    }
}
