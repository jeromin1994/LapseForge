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
    
    var totalDuration: TimeInterval {
        sequences.compactMap(\.expectedDuration).reduce(0, +)
    }
    
    func captureData(at time: TimeInterval) -> Data? {
        var accumulatedTime: TimeInterval = 0
        
        for sequence in sequences {
            guard let duration = sequence.expectedDuration else { continue }
            
            let sequenceEndTime = accumulatedTime + duration
            if time >= accumulatedTime && time <= sequenceEndTime {
                // Estamos dentro de esta secuencia
                let relativeTime = time - accumulatedTime
                // Calcular índice aproximado en base al número de capturas y duración
                if duration > 0, !sequence.captures.isEmpty {
                    let secondsPerFrame = duration / Double(sequence.captures.count)
                    let index = Int(relativeTime / secondsPerFrame)
                    let safeIndex = max(0, min(index, sequence.captures.count - 1))
                    return sequence.captureData(at: safeIndex)
                }
            }
            accumulatedTime += duration
        }
        
        return nil
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
    
    func captureData(at index: Int) -> Data? {
        do {
            return try FileManager.default.getPhoto(from: self, at: index)
        } catch {
            print("No se pudo obtener la captura \(error.localizedDescription)")
            return nil
        }
    }
    
    init(captures: [Date] = [], expectedDuration: TimeInterval? = nil) {
        self.id = UUID()
        self.captures = captures
        self.expectedDuration = expectedDuration
    }
}
