//
//  BaseViewModel.swift
//  Bitaskora
//
//  Created by Jerónimo Cabezuelo Ruiz on 2/11/24.
//

import SwiftUI

class BaseViewModel: ObservableObject, Identifiable {
    var baseInteractor: BaseInteractorInputProtocol?
    
    @Published var isLoading: Bool = false
    
    func didAssembly() {
//        print("\(Self.self) \(#function)")
    }
    
    func onAppear() {
//        print("\(Self.self) \(#function)")
    }
    
    init() {
        // No NotificationManager in this proyect yet
//        NotificationManager.shared.addDelegate(self)
    }
    
    deinit {
        // No NotificationManager in this proyect yet
//        NotificationManager.shared.removeDelegate(self)
    }
}

extension BaseViewModel: BaseInteractorOutputProtocol {

}

// No NotificationManager in this proyect yet
// extension BaseViewModel: NotificationManagerDelegate {
//    @objc
//    func didRequestDataRefresh() {
//        // MUSt OVERRIDE
//    }
//}
