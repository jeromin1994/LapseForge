//
//  ProjectsListView.swift
//  LapseForge
//
//  Created by Jerónimo Cabezuelo Ruiz on 3/8/25.
//

import SwiftUI
import SwiftData
import DeveloperKit

struct ProjectsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [LapseProject]
    
    @ObservedObject var exporter: Exporter = .init()
    
    @ViewBuilder
    var splitView: some View {
        NavigationSplitView {
            List {
                ForEach(projects) { project in
                    NavigationLink {
                        ProjectView(project: project, exporter: exporter)
                    } label: {
                        Text("\(project.title) at \(project.createdDate, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    }
                }
                .onDelete(perform: deleteProjects)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addProject) {
                        Label("New Project", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an Project")
        }
        .onAppear(perform: {
            deleteLostSequences()
        })
    }
    
    var body: some View {
        ZStack {
            splitView
            
            if let status = exporter.status {
                Spacer()
                    .background(.background.opacity(0.5))
                VStack {
                    VStack(alignment: .leading) {
                        Text("Exportando vídeo")
                        ProgressView(value: status.exportProgress, total: 1)
                        Text("Unificando vídeo")
                        ProgressView(value: status.unifyProgress, total: 1)
                    }
                    if status.success {
                        Text("Video guardado en la galería")
                        Button("Ok") {
                            self.exporter.status = nil
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(60)
                .background(.background)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(30)
                .shadow(radius: 16)
            }
        }
    }
    
    private func addProject() {
        withAnimation {
            let newProject = LapseProject(
                createdDate: Date(),
                title: projects.nextAvailableTitle()
            )
            modelContext.insert(newProject)
            
            do {
                try modelContext.save()
            } catch {
                print(error)
            }
        }
    }
    
    private func deleteProjects(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                guard let project = projects.at(index) else { continue }
                modelContext.delete(project)
            }
            
            do {
                try modelContext.save()
            } catch {
                print(error)
            }
        }
    }
    
    private func deleteLostSequences() {
        do {
            try CustomFileManager.shared.removeUnusedPhotos(keeping: projects)
        } catch {
            print("Error borranod secuencias perdidas: \(error)")
        }
    }
}
