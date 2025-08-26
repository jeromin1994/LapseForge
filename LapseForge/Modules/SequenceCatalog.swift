//
//  SequenceCatalog.swift
//  LapseForge
//
//  Created by Jerónimo Cabezuelo Ruiz on 12/8/25.
//

import SwiftUI

private struct SequenceCatalogCaptureModel {
    var selected: Bool = false
    let capture: LapseCapture
    
    init(capture: LapseCapture) {
        self.capture = capture
    }
}

struct SequenceCatalog: View {
    let sequence: LapseSequence
    var onSaveSequence: () -> Void
    
    @State private var captures: [SequenceCatalogCaptureModel] = []
    
    @Environment(\.dismiss) private var dismiss
    
    let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    private var selectedCaptures: Int {
        captures.count(where: \.selected)
    }
    
    @ViewBuilder
    private func captureView(with model: SequenceCatalogCaptureModel) -> some View {
        GeometryReader { geo in
            ZStack {
                CaptureView(
                    capture: model.capture
                )
            }
            .frame(width: geo.size.width, height: geo.size.width)
            
        }
        .background(.gray)
        .overlay {
            if model.selected {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue, lineWidth: 8)
            }
        }
        .overlay(alignment: .bottomLeading) {
            let systemName = model.selected ? "checkmark.circle.fill" : "circle"
            Image(systemName: systemName)
                .font(.title2)
                .foregroundStyle(model.selected ? .primary : .secondary)
                .background(.ultraThinMaterial)
                .clipShape(.circle)
                .shadow(radius: 3)
                .padding(8)
        }
        .cornerRadius(8)
        .aspectRatio(1, contentMode: .fit)
        .onTapGesture {
            captures[at: model.capture.index]?.selected.toggle()
        }
    }
    
    @ViewBuilder
    var selectionView: some View {
        HStack {
            Text("\(selectedCaptures) frames selecionados")
            Spacer()
            if selectedCaptures == captures.count {
                Button("Deselecionar todos") {
                    captures.indices.forEach {
                        captures[at: $0]?.selected = false
                    }
                }
            } else {
                Button("Selecionar todos") {
                    captures.indices.forEach {
                        captures[at: $0]?.selected = true
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    var deleteButton: some View {
        Button("Borrar Frames", role: .destructive) {
            withAnimation {
                for capture in captures where capture.selected {
                    sequence.removeCapture(capture.capture)
                }
                captures.removeAll(where: \.selected)
            }
        }
        .buttonStyle(.borderedProminent)
    }
    
    @ViewBuilder
    var exportButton: some View {
        Button("Exportar Frames", role: .cancel) {
            // TODO: Implementar esta funcionalidad.
        }
        .buttonStyle(.borderedProminent)
        .disabled(true)
    }
    
    @ViewBuilder
    var buttonsView: some View {
        HStack {
            deleteButton
            Spacer()
            exportButton
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(captures, id: \.capture) { capture in
                            captureView(with: capture)
                        }
                    }
                    
                }
                selectionView
                buttonsView
            }
            .padding()
            .navigationTitle("Catálogo de Frames")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        onSaveSequence()
                        dismiss()
                    }
                }
            }
            .task {
                calculeCaptures()
            }
        }
    }
    
    private func calculeCaptures() {
        captures = sequence.captures.map(SequenceCatalogCaptureModel.init)
    }
}

#Preview {
    SequenceCatalog(sequence: .mock, onSaveSequence: {})
}
