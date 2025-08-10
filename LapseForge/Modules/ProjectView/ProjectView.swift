//
//  ProjectView.swift
//  LapseForge
//
//  Created by Jerónimo Cabezuelo Ruiz on 6/8/25.
//

import SwiftUI

private class ProjectViewModel: ObservableObject {
    @Published var selectedSequence: LapseSequence?
    @Published var scrubber: TimeInterval?
}

struct ProjectView: View {
    @Environment(\.modelContext) private var modelContext
    var project: LapseProject
    
    @StateObject private var viewModel = ProjectViewModel()
    
    var currentSequence: LapseSequence? {
        guard let scrubber = viewModel.scrubber else {
            return nil
        }
        let sequence = project.sequence(at: scrubber)?.sequence
        return sequence
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Previsualización
            PreviewView(
                project: project,
                scrubber: $viewModel.scrubber
            )
            
            // Línea de tiempo avanzada
            TimeLineView(
                project: project,
                updateSelectedSequence: { [weak viewModel] selectedSequence in
                    runOnMainThread {
                        viewModel?.selectedSequence = selectedSequence
                    }
                },
                updateScrubber: { [weak viewModel] newScrubber in
                    runOnMainThread {
                        viewModel?.scrubber = newScrubber
                    }
                }
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
            item: $viewModel.selectedSequence,
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
