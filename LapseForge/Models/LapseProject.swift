//
//  LapseProject.swift
//  LapseForge
//
//  Created by Jerónimo Cabezuelo Ruiz on 3/8/25.
//

import Foundation
import SwiftData
import UIKit

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
    
    var totalDuration: TimeInterval {
        sequences.compactMap(\.expectedDuration).reduce(0, +)
    }
    
    func sequence(at time: TimeInterval) -> (sequence: LapseSequence, relativeTime: TimeInterval)? {
        var accumulatedTime: TimeInterval = 0
        for sequence in sequences {
            let duration = sequence.expectedDuration
            let sequenceEndTime = accumulatedTime + duration
            if time >= accumulatedTime && time <= sequenceEndTime {
                let relativeTime = time - accumulatedTime
                return (sequence, relativeTime)
            }
            accumulatedTime += duration
        }
        return nil
    }
    
    func captureData(at time: TimeInterval) -> Data? {
        guard let (sequence, relativeTime) = sequence(at: time) else {
            return nil
        }
        let duration = sequence.expectedDuration
        guard duration > 0,
              !sequence.captures.isEmpty else {
            return nil
        }
        
        let secondsPerFrame = duration / Double(sequence.captures.count)
        let index = Int(relativeTime / secondsPerFrame)
        let safeIndex = max(0, min(index, sequence.captures.count - 1))
        return sequence.captureData(at: safeIndex)
    }
}

extension LapseProject {
    static var mock: Self {
        .init(createdDate: .now, title: "Mock", sequences: [.mock])
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
    var title: String?
    var captures: [Date]
    var expectedDuration: TimeInterval = 10
    var reversed: Bool = false
    
    init(captures: [Date] = [], expectedDuration: TimeInterval = 10) {
        self.id = UUID()
        self.captures = captures
        self.expectedDuration = expectedDuration
    }
    
    var directoryName: String {
        "sequence_\(id.uuidString)/"
    }
    
    func captureData(at index: Int) -> Data? {
        do {
            return try CustomFileManager.shared.getPhoto(from: self, at: index)
        } catch {
            print("No se pudo obtener la captura \(error.localizedDescription)")
            return nil
        }
    }
    
    func rotate() {
        // TODO: Pensar cómo hacerlo para que sea eficiente
    }
    
}

extension LapseSequence {
    static var mock: Self {
        .init(
            captures: (0..<100).map({ i in Date.now.addingTimeInterval(TimeInterval(i))}),
            expectedDuration: 30
        )
    }
}
