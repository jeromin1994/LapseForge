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
    
    init(createdDate: Date) {
        self.createdDate = createdDate
    }
}
