//
//  BaseAssemblyDTO.swift
//  Bitaskora
//
//  Created by Jerónimo Cabezuelo Ruiz on 1/12/24.
//

class BaseAssemblyDTO: Identifiable, Hashable {
    static func == (lhs: BaseAssemblyDTO, rhs: BaseAssemblyDTO) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
