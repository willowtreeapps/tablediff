//
//  NumbersViewController.swift
//  DeepDiff
//
//  Created by Ian Terrell on 7/8/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit
import DeepDiff

extension Int: SequenceDiffable {
    public var identifier: Int { return self }
}

class NumbersViewController: UITableViewController {

    var index = 0 {
        didSet {
            if index == numbers.count {
                index = 0
            }
        }
    }
    var numbers: [[Int]] = [
        [],
        [1],
        [],
        [1, 2],
        [2, 1],
        [1, 2, 3],
        [2, 3],
        [342, 604, 390, 870, 745],
        [870, 604, 745, 390, 342],
    ]

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numbers[index].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NumberCell")!
        cell.textLabel?.text = String(numbers[index][indexPath.row])
        return cell
    }

    @IBAction func next(sender: AnyObject) {
        let old = numbers[index]
        index += 1
        let new = numbers[index]

        let (diff, _) = old.deepDiff(new)
        tableView.beginUpdates()
        for step in diff {
            switch step {
            case .move(let i, let j):
                tableView.moveRowAtIndexPath(NSIndexPath(forItem: i, inSection: 0), toIndexPath: NSIndexPath(forItem: j, inSection: 0))
            case .insert(let i):
                tableView.insertRowsAtIndexPaths([NSIndexPath(forItem: i, inSection: 0)], withRowAnimation: .Automatic)
            case .delete(let i):
                tableView.deleteRowsAtIndexPaths([NSIndexPath(forItem: i, inSection: 0)], withRowAnimation: .Automatic)
            }
        }
        tableView.endUpdates()
    }
}
