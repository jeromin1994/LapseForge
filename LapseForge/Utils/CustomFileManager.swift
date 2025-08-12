//
//  CustomFileManager.swift
//  LapseForge
//
//  Created by Jerónimo Cabezuelo Ruiz on 10/8/25.
//

import Foundation

class CustomFileManager {
    static let shared = CustomFileManager()
    
    private let fileManager = FileManager.default
    
    private init() {}
    
    func savePhoto(_ photo: Data, to sequence: LapseSequence) throws {
        guard let sequenceDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            .first?.appending(path: sequence.directoryName)
        else {
            print("No se pudo generar la URL del archivo")
            throw FileManagerError.invalidDirectory
        }
        
        try fileManager.createDirectory(at: sequenceDirectory, withIntermediateDirectories: true)
        
        let now = Date()
        
        let url = sequenceDirectory.appendingPathComponent(now.imageName)
        
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
        try photo.write(to: url)
        
        sequence.captures.append(now)
        
        print("✅ Imagen guardada en \(url)")
    }
    
    func getPhotoUrl(from sequence: LapseSequence, at index: Int) throws -> URL {
        guard let sequenceDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            .first?.appending(path: sequence.directoryName)
        else {
            print("No se pudo generar la URL del archivo")
            throw FileManagerError.invalidDirectory
        }
        
        guard let date = sequence.captures.at(index, reversed: sequence.reversed) else {
            print("No se pudo obtener la captura por el indice")
            throw FileManagerError.noPhotoAtIndex
        }
        let capturePath = sequenceDirectory.appendingPathComponent(date.imageName)
        
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
