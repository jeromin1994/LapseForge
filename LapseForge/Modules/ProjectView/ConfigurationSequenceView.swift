//
//  ConfigurationSequenceView.swift
//  LapseForge
//
//  Created by Jerónimo Cabezuelo Ruiz on 10/8/25.
//
import SwiftUI

struct ConfigurationSequenceView: View {
    var currentSequence: LapseSequence
    
    @ViewBuilder
    var nameAndDate: some View {
        HStack {
            TextField(
                "Secuencia sín nombre",
                text: Binding(
                    get: { currentSequence.title ?? "" },
                    set: { newValue in
                        currentSequence.title = newValue
                    }
                )
            )
            if let firstCapture = currentSequence.captures.first {
                Text(firstCapture, format: Date.FormatStyle(date: .long, time: .standard))
                    .font(.footnote)
            }
        }
    }
    
    @ViewBuilder
    var durationView: some View {
        VStack {
            Text("Duración secuencia ")
            TimeIntervalPicker(
                timeInterval: .init(
                    get: {
                        currentSequence.expectedDuration
                    },
                    set: { new in
                        currentSequence.expectedDuration = new
                    }
                )
            )
        }
    }
    
    @ViewBuilder
    var reversedButton: some View {
        CustomButton(
            action: {
                currentSequence.reversed.toggle()
            },
            systemImageName: "clock.arrow.circlepath",
            title: currentSequence.reversed ? "En reversa" : "Normal"
        )
    }
    
    @ViewBuilder
    var rotateButton: some View {
        CustomButton(
            action: {
                currentSequence.rotate()
            },
            systemImageName: "rotate.left",
            // TODO: Cambiar este texto
            title: "Catálogo de Frames"
        )
    }
    
    @ViewBuilder
    var catalogButton: some View {
        CustomButton(
            action: {
                
            },
            systemImageName: "photo.stack",
            title: "Catálogo de Frames"
        )
    }
    
    var body: some View {
        VStack {
            nameAndDate
            HStack(alignment: .top) {
                durationView
                VStack {
                    reversedButton
                    rotateButton
                    catalogButton
                }
            }
        }
        .padding()
    }
}

private struct CustomButton: View {
    var action: () -> Void
    var systemImageName: String
    var title: String
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImageName)
                Text(title)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical)
        .background(.ultraThickMaterial)
        .clipShape(.buttonBorder)
    }
}

#Preview {
    ConfigurationSequenceView(currentSequence: .mock)
}
