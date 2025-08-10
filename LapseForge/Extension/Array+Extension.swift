//
//  Array+Extension.swift
//  LapseForge
//
//  Created by Jerónimo Cabezuelo Ruiz on 9/8/25.
//

extension Array {
    func at(_ index: Int, reversed: Bool = false) -> Element? {
        guard index >= startIndex,
              index < endIndex
        else { return nil }
        
        let index = reversed ? count - index - 1 : index
        
        return self[index]
    }
}
