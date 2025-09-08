//
//  TimeLineView.swift
//  LapseForge
//
//  Created by Jerónimo Cabezuelo Ruiz on 8/8/25.
//

import SwiftUI
import DeveloperKit // TODO: Para las alertas. Cuando hagamos publico el repo, habrá que quitar DeveloperKit y por tanto mover esas implementaciones a este proyecto.

struct TimeLineView: View {
    @State private var scrollContentHeight: CGFloat = 0
    @State private var alertModel: AlertModel?
    let project: LapseProject
    var updateSelectedSequence: (LapseSequence) -> Void
    var updateScrubber: (TimeInterval) -> Void
    var showPhotoPicker: () -> Void
    
    let scrollCoordinateSpace: NamedCoordinateSpace = .named("Scroll")
    let imageWidth = 20
    
    private var pixelsPerSecond: CGFloat {
        UIScreen.main.bounds.width / 45
    }
    
    @ViewBuilder
    var timeMarkers: some View {
        let markerInterval: TimeInterval = 15.0
        let totalDuration = project.totalDuration
        let horizontalInset: CGFloat = UIScreen.main.bounds.width/2
        HStack(alignment: .center, spacing: 0) {
            Spacer().frame(width: horizontalInset, height: 10)
            ForEach(0..<Int(totalDuration / markerInterval) + 1, id: \.self) { index in
                let label = (TimeInterval(index) * markerInterval).timeString
                Text(label)
                    .font(.caption2)
                    .frame(width: CGFloat(markerInterval) * pixelsPerSecond, alignment: .leading)
            }
        }
    }
    
    func capturesView(for sequence: LapseSequence, count: Int, step: Int) -> some View {
        HStack(spacing: .zero) {
            ForEach(
                Array(sequence.captures)
                    .filter { $0.index % step == 0 }
                    .prefix(count)
            ) { capture in
                CaptureView(
                    capture: capture,
                    scaleType: .fill
                )
                .frame(width: CGFloat(imageWidth), height: 40)
            }
        }
    }
    
    @ViewBuilder
    var sequencesViews: some View {
        let horizontalInset: CGFloat = UIScreen.main.bounds.width/2
        HStack(alignment: .top, spacing: 0) {
            Spacer().frame(width: horizontalInset, height: 10)
            ForEach(project.sequences) { sequence in
                let duration = sequence.expectedDuration
                let width = max(CGFloat(duration) * pixelsPerSecond, 1)
                let padding: CGFloat = 2
                let count = Int(ceil(width / CGFloat(imageWidth)))
                let step = max(1, sequence.count / count)
                
                VStack(alignment: .leading, spacing: 4) {
                    capturesView(for: sequence, count: count, step: step)
                        .frame(width: max(width - padding, .zero), alignment: .leading)
                        .clipped()
                    
                    HStack {
                        Text("\(Int(duration))s")
                            .font(.caption)
                        Spacer(minLength: .zero)
                        Text("\(sequence.count) frames")
                            .font(.caption)
                    }
                }
                .frame(width: max(width - padding, .zero))
                .background(Color.secondary)
                .cornerRadius(4)
                .onTapGesture {
                    updateSelectedSequence(sequence)
                }
                
                Spacer().frame(width: padding)
            }
            Spacer().frame(width: horizontalInset, height: 10)
        }
    }
    
    @ViewBuilder
    var backgroundReader: some View {
        GeometryReader { innerGeo in
            Color.clear
                .onAppear {
                    updateSelectedSecond(withOffset: innerGeo.frame(in: scrollCoordinateSpace).minX)
                    scrollContentHeight = innerGeo.size.height
                }
                .onChange(of: innerGeo.size.height) { _, newHeight in
                    scrollContentHeight = newHeight
                }
                .onChange(of: innerGeo.frame(in: scrollCoordinateSpace).minX) { _, newOffset in
                    updateSelectedSecond(withOffset: newOffset)
                }
        }
    }
    
    @ViewBuilder
    var scrubberLine: some View {
        HStack {
            Spacer()
            Rectangle()
                .fill(Color.red)
                .frame(width: 2, height: scrollContentHeight + 4)
            Spacer()
        }
    }
    
    @ViewBuilder
    var addSequenceButton: some View {
        Button(
            action: {
                let cameraButton = AlertButton(
                    title: "Cámara",
                    action: {
                        updateSelectedSequence(.init())
                    }
                )
                
                let galeryButton = AlertButton(
                    title: "Galería",
                    action: showPhotoPicker
                )
                alertModel = .init(
                    title: "Nueva sequencia",
                    message: "¿Cómo la quieres crear?",
                    buttons: [
                        cameraButton,
                        galeryButton,
                        .cancel()
                    ]
                )
            },
            label: {
                Image(systemName: "plus.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(height: max(scrollContentHeight - 32, 20))
            }
        )
        .padding(.horizontal)
        .background(
            .ultraThinMaterial
        )
        .clipShape(.circle)
        .shadow(
            color: .black.opacity(0.8),
            radius: 2,
            x: 1,
            y: 1
        )
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 4) {
                // Marcas de tiempo
                timeMarkers
                
                // Secuencias
                sequencesViews
            }
            .background {
                backgroundReader
            }
        }
        .coordinateSpace(scrollCoordinateSpace)
        .overlay {
            scrubberLine
        }
        .overlay(alignment: .trailing) {
            addSequenceButton
        }
        .alert(model: $alertModel)
    }
    
    private func updateSelectedSecond(withOffset offset: CGFloat) {
        let newScrubber = max(min(-offset / pixelsPerSecond, project.totalDuration), .zero)
        updateScrubber(newScrubber)
    }
}
