//
//  TimeIntervalPicker.swift
//  LapseForge
//
//  Created by Jerónimo Cabezuelo Ruiz on 9/8/25.
//

import SwiftUI

struct TimeIntervalPicker: View {
    @Binding var timeInterval: TimeInterval
    
    var min: TimeInterval = .zero
    
    var minutesRange: Range<Int> {
        let minMinutes = Int(min) / 60
        return minMinutes..<60
    }
    
    var secondsRange: Range<Int> {
        let minMinutes = Int(min) / 60
        let minSeconds = Int(min) % 60
        
        // Si ya estamos en el minuto mínimo, entonces limitamos también los segundos
        if timeInterval.minutes == minMinutes {
            return minSeconds..<60
        } else {
            return 0..<60
        }
    }
    
    var safeMinutes: Binding<Int> {
        Binding(
            get: { timeInterval.minutes },
            set: { newMinutes in
                var clamped = TimeInterval(newMinutes * 60 + timeInterval.seconds)
                if clamped < min {
                    clamped = min
                }
                timeInterval = clamped
            }
        )
    }
    
    var safeSeconds: Binding<Int> {
        Binding(
            get: { timeInterval.seconds },
            set: { newSeconds in
                var clamped = TimeInterval(timeInterval.minutes * 60 + newSeconds)
                if clamped < min {
                    clamped = min
                }
                timeInterval = clamped
            }
        )
    }
    
    var body: some View {
        HStack(alignment: .intPickerAlignment) {
            IntPicker(title: .Common.minutes, range: minutesRange, selection: safeMinutes)
            Text(.Common.colon)
                .alignmentGuide(.intPickerAlignment) { d in
                    d[VerticalAlignment.center]
                }
            IntPicker(title: .Common.seconds, range: secondsRange, selection: safeSeconds)
        }
    }
}
