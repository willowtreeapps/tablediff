//
//  EmojiCell.swift
//  TableDiff
//
//  Created by Kent White on 7/5/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit

class EmojiCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!

    func setup(emoji: Emoji) {
        backgroundColor = emoji.color
        imageView.image = emoji.image
    }

    func update(emoji: Emoji) {
        UIView.animateWithDuration(0.5) { [weak self] in
            self?.backgroundColor = emoji.color
        }
    }
}
