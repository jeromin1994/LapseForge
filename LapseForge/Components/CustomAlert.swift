//
//  CustomAlert.swift
//  Bitaskora
//
//  Created by Jerónimo Cabezuelo Ruiz on 10/11/24.
//

import SwiftUI

public struct AlertButton {
    let title: String
    var role: ButtonRole?
    var action: (() -> Void)?
    
    public init(title: String, role: ButtonRole? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.role = role
        self.action = action
    }
    
    public static func accept(action: (() -> Void)? = nil) -> Self {
        .init(title: "Aceptar", action: action)
    }
    
    public static func cancel(action: (() -> Void)? = nil) -> Self {
        .init(title: "Cancelar", role: .cancel, action: action)
    }
    
    public static func delete(action: (() -> Void)? = nil) -> Self {
        .init(title: "Borrar", role: .destructive, action: action)
    }
}

public struct AlertModel {
    let title: String
    let message: String
    var buttons: [AlertButton] = [.accept()]
    
    public init(title: String, message: String, buttons: [AlertButton] = [.accept()]) {
        self.title = title
        self.message = message
        self.buttons = buttons
    }
}

extension View {
    public func alert(model: Binding<AlertModel?>) -> some View {
        self.alert(
            model.wrappedValue?.title ?? "",
            isPresented: Binding(
                get: { model.wrappedValue != nil },
                set: { if !$0 { model.wrappedValue = nil } }
            ),
            presenting: model.wrappedValue
        ) { model in
            ForEach(model.buttons, id: \.title) { button in
                Button(button.title, role: button.role) {
                    button.action?()
                }
            }
        } message: { model in
            Text(model.message)
        }
    }
}
