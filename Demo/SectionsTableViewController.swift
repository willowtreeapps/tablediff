//
//  SectionsTableViewController.swift
//  DeepDiff
//
//  Created by Kent White on 8/1/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit
import DeepDiff

extension String: SequenceDiffable {
    public var identifier: String { return self }
}

struct DataSource: SectionedCollectionConvertible {
    typealias Section = String
    typealias Element = Int
    var sections: [Section]
    var elements: [[Element]]
    
    func toSectionedCollection() -> ([SectionedCollectionElement<Section, Element>], SectionIndices: [Int]) {
        var sectionedCollection: [SectionedCollectionElement<Section, Element>] = []
        var sectionIndices: [Int] = []
        for (index, sectionElements) in elements.enumerate() {
            let section = SectionedCollectionElement<Section, Element>.section(sections[index])
            sectionIndices.append(sectionedCollection.count)
            sectionedCollection.append(section)
            for element in sectionElements {
                sectionedCollection.append(SectionedCollectionElement<Section, Element>.element(element))
            }
        }
        return (sectionedCollection, sectionIndices)
    }
}

class SectionsTableViewController: UITableViewController {
    var dataSource = DataSource(sections: ["First", "Second"], elements: [[6, 2, 3], [4, 5]])
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSource.sections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.elements[section].count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource.sections[section]
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ElementsCell")!
        cell.textLabel?.text = String(dataSource.elements[indexPath.section][indexPath.row])
        return cell
    }
    
    @IBAction func nextPressed(sender: AnyObject) {
        let old = dataSource
        let new = DataSource(sections: ["First", "Second"], elements: [[2], [3, 4, 5, 1]])
        
        let (diff, _) = old.tableDiff(old, new)
        
        for step in diff {
            switch step {
            case .insert(let index):
                tableView.insertRowsAtIndexPaths([index], withRowAnimation: .Automatic)
            case .delete(let index):
                tableView.deleteRowsAtIndexPaths([index], withRowAnimation: .Automatic)
            case .move(let from, let to):
                tableView.moveRowAtIndexPath(from, toIndexPath: to)
            case .insertSection(let index):
                tableView.insertSections(NSIndexSet(index: index), withRowAnimation: .Automatic)
            case .deleteSection(let index):
                tableView.deleteSections(NSIndexSet(index: index), withRowAnimation: .Automatic)
            case .moveSection(let from, let to):
                tableView.moveSection(from, toSection: to)
            }
        }
        
        
        //tableView.applyDiff(diff)
    }
}

