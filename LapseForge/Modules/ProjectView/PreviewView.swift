//
//  PreviewView.swift
//  LapseForge
//
//  Created by Jerónimo Cabezuelo Ruiz on 9/8/25.
//

import SwiftUI

struct PreviewView: View {
    var project: LapseProject
    @Binding var scrubber: TimeInterval?
    
    var body: some View {
        Color.gray
            .frame(height: 200)
            .overlay {
                if let scrubber,
                   let data = project.captureData(at: scrubber),
                   let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                } else {
                    Text("Preview")
                        .foregroundColor(.white)
                        .bold()
                }
            }
            .overlay(alignment: .bottomLeading) {
                Text("\((scrubber ?? .zero).timeString) - \(project.totalDuration.timeString)")
            }
    }
}
