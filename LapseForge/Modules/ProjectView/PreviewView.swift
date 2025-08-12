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
            .overlay {
                if let scrubber,
                   let (sequence, index) = project.sequenceAndIndex(at: scrubber) {
                    CaptureView(
                        sequence: sequence,
                        index: index,
                        scaleType: .fit
                    )
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
