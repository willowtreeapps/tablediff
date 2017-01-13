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

    func setup(_ emoji: Emoji) {
        backgroundColor = emoji.color
        imageView.image = emoji.image
    }

    func update(_ emoji: Emoji) {
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.backgroundColor = emoji.color
        }) 
    }
}
