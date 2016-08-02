//
//  Emoji.swift
//  TableDiff
//
//  Created by Kent White on 7/5/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import UIKit
import TableDiff

struct Emoji: SequenceDiffable {
    let identifier: String
    let name: String
    let image: UIImage
    var color: UIColor

    var hashValue: Int {
        return identifier.hashValue
    }
}


func ==(lhs: Emoji, rhs: Emoji) -> Bool {
    return lhs.identifier == rhs.identifier && lhs.name == rhs.name && lhs.image == rhs.image && lhs.color == rhs.color
}
