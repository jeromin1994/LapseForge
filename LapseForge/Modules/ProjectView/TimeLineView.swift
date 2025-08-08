//
//  TimeLineView.swift
//  LapseForge
//
//  Created by Jerónimo Cabezuelo Ruiz on 8/8/25.
//

import SwiftUI

struct TimeLineView: View {
    @State private var scrollContentHeight: CGFloat = 0
    let project: LapseProject
    @Binding var currentSequence: LapseSequence?
    @Binding var scrubber: TimeInterval?
    
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
                Array(sequence.captures.enumerated())
                    .filter { $0.offset % step == 0 }
                    .prefix(count),
                id: \.offset
            ) { index in
                Text("\(index.offset)")
                    .font(.footnote)
                    .frame(width: CGFloat(imageWidth), height: 40)
                    .background(Color.gray)
            }
            
        }
    }
    
    @ViewBuilder
    var sequencesViews: some View {
        let horizontalInset: CGFloat = UIScreen.main.bounds.width/2
        HStack(alignment: .bottom, spacing: 0) {
            Spacer().frame(width: horizontalInset, height: 10)
            ForEach(project.sequences) { sequence in
                let duration = sequence.expectedDuration ?? 1
                let width = CGFloat(duration) * pixelsPerSecond
                let count = Int(ceil(width / CGFloat(imageWidth)))
                let step = max(1, sequence.captures.count / count)
                
                VStack(alignment: .leading, spacing: 4) {
                    capturesView(for: sequence, count: count, step: step)
                        .frame(width: width, alignment: .leading)
                        .clipped()
                    
                    Text("\(Int(duration))s")
                        .font(.caption)
                }
                .frame(width: width)
                .background(Color.secondary)
                .cornerRadius(4)
                .onTapGesture {
                    currentSequence = sequence
                }
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
    
    var body: some View {
        ZStack {
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 8) {
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
            
            scrubberLine
            
        }
        .onChange(of: scrubber) { _, newSecond in
            guard let newSecond else { return }
            print("Instante en el centro: \(newSecond) segundos")
        }
    }
    
    private func updateSelectedSecond(withOffset offset: CGFloat) {
        scrubber = max(min(-offset / pixelsPerSecond, project.totalDuration), .zero)
    }
}
