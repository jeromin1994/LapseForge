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
                        ProjectView(project: project)
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
}
