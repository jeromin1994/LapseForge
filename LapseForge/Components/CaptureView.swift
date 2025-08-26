//
//  CaptureView.swift
//  LapseForge
//
//  Created by Jerónimo Cabezuelo Ruiz on 12/8/25.
//

import SwiftUI

struct CaptureView: View {
    let capture: LapseCapture
    var scaleType: ScaleType = .fit
    
    @State private var imageData: Data?
    
    var body: some View {
        HStack {
            if let imageData,
               let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaleTo(scaleType)
            } else {
                Image(systemName: "photo")
            }
        }
        .task(id: capture.id.uuidString + "-\(capture.index)" + "-\(capture.sequence?.rotation.rawValue ?? -1)") {
            // TODO: Esto no temina de ser eficiente cuando la imágen está rotada.
            let data = /*await*/ capture.captureData
            await MainActor.run {
                self.imageData = data
            }
        }
    }
    enum ScaleType {
        case fit
        case fill
    }
}

private struct ScaleTo: ViewModifier {
    var type: CaptureView.ScaleType
    
    func body(content: Content) -> some View {
        switch type {
        case .fit:
            content.scaledToFit()
        case .fill:
            content.scaledToFill()
        }
    }
}

private extension View {
    func scaleTo(_ type: CaptureView.ScaleType) -> some View {
        self.modifier(ScaleTo(type: type))
    }
}
