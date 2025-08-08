//
//  TimeInterval+Extension.swift
//  LapseForge
//
//  Created by Jerónimo Cabezuelo Ruiz on 8/8/25.
//

import Foundation

extension TimeInterval {
    var timeString: String {
        let time = Int(self)
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
