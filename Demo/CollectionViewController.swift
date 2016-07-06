//
//  CollectionViewController.swift
//  DeepDiff
//
//  Created by Kent White on 7/5/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

let reusableIdentifier = "EmojiCellIdentifier"
class CollectionViewController: UICollectionViewController {
    var possibleEmojis = [
        Emoji(id: "0", name: "Tongue", image: UIImage(named: "tongue")!),
        Emoji(id: "1", name: "Blush", image: UIImage(named: "blush")!),
        Emoji(id: "2", name: "Content", image: UIImage(named: "content")!),
        Emoji(id: "3", name: "Cry", image: UIImage(named: "cry")!),
        Emoji(id: "4", name: "Sob", image: UIImage(named: "sob")!),
        Emoji(id: "5", name: "Thinking", image: UIImage(named: "thinking")!),
        Emoji(id: "6", name: "Cool", image: UIImage(named: "cool")!),
        Emoji(id: "7", name: "Dog", image: UIImage(named: "dog")!),
        Emoji(id: "8", name: "Heart", image: UIImage(named: "heart")!),
        Emoji(id: "9", name: "Monkey", image: UIImage(named: "monkey")!),
        Emoji(id: "10", name: "Nerd", image: UIImage(named: "nerd")!),
        Emoji(id: "11", name: "Wink", image: UIImage(named: "wink")!),
        Emoji(id: "12", name: "Parrot", image: UIImage.gifWithName("parrot")!),
        Emoji(id: "13", name: "Fiesta Parrot", image: UIImage.gifWithName("fiestaparrot")!),
        Emoji(id: "14", name: "Conga Parrot", image: UIImage.gifWithName("congaparrot")!),
        Emoji(id: "15", name: "Parrot Cop", image: UIImage.gifWithName("parrotcop")!),
        Emoji(id: "16", name: "Sad Parrot", image: UIImage.gifWithName("sadparrot")!),
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
        let (diff, _) = emojis.deepDiff(newArray)
        emojis = newArray
        collectionView?.performBatchUpdates({ () -> Void in
            for step in diff {
                switch step {
                case .move(let i, let j):
                    self.collectionView?.moveItemAtIndexPath(NSIndexPath(forItem: i, inSection: 0), toIndexPath: NSIndexPath(forItem: j, inSection: 0))
                case .insert(let i, _):
                    self.collectionView?.insertItemsAtIndexPaths([NSIndexPath(forItem: i, inSection: 0)])
                case .delete(let i, _):
                    self.collectionView?.deleteItemsAtIndexPaths([NSIndexPath(forItem: i, inSection: 0)])
                }
            }
        }, completion: {(finished) -> Void in
                control.endRefreshing()
        })
        
    }
    
    func randomize(array: [Emoji]) -> [Emoji] {
        var array = array
        for i in 0..<array.count - 1 {
            let j = Int(arc4random_uniform(UInt32(array.count - i))) + i
            if i != j {
                swap(&array[i], &array[j])
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
        cell.imageView.image = emojis[indexPath.row].image
        return cell
    }
    
}
