//
//  ProjectView.swift
//  LapseForge
//
//  Created by Jerónimo Cabezuelo Ruiz on 6/8/25.
//

import SwiftUI

struct ProjectView: View {
    @Environment(\.modelContext) private var modelContext
    var project: LapseProject
    
    @State private var selectedSequence: LapseSequence?
    @State private var scrubber: TimeInterval?
    
    var currentSequence: LapseSequence? {
        guard let scrubber else { return nil }
        let sequence = project.sequence(at: scrubber)?.sequence
        return sequence
    }
    
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
            
            //
            if let currentSequence {
                ConfigurationSequenceView(currentSequence: currentSequence)
            }
        }
        .navigationTitle(project.title)
        .toolbar(content: {
            ToolbarItem {
                Button {
                    saveProject()
                } label: {
                    Text("Guardar")
                }
            }
        })
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
        saveProject()
    }
    
    private func saveProject() {
        do {
            try modelContext.save()
        } catch {
            print("No se pudo guardar el context: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        ProjectView(project: .mock)
    }
}
