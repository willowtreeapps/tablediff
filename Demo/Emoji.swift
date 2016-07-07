//
//  Emoji.swift
//  DeepDiff
//
//  Created by Kent White on 7/5/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit
import DeepDiff

struct Emoji: SequenceDiffable {
    var id: String
    var name: String
    var image: UIImage
    var identifier: String { return id }
}


func ==(lhs: Emoji, rhs: Emoji) -> Bool {
    return lhs.id == rhs.id && lhs.name == rhs.name && lhs.image == rhs.image
}