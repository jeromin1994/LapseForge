//
//  BaseView.swift
//  Bitaskora
//
//  Created by Jerónimo Cabezuelo Ruiz on 2/11/24.
//

import SwiftUI

protocol BaseView: View {
    associatedtype ViewModel: BaseViewModel
    associatedtype BodyContent: View
    var viewModel: ViewModel { get }
    var bodyContent: BodyContent { get }
    
    init(viewModel: ViewModel)
}

extension BaseView {
    var body: some View {
        bodyContent
            .withLoader(isLoading: viewModel.isLoading)
            .onAppear(perform: viewModel.onAppear)
    }
}

extension View {
    /// Agrega un loader superpuesto si `isLoading` es verdadero.
    func withLoader(isLoading: Bool) -> some View {
        ZStack {
            self // Representa la vista base
            
            if isLoading {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
    }
}
