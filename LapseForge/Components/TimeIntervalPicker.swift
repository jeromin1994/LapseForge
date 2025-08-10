//
//  TimeIntervalPicker.swift
//  LapseForge
//
//  Created by Jerónimo Cabezuelo Ruiz on 9/8/25.
//

import SwiftUI

// TODO: Si se selecciona 0 segundos, 0 minutos se produce un chrash
struct TimeIntervalPicker: View {
    @Binding var timeInterval: TimeInterval
    
    var body: some View {
        HStack(alignment: .intPickerAlignment) {
            IntPicker(title: "Minutos", selection: $timeInterval.minutes)
            Text(":")
                .alignmentGuide(.intPickerAlignment) { d in
                    d[VerticalAlignment.center]
                }
            IntPicker(title: "Segundos", selection: $timeInterval.seconds)
        }
    }
}
