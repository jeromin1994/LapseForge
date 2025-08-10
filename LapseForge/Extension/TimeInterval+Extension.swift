//
//  TimeInterval+Extension.swift
//  LapseForge
//
//  Created by Jerónimo Cabezuelo Ruiz on 8/8/25.
//

import Foundation

extension TimeInterval {
    var timeString: String {
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var seconds: Int {
        get {
            Int(self) % 60
        }
        set {
            self = TimeInterval(minutes * 60 + newValue)
        }
    }
    
    var minutes: Int {
        get {
            Int(self) / 60
        }
        set {
            self = TimeInterval(newValue * 60 + seconds)
        }
    }
}
