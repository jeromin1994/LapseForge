//
//  ProjectView.swift
//  LapseForge
//
//  Created by Jerónimo Cabezuelo Ruiz on 6/8/25.
//

import SwiftUI

struct ProjectView: View {
    @Environment(\.modelContext) private var modelContext
    let project: LapseProject
    
    @State private var currentSequence: LapseSequence?
    @State private var scrubber: TimeInterval?
    
    var body: some View {
        VStack(spacing: 16) {
            // Previsualización
            PreviewView(
                project: project,
                scrubber: $scrubber
            )
                
            // Línea de tiempo avanzada
            TimeLineView(
                project: project,
                currentSequence: $currentSequence,
                scrubber: $scrubber
            )
            
            // Botonera de control
            HStack {
                Button(
                    action: {
                        currentSequence = .init(expectedDuration: 10)
                    }, label: {
                        Image(systemName: "record.circle")
                            .font(.title)
                    }
                )
                
                Spacer()
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationTitle(project.title)
        .sheet(
            item: $currentSequence,
            content: { sequence in
                CaptureSequenceView(
                    sequence: sequence,
                    onSaveSequence: onSaveSequence
                )
            }
        )
    }
    
    private func onSaveSequence(sequence: LapseSequence) {
        if !project.sequences.contains(sequence) {
            project.sequences.append(sequence)
        }
        do {
            try modelContext.save()
        } catch {
            print("No se pudo guardar el context: \(error)")
        }
    }
}

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
