//
//  ViewController.swift
//  DiffExample
//
//  Created by Kent White on 7/1/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit
import DeepDiff

class ViewController: UITableViewController {
    var array = [342, 604, 390, 870, 745]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let navButton = UIBarButtonItem(title: "Test", style: UIBarButtonItemStyle.Done, target: self, action: #selector(ViewController.testPressed(_:)))
        self.navigationItem.rightBarButtonItem = navButton
        array = randomArray()
    }
    
    
    func testPressed(sender: UIButton) {
        print(array)
        let new = array.shuffled()
        print(new)
        var (diff, updates) = array.deepDiff(new)
        //diff = [DiffStep.move(fromIndex: 0, toIndex: 4), DiffStep.move(fromIndex: 2, toIndex: 3), DiffStep.move(fromIndex: 3, toIndex: 0), DiffStep.move(fromIndex: 4, toIndex: 2)]
        array = new
        for step in diff {
            print(step)
        }
        tableView.beginUpdates()
        var inserts: [NSIndexPath] = []
        var deletes: [NSIndexPath] = []
        for step in diff {
            switch step {
            case .move(let i, let j):
                tableView.moveRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0), toIndexPath: NSIndexPath(forRow: j, inSection: 0))
            case .insert(let i, _):
                inserts.append(NSIndexPath(forRow: i, inSection: 0))
            case .delete(let i, _):
                deletes.append(NSIndexPath(forRow: i, inSection: 0))
            }
        }
        tableView.insertRowsAtIndexPaths(inserts, withRowAnimation: .Automatic)
        tableView.deleteRowsAtIndexPaths(deletes, withRowAnimation: .Automatic)
        tableView.endUpdates()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        cell.textLabel?.text = "\(array[indexPath.row])"
        return cell
    }

}

extension Int: SequenceDiffable {
    public func identifiedSame(other: Int) -> Bool {
        return self == other
    }
}
extension CollectionType {
    func shuffled() -> [Generator.Element] {
        var list = Array(self)
        list.shuffle()
        return list
    }
}

func randomArray(minSize: Int = 0, maxSize: Int = 20, minValue: Int = 0, maxValue: Int = 1000) -> [Int] {
    let count = 20//UInt32(minSize) + arc4random_uniform(UInt32(maxSize-minSize))
    return (0..<count).map { _ in minValue + Int(arc4random_uniform(UInt32(maxValue - minValue))) }
}

extension MutableCollectionType where Index == Int {
    mutating func shuffle() {
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}

