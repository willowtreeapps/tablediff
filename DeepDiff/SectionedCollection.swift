//
//  SectionedCollection.swift
//  DeepDiff
//
//  Created by Ian Terrell on 6/27/16.
//  Copyright © 2016 WillowTree. All rights reserved.
//

import Foundation

//protocol SequenceDiffableSection {
//    associatedtype Identifier: SequenceDiffable
//    associatedtype Element: SequenceDiffable
//
//    var identifier: Identifier { get }
//    var elements: [Element] { get }
//}
//
//struct SectionedCollection<S: SequenceDiffableSection where S.Identifier.Index == Int, S..Index == NSIndexPath>: SequenceType {
//    var sections: [S]
//
//    func generate() -> SectionedCollectionGenerator<S> {
//        return SectionedCollectionGenerator<S>(sections: sections)
//    }
//}
//
//struct SectionedCollectionGenerator<Section: SequenceDiffableSection>: GeneratorType {
//    let sections: [Section]
//
//    init(sections: [Section]) {
//        self.sections = sections
//    }
//
//    func next() -> SectionedCollectionElement<Section.Identifier, Section.Element>? {
//        // IMPLEMENT ME!
//        return .section(sections.first!.identifier)
//    }
//}
//
//enum SectionedCollectionElement<SectionIdentifier, Element where SectionIdentifier: SequenceDiffable, Element: SequenceDiffable> {
//    case section(SectionIdentifier)
//    case element(Element)
//}