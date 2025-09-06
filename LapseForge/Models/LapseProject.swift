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
    
    func sequenceAndIndex(at time: TimeInterval) -> (sequence: LapseSequence, index: Int)? {
        guard let (sequence, relativeTime) = sequence(at: time) else {
            return nil
        }
        let duration = sequence.expectedDuration
        guard duration > 0,
              !sequence.isEmpty else {
            return nil
        }
        
        let secondsPerFrame = duration / Double(sequence.count)
        let index = Int(relativeTime / secondsPerFrame)
        let safeIndex = max(0, min(index, sequence.count - 1))
        
        return (sequence, safeIndex)
    }
    
    func captureUrl(at time: TimeInterval) -> URL? {
        guard let (sequence, safeIndex) = sequenceAndIndex(at: time) else {
            return nil
        }
        return sequence.captureUrl(at: safeIndex)
    }
    
    func captureData(at time: TimeInterval) -> Data? {
        guard let (sequence, safeIndex) = sequenceAndIndex(at: time) else {
            return nil
        }
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
final class LapseSequence: SequenceProtocol {
    typealias CaptureType = LapseCapture
    
    private(set) var id: UUID
    var title: String?
    @Relationship(deleteRule: .cascade)
    var internalCaptures: [LapseCapture]
    var expectedDuration: TimeInterval = 10
    var reversed: Bool = false
    private var rotationRawValue: Int?
    
    // MARK: - Cache en memoria
    @Transient
    private var shouldRebuildCache: Bool = true
    @Transient
    private var capturesCache: [LapseCapture] = []
    @Transient
    private var capturesByIndex: [Int: LapseCapture] = [:]
    
    var rotation: Rotation {
        get {
            Rotation(rawValue: rotationRawValue ?? .zero) ?? .none
        }
        set {
            rotationRawValue = newValue.rawValue
        }
    }
    
    var count: Int { internalCaptures.count }
    var isEmpty: Bool { internalCaptures.isEmpty }
    var captures: [LapseCapture] {
        if shouldRebuildCache {
            rebuildCache()
        }
        return capturesCache
    }
    
    init(id: UUID = UUID(), captures: [LapseCapture] = [], expectedDuration: TimeInterval = 10) {
        self.id = id
        self.internalCaptures = captures
        self.expectedDuration = expectedDuration
        
        rebuildCache()
    }
    
    convenience init(generatedSequence: GeneratedSequence) {
        self.init(id: generatedSequence.id)
        
        for generatedCapture in generatedSequence.captures {
            let capture = LapseCapture(generatedCapture: generatedCapture)
            self.addCapture(capture)
        }
    }
    
    private func rebuildCache() {
        capturesCache = internalCaptures.sorted { $0.index < $1.index }
        capturesByIndex = Dictionary(uniqueKeysWithValues: capturesCache.map { ($0.index, $0) })
        shouldRebuildCache = false
    }
    
    func capture(at index: Int) -> LapseCapture? {
        if shouldRebuildCache {
            rebuildCache()
        }
        
        let targetIndex = reversed ? (count - 1 - index) : index
        return capturesByIndex[targetIndex]
    }
    
    func addCapture(_ capture: LapseCapture) {
        capture.index = internalCaptures.count
        internalCaptures.append(capture)
        shouldRebuildCache = true
    }
    
    func removeCapture(_ capture: LapseCapture) {
        guard let removedIndex = internalCaptures.firstIndex(where: { $0.id == capture.id }) else { return }
        removeCapture(at: removedIndex)
    }
    
    func removeCapture(at index: Int) {
        let removedCapture = internalCaptures.remove(at: index)
        
        // Reindexar solo los que están después del eliminado
        for cap in internalCaptures where cap.index > removedCapture.index {
            cap.index -= 1
        }
        
        shouldRebuildCache = true
    }
    
    func captureUrl(at index: Int) -> URL? {
        do {
            let url = try CustomFileManager.shared.getPhotoUrl(from: self, at: index)
            return url
        } catch {
            print("No se pudo obtener la captura \(error.localizedDescription)")
            return nil
        }
    }
    
    func captureData(at index: Int) -> Data? {
        do {
            let data = try CustomFileManager.shared.getPhoto(from: self, at: index)
            return applyRotation(to: data)
        } catch {
            print("No se pudo obtener la captura \(error.localizedDescription)")
            return nil
        }
    }
    
    private func applyRotation(to data: Data) -> Data? {
        guard rotation != .none else { return data }
        guard let image = UIImage(data: data) else { return data }
        
        let radians = CGFloat(rotation.rawValue) * .pi / 180
        let rotatedSize: CGSize
        switch rotation {
        case .none, .clockwise180: rotatedSize = image.size
            
        case .clockwise90, .counterClockwise90: rotatedSize = CGSize(width: image.size.height, height: image.size.width)
        }
        
        UIGraphicsBeginImageContext(rotatedSize)
        guard let context = UIGraphicsGetCurrentContext() else { return data }
        
        // Mover el origen al centro y rotar
        context.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        context.rotate(by: radians)
        image.draw(in: CGRect(x: -image.size.width / 2,
                              y: -image.size.height / 2,
                              width: image.size.width,
                              height: image.size.height))
        
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return rotatedImage?.jpegData(compressionQuality: 1.0)
    }
    
    func rotate() {
        rotation = rotation.next
    }
    
    enum Rotation: Int {
        case none = 0
        case clockwise90 = 90
        case clockwise180 = 180
        case counterClockwise90 = 270
        
        var next: Rotation {
            switch self {
            case .none: .clockwise90
            case .clockwise90: .clockwise180
            case .clockwise180: .counterClockwise90
            case .counterClockwise90: .none
            }
        }
        
        var title: String {
            switch self {
            case .none: "No rotación"
            case .clockwise90: "Rotado 90º"
            case .clockwise180: "Rotado 180º"
            case .counterClockwise90: "Rotado 270º"
            }
        }
    }
    
}

@Model
final class LapseCapture: CaptureProtocol {
    
    private(set) var id: UUID
    private(set) var date: Date
    @Relationship(inverse: \LapseSequence.internalCaptures)
    var sequence: LapseSequence?
    
    var index: Int
    
    required init() {
        self.id = UUID()
        self.date = Date()
        self.index = -1
    }
    
    init(id: UUID = UUID(), date: Date = Date(), index: Int? = nil) {
        self.id = id
        self.date = date
        self.index = index ?? -1
    }
    
    convenience init(generatedCapture: GeneratedCapture) {
        self.init(id: generatedCapture.id)
    }
    
    var captureData: Data? {
        sequence?.captureData(at: index)
    }
}

extension Identifiable where ID == UUID {
    var frameName: String {
        let filename = "frame_\(id.uuidString).jpg"
        return filename
    }
    
    var directoryName: String {
        "sequence_\(id.uuidString)"
    }
}

extension LapseSequence {
    static var mock: Self {
        .init(
            captures: (0..<100).map({ i in LapseCapture(index: i) }),
            expectedDuration: 30
        )
    }
}
