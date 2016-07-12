//
//  UIKit+Diff.swift
//  DeepDiff
//
//  Created by Kent White on 7/12/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation

public extension UITableView {
    public func applyDiff(diff: Set<DiffStep<Int>>, animationType: UITableViewRowAnimation = .Automatic) {
        beginUpdates()
        var insertionIndexPaths: [NSIndexPath] = []
        var deletionIndexPaths: [NSIndexPath] = []
        for step in diff {
            switch step {
            case .insert(let index):
                insertionIndexPaths.append(NSIndexPath(forRow: index, inSection: 0))
            case .delete(let index):
                deletionIndexPaths.append(NSIndexPath(forRow: index, inSection: 0))
            case .move(let from, let to):
                moveRowAtIndexPath(NSIndexPath(forRow: from, inSection: 0), toIndexPath: NSIndexPath(forRow: to, inSection: 0))
            }
        }
        insertRowsAtIndexPaths(insertionIndexPaths, withRowAnimation: animationType)
        deleteRowsAtIndexPaths(deletionIndexPaths, withRowAnimation: animationType)
        endUpdates()
    }
    
    public func applyDiff(diff: Set<DiffStep<NSIndexPath>>, animationType: UITableViewRowAnimation = .Automatic) {
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
        insertRowsAtIndexPaths(insertionIndexPaths, withRowAnimation: animationType)
        deleteRowsAtIndexPaths(deletionIndexPaths, withRowAnimation: animationType)
        endUpdates()
    }
}

public extension UICollectionView {
    public func applyDiff(diff: Set<DiffStep<Int>>, completion: ((Bool) -> Void)? = nil) {
        performBatchUpdates({
            var insertionIndexPaths: [NSIndexPath] = []
            var deletionIndexPaths: [NSIndexPath] = []
            for step in diff {
                switch step {
                case .insert(let i):
                    insertionIndexPaths.append(NSIndexPath(forRow: i, inSection: 0))
                case .delete(let i):
                    deletionIndexPaths.append(NSIndexPath(forRow: i, inSection: 0))
                case . move(let fromIndex, let toIndex):
                    self.moveItemAtIndexPath(NSIndexPath(forRow: fromIndex, inSection: 0), toIndexPath: NSIndexPath(forRow: toIndex, inSection: 0))
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
                case . move(let fromIndex, let toIndex):
                    self.moveItemAtIndexPath(fromIndex, toIndexPath: toIndex)
                }
            }
            self.insertItemsAtIndexPaths(insertionIndexPaths)
            self.deleteItemsAtIndexPaths(deletionIndexPaths)
        }, completion: completion)
        
    }
}
