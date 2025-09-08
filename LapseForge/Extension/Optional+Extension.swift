//
//  Optional+Extension.swift
//  LapseForge
//
//  Created by Jerónimo Cabezuelo Ruiz on 8/9/25.
//

import Foundation

extension Optional {
    public var isNull: Bool {
        return self == nil
    }
    
    public var isNotNull: Bool {
        return !isNull
    }
}
