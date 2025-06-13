//
//  ProjectListView.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/2/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ProjectListView: View {
    @State private var projects: [ProjectModel] = []
    @State private var showAddProject = false
    @State private var errorMessage: IdentifiableError?

    var body: some View {
        NavigationView {
            List {
                if projects.isEmpty {
                    Text("No projects found")
                        .foregroundColor(.gray)
                } else {
                    ForEach(projects) { project in
                        NavigationLink(destination: ProjectDetailView(project: project)) {
                            VStack(alignment: .leading) {
                                Text(project.name)
                                    .font(.headline)
                                Text("Deadline: \(project.deadline?.formatted(date: .abbreviated, time: .omitted) ?? "No deadline")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: deleteProjects)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Projects")
                        .font(.system(size: 24, weight: .bold))
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddProject.toggle() }) {
                        Label("Add Project", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddProject) {
                AddProjectView(onProjectAdded: {
                    showAddProject = false
                    // No manual fetch needed due to snapshot listener
                })
            }
            .onAppear {
                fetchProjects()
            }
            .alert(item: $errorMessage) { err in
                Alert(title: Text("Error"), message: Text(err.message), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func fetchProjects() {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = IdentifiableError(message: "User not authenticated.")
            return
        }

        Firestore.firestore().collection("projects")
            .whereField("consultantUserIds", arrayContains: userId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    errorMessage = IdentifiableError(message: error.localizedDescription)
                    return
                }

                self.projects = snapshot?.documents.compactMap {
                    try? $0.data(as: ProjectModel.self)
                } ?? []
            }
    }

    private func deleteProjects(at offsets: IndexSet) {
        for index in offsets {
            let project = projects[index]
            guard let projectId = project.id else { continue }

            Firestore.firestore().collection("projects").document(projectId).delete { error in
                if let error = error {
                    errorMessage = IdentifiableError(message: error.localizedDescription)
                }
            }
        }
    }
}

struct ProjectListView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectListView()
    }
}
