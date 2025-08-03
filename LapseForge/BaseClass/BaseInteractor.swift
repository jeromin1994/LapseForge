//
//  BaseInteractor.swift
//  Bitaskora
//
//  Created by Jerónimo Cabezuelo Ruiz on 16/11/24.
//

import Foundation

protocol BaseInteractorInputProtocol: AnyObject {
    
}

protocol BaseInteractorOutputProtocol: AnyObject {
    var isLoading: Bool { get set }
}

class BaseInteractor: BaseInteractorInputProtocol {
    weak var baseViewModel: BaseInteractorOutputProtocol?
    
    private var numberOfAsyncTasks: Int = 0 {
        didSet {
            runOnMainThread {
                self.baseViewModel?.isLoading = self.numberOfAsyncTasks > 0
            }
        }
    }
}

extension BaseInteractor: ProviderDelegate {
    func asyncTaskStart() {
        numberOfAsyncTasks += 1
    }
    
    func asyncTaskFinish() {
        numberOfAsyncTasks -= 1
    }
}
