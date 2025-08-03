//
//  BaseProvider.swift
//  Bitaskora
//
//  Created by Jerónimo Cabezuelo Ruiz on 19/11/24.
//

import Foundation

protocol ProviderDelegate: AnyObject {
    func asyncTaskStart()
    func asyncTaskFinish()
}

class BaseProvider {
    weak var delegate: ProviderDelegate?
    
    init(interactor: ProviderDelegate?) {
        self.delegate = interactor
    }
}
