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

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(projects) { project in
                    NavigationLink {
                        Text("Project at \(project.createdDate, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(project.createdDate, format: Date.FormatStyle(date: .numeric, time: .standard))
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
    }

    private func addProject() {
        withAnimation {
            let newProject = LapseProject(createdDate: Date())
            modelContext.insert(newProject)
        }
    }

    private func deleteProjects(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                guard let project = projects.at(index) else { continue }
                modelContext.delete(project)
            }
        }
    }
}

#Preview {
    ProjectsListView()
        .modelContainer(for: LapseProject.self, inMemory: true)
}
