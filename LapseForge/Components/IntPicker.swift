//
//  IntPicker.swift
//  LapseForge
//
//  Created by Jerónimo Cabezuelo Ruiz on 9/8/25.
//

import SwiftUI

struct IntPicker: View {
    var title: LocalizedStringResource?
    
    var range: Range<Int> = 0..<60
    @Binding var selection: Int
    
    var body: some View {
        VStack {
            Picker("", selection: $selection) {
                ForEach(range, id: \.self) { int in
                    Text(int.description)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80, height: 150)
            .alignmentGuide(.intPickerAlignment) { d in
                d[VerticalAlignment.center]
            }
            if let title = title {
                Text(title)
                    .fixedSize()
            }
        }
    }
}

extension VerticalAlignment {
    struct IntPickerAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[VerticalAlignment.top]
        }
    }
    
    static let intPickerAlignment = VerticalAlignment(IntPickerAlignment.self)
}
