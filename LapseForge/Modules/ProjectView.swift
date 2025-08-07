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
    
    var body: some View {
        VStack(spacing: 16) {
            // Previsualización
            Color.gray
                .frame(height: 200)
                .overlay(
                    Text("Preview")
                        .foregroundColor(.white)
                        .bold()
                )
            
            // Línea de tiempo
            ScrollView(.horizontal) {
                HStack {
                    ForEach(project.sequences) { sequence in
                        Text("Sequence \(sequence.captures.count) frames")
                    }
                }
            }
            
            Text("Timeline")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
            
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
        .padding()
        .navigationTitle(project.title)
        .sheet(
            item: $currentSequence,
            content: { sequence in
                CaptureSequenceView(
                    sequence: sequence,
                    onSaveSequence: { sequence in
                        if !project.sequences.contains(sequence) {
                            project.sequences.append(sequence)
                        }
                        do {
                            try modelContext.save()
                        } catch {
                            print("No se pudo guardar el context: \(error)")
                        }
                    }
                )
            }
        )
    }
}
