//
//  CollectionViewController.swift
//  TableDiff
//
//  Created by Kent White on 7/5/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

let reusableIdentifier = "EmojiCellIdentifier"
class CollectionViewController: UICollectionViewController {
    var possibleEmojis = [
        Emoji(identifier: "0", name: "Tongue", image: UIImage(named: "tongue")!, color: UIColor.whiteColor()),
        Emoji(identifier: "1", name: "Blush", image: UIImage(named: "blush")!, color: UIColor.whiteColor()),
        Emoji(identifier: "2", name: "Content", image: UIImage(named: "content")!, color: UIColor.whiteColor()),
        Emoji(identifier: "3", name: "Cry", image: UIImage(named: "cry")!, color: UIColor.whiteColor()),
        Emoji(identifier: "4", name: "Sob", image: UIImage(named: "sob")!, color: UIColor.whiteColor()),
        Emoji(identifier: "5", name: "Thinking", image: UIImage(named: "thinking")!, color: UIColor.whiteColor()),
        Emoji(identifier: "6", name: "Cool", image: UIImage(named: "cool")!, color: UIColor.whiteColor()),
        Emoji(identifier: "7", name: "Dog", image: UIImage(named: "dog")!, color: UIColor.whiteColor()),
        Emoji(identifier: "8", name: "Heart", image: UIImage(named: "heart")!, color: UIColor.whiteColor()),
        Emoji(identifier: "9", name: "Monkey", image: UIImage(named: "monkey")!, color: UIColor.whiteColor()),
        Emoji(identifier: "10", name: "Nerd", image: UIImage(named: "nerd")!, color: UIColor.whiteColor()),
        Emoji(identifier: "11", name: "Wink", image: UIImage(named: "wink")!, color: UIColor.whiteColor()),
        Emoji(identifier: "12", name: "Parrot", image: UIImage.gifWithName("parrot")!, color: UIColor.whiteColor()),
        Emoji(identifier: "13", name: "Fiesta Parrot", image: UIImage.gifWithName("fiestaparrot")!, color: UIColor.whiteColor()),
        Emoji(identifier: "14", name: "Conga Parrot", image: UIImage.gifWithName("congaparrot")!, color: UIColor.whiteColor()),
        Emoji(identifier: "15", name: "Parrot Cop", image: UIImage.gifWithName("parrotcop")!, color: UIColor.whiteColor()),
        Emoji(identifier: "16", name: "Sad Parrot", image: UIImage.gifWithName("sadparrot")!, color: UIColor.whiteColor()),
    ]
    var emojis: [Emoji] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emojis = possibleEmojis
        collectionView?.backgroundColor = UIColor.whiteColor()
        collectionView?.alwaysBounceVertical = true
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(CollectionViewController.refresh), forControlEvents: .ValueChanged)
        collectionView?.addSubview(refreshControl)
        emojis = randomize(possibleEmojis)
    }
    
    func refresh(control: UIRefreshControl) {
        let newArray = randomize(possibleEmojis)
        let (diff, updates) = emojis.tableDiff(newArray)

        let visibleIndices = Set((self.collectionView?.indexPathsForVisibleItems() ?? []).map { $0.item })
        for index in updates.intersect(visibleIndices) {
            let cell = self.collectionView?.cellForItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0)) as? EmojiCell
            cell?.update(self.emojis[index])
        }
        
        emojis = newArray
        collectionView?.applyDiff(diff, completion: {(finished) -> Void in
            control.endRefreshing()
        })
        
    }
    
    func randomize(array: [Emoji]) -> [Emoji] {
        var array = array
        for i in 0..<array.count - 1 {
            let j = Int(arc4random_uniform(UInt32(array.count - i))) + i
            if i != j {
                swap(&array[i], &array[j])
                let roll = (Double(arc4random() % 100))/100.0
                array[i].color = roll < 0.2 ? UIColor.blueColor().colorWithAlphaComponent(0.5) : .whiteColor()
            }
        }
        let subsetCount: Int = Int(arc4random_uniform(3)) + (array.count/2)
        return Array(array[0...subsetCount])
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reusableIdentifier, forIndexPath: indexPath) as! EmojiCell
        cell.setup(emojis[indexPath.row])
        return cell
    }
    
}
