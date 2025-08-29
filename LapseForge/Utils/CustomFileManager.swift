//
//  CustomFileManager.swift
//  LapseForge
//
//  Created by Jerónimo Cabezuelo Ruiz on 10/8/25.
//

import Foundation

protocol SequenceProtocol: Identifiable<UUID> {
    associatedtype CaptureType: CaptureProtocol
}

protocol CaptureProtocol: Identifiable<UUID> {
    init()
}

class CustomFileManager {
    static let shared = CustomFileManager()
    
    private let fileManager = FileManager.default
    
    private init() {}
    
    func savePhoto<S: SequenceProtocol>(_ photo: Data, to sequence: S) throws -> S.CaptureType {
        guard let sequenceDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            .first?.appending(path: sequence.directoryName)
        else {
            print("No se pudo generar la URL del archivo")
            throw FileManagerError.invalidDirectory
        }
        
        try fileManager.createDirectory(at: sequenceDirectory, withIntermediateDirectories: true)
        
        let capture = S.CaptureType()
        
        let url = sequenceDirectory.appendingPathComponent(capture.frameName)
        
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
        try photo.write(to: url)
        
        return capture
    }
    
    func getPhotoUrl(from sequence: LapseSequence, at index: Int) throws -> URL {
        guard let sequenceDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            .first?.appending(path: sequence.directoryName)
        else {
            print("No se pudo generar la URL del archivo")
            throw FileManagerError.invalidDirectory
        }
        
        guard let capture = sequence.capture(at: index) else {
            print("No se pudo obtener la captura por el indice")
            throw FileManagerError.noPhotoAtIndex
        }
        let capturePath = sequenceDirectory.appendingPathComponent(capture.frameName)
        
        return capturePath
    }
    
    func getPhoto(from sequence: LapseSequence, at index: Int) throws -> Data {
        let capturePath = try getPhotoUrl(from: sequence, at: index)
        
        return try Data(contentsOf: capturePath)
    }
}

enum FileManagerError: Error {
    case invalidDirectory
    case noPhotoAtIndex
}
