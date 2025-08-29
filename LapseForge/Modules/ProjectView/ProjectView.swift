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
    @Published var showPhotoPicker: Bool = false
    
    @Published var catalogSequence: LapseSequence?
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
                },
                showPhotoPicker: { [weak viewModel] in
                    runOnMainThread {
                        viewModel?.showPhotoPicker = true
                    }
                }
            )
            //
            if let currentSequence {
                ConfigurationSequenceView(
                    currentSequence: currentSequence,
                    catalogSequence: $viewModel.catalogSequence
                )
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
        .sheet(
            item: $viewModel.catalogSequence,
            content: { sequence in
                SequenceCatalog(
                    sequence: sequence,
                    onSaveSequence: saveProject
                )
            }
        )
        .sheet(isPresented: $viewModel.showPhotoPicker) {
            PHVideoPicker(
                isPresented: $viewModel.showPhotoPicker,
                onPicked: { url in
                    Task {
                        print("Vídeo URL:", url)
                        guard let generatedSequence = await generateSequence(from: url) else { return }
                        
                        await MainActor.run {
                            let sequence = LapseSequence(generatedSequence: generatedSequence)
                            onSaveSequence(sequence: sequence)
                        }
                    }
                },
                onProgress: { p in
                    // Si quieres mostrar progreso (0…1)
                    print("Progreso:", p)
                }
            )
        }
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

import AVFoundation

struct GeneratedSequence: SequenceProtocol {
    typealias CaptureType = GeneratedCapture
    let id: UUID = UUID()
    
    var captures: [GeneratedCapture] = []
}

struct GeneratedCapture: CaptureProtocol {
    let id: UUID = UUID()
    var index: Int = -1
}

func generateSequence(from url: URL) async -> GeneratedSequence? {
    let asset = AVURLAsset(url: url)
    
    // 1) Cargar duración y track
    guard let duration = try? await asset.load(.duration) else { return nil }
    guard let track = try? await asset.loadTracks(withMediaType: .video).first else { return nil }
    
    // 2) Leer fps real (puede dar 0 en vídeo VFR)
    let fpsFloat = try? await track.load(.nominalFrameRate)
    let fps = Double(max(1.0, fpsFloat ?? 0.0)) // si es 0, evitamos 0 fps
    let seconds = duration.seconds
    let totalFrames = max(1, Int(round(fps * seconds)))
    print("duration: \(seconds)s fps: \(fps) totalFrames: \(totalFrames)")
    
    // 3) Preparar generador
    let generator = AVAssetImageGenerator(asset: asset)
    generator.appliesPreferredTrackTransform = true
    // exactitud: .zero -> más lento pero más exacto; poner tolerancias si quieres más velocidad
    generator.requestedTimeToleranceBefore = .zero
    generator.requestedTimeToleranceAfter  = .zero
    // limita el tamaño si quieres (reduce uso memoria / CPU)
    // generator.maximumSize = CGSize(width: 1920, height: 1080)
    
    var result = GeneratedSequence()
    
    await withTaskGroup(of: GeneratedCapture?.self) { group in
        for i in 0..<totalFrames {
            group.addTask {
                let time = CMTime(seconds: Double(i) / fps, preferredTimescale: 600)
                do {
                    let image = try await generator.image(at: time).image
                    // Aquí guardarías la imagen o la convertirías en Data
                    let uiImage = UIImage(cgImage: image)
                    guard let data  = uiImage.jpegData(compressionQuality: 0.9) else {
                        print("Error frame \(i) al convertir a JPEG")
                        return nil
                    }
                    
                    var capture = try CustomFileManager.shared.savePhoto(data, to: result)
                    capture.index = i
                    
                    print("Generado el frame \(i)")
                    return capture
                } catch {
                    print("Error frame \(i): \(error)")
                    return nil
                }
            }
        }
        
        for await capture in group {
            if let capture {
                result.captures.append(capture)
            }
        }
    }
    
    result.captures.sort { $0.index < $1.index }
    
    return result
}

#Preview {
    NavigationStack {
        ProjectView(project: .mock)
    }
}
