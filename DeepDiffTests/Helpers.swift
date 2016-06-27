//
//  Helpers.swift
//  DeepDiff
//
//  Created by Ian Terrell on 6/27/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation
import DeepDiff

extension Int: SequenceDiffable {
    public func identifiedSame(other: Int) -> Bool {
        return self == other
    }
}

func randomArray(minSize: Int = 0, maxSize: Int = 100, minValue: Int = 0, maxValue: Int = 1000) -> [Int] {
    let count = UInt32(minSize) + arc4random_uniform(UInt32(maxSize-minSize))
    return (0..<count).map { _ in minValue + Int(arc4random_uniform(UInt32(maxValue - minValue))) }
}