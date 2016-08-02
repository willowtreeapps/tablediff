//
//  NumbersViewController.swift
//  TableDiff
//
//  Created by Ian Terrell on 7/8/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit
import TableDiff

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

        let (diff, _) = old.tableDiff(new)
        tableView.applyDiff(diff)
    }
}
