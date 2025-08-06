//
//  ProjectView.swift
//  LapseForge
//
//  Created by Jerónimo Cabezuelo Ruiz on 6/8/25.
//

import SwiftUI

struct ProjectView: View {
    let project: LapseProject
    
    var body: some View {
        Text("\(project.title) at \(project.createdDate, format: Date.FormatStyle(date: .numeric, time: .standard))")
    }
}
