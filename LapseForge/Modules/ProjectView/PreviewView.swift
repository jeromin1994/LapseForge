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
    
    @State private var isPlaying = false
    @State private var playbackTask: Task<Void, Never>?
    
    var body: some View {
        Color.gray
            .overlay {
                if let scrubber,
                   let (sequence, index) = project.sequenceAndIndex(at: scrubber),
                   let capture = sequence.capture(at: index) {
                    CaptureView(
                        capture: capture,
                        scaleType: .fit
                    )
                } else {
                    Text("Preview")
                        .foregroundColor(.white)
                        .bold()
                }
            }
            .overlay(alignment: .bottom) {
                HStack {
                    HStack {
                        Button(
                            action: {
                                togglePlayback()
                            },
                            label: {
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .shadow(
                                        color: .black.opacity(0.8),
                                        radius: 2,
                                        x: 1,
                                        y: 1
                                    )
                            }
                        )
                        Spacer(minLength: .zero)
                    }
                    Text("\((scrubber ?? .zero).timeString) - \(project.totalDuration.timeString)")
                        .shadow(
                            color: .white.opacity(0.8),
                            radius: 2,
                            x: 1,
                            y: 1
                        )
                    
                    HStack {
                        Spacer(minLength: .zero)
                        Text("")
                    }
                }
                .padding()
            }
    }
    
    private func togglePlayback() {
        if isPlaying {
            stopPlayback()
        } else {
            startPlayback()
        }
    }
    
    private func startPlayback() {
        isPlaying = true
        playbackTask = Task {
            let start = scrubber ?? .zero
            let startTime = Date()
            while !Task.isCancelled {
                let elapsed = Date().timeIntervalSince(startTime)
                let newValue = start + elapsed
                if newValue >= project.totalDuration {
                    DispatchQueue.main.async {
                        scrubber = project.totalDuration
                    }
                    stopPlayback()
                    break
                } else {
                    DispatchQueue.main.async {
                        scrubber = newValue
                    }
                }
                try? await Task.sleep(for: .milliseconds(33))
            }
        }
    }
    
    private func stopPlayback() {
        playbackTask?.cancel()
        playbackTask = nil
        isPlaying = false
    }
}
