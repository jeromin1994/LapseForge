//
//  LapseProject.swift
//  LapseForge
//
//  Created by Jerónimo Cabezuelo Ruiz on 3/8/25.
//

import Foundation
import SwiftData

@Model
final class LapseProject {
    var createdDate: Date
    var title: String
    @Relationship(deleteRule: .cascade)
    var sequences: [LapseSequence]
    
    init(createdDate: Date, title: String, sequences: [LapseSequence] = []) {
        self.createdDate = createdDate
        self.title = title
        self.sequences = sequences
    }
}

extension Array where Element == LapseProject {
    func nextAvailableTitle(index: Int? = nil) -> String {
        let baseName = "MyProject"
        
        let titles = Set(self.map(\.title))
        
        if let index = index {
            let indexTitle = "\(baseName) \(index)"
            if titles.contains(indexTitle) {
                return nextAvailableTitle(index: index + 1)
            } else {
                return indexTitle
            }
        } else {
            if titles.contains(baseName) {
                return nextAvailableTitle(index: 1)
            } else {
                return baseName
            }
        }
    }
}

@Model
final class LapseSequence {
    var id: UUID
    var captures: [Date]
    var expectedDuration: TimeInterval?
    
    var directoryName: String {
        "sequence_\(id.uuidString)/"
    }
    
    init(captures: [Date] = [], expectedDuration: TimeInterval? = nil) {
        self.id = UUID()
        self.captures = captures
        self.expectedDuration = expectedDuration
    }
}
