//
//  CustomAlert.swift
//  Bitaskora
//
//  Created by Jerónimo Cabezuelo Ruiz on 10/11/24.
//

import SwiftUI

public struct AlertButton: Identifiable {
    public let id = UUID()
    let title: LocalizedStringResource
    var role: ButtonRole?
    var action: (() -> Void)?
    
    public init(title: LocalizedStringResource, role: ButtonRole? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.role = role
        self.action = action
    }
    
    public static func accept(action: (() -> Void)? = nil) -> Self {
        .init(title: .Common.accept, action: action)
    }
    
    public static func cancel(action: (() -> Void)? = nil) -> Self {
        .init(title: .Common.cancel, role: .cancel, action: action)
    }
    
    public static func delete(action: (() -> Void)? = nil) -> Self {
        .init(title: .Common.delete, role: .destructive, action: action)
    }
}

public struct AlertModel {
    let title: LocalizedStringResource
    let message: LocalizedStringResource
    var buttons: [AlertButton] = [.accept()]
    
    public init(
        title: LocalizedStringResource,
        message: LocalizedStringResource,
        buttons: [AlertButton] = [.accept()]
    ) {
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
            ForEach(model.buttons) { button in
                Button(button.title, role: button.role) {
                    button.action?()
                }
            }
        } message: { model in
            Text(model.message)
        }
    }
}
