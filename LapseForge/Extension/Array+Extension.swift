//
//  Array+Extension.swift
//  LapseForge
//
//  Created by Jerónimo Cabezuelo Ruiz on 9/8/25.
//

extension Array {
    subscript(at index: Int, reversed reversed: Bool = false) -> Element? {
        get {
            guard index >= startIndex, index < endIndex else { return nil }
            let idx = reversed ? count - index - 1 : index
            return self[idx]
        }
        set {
            guard index >= startIndex, index < endIndex else { return }
            let idx = reversed ? count - index - 1 : index
            if let newValue = newValue {
                self[idx] = newValue
            }
        }
    }
}
