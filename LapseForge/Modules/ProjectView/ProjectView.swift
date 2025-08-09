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
    
    @State private var selectedSequence: LapseSequence?
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
                selectedSequence: $selectedSequence,
                scrubber: $scrubber
            )
            
            // Botonera de control
            HStack {
                
                
                Spacer()
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationTitle(project.title)
        .sheet(
            item: $selectedSequence,
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

