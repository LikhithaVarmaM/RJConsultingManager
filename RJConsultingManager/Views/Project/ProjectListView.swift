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
                            VStack(alignment: .leading, spacing: 4) {
                                Text(project.name.isEmpty ? "Untitled Project" : project.name)
                                    .font(.headline)
                                Text("Deadline: \(project.deadline?.formatted(date: .abbreviated, time: .omitted) ?? "No deadline")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .onDelete(perform: deleteProjects)
                }
            }
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddProject.toggle() }) {
                        Label("Add Project", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddProject) {
                AddProjectView(onProjectAdded: {
                    showAddProject = false
                    fetchProjects() // ✅ Force refresh after add
                })
            }
            .onAppear {
                print("✅ ProjectListView appeared")
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
            print("❌ No user ID found")
            return
        }

        print("✅ Fetching projects for user ID: \(userId)")

        Firestore.firestore().collection("projects")
            .whereField("consultantUserIds", arrayContains: userId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    errorMessage = IdentifiableError(message: error.localizedDescription)
                    print("❌ Firestore fetch error: \(error.localizedDescription)")
                    return
                }

                let docs = snapshot?.documents ?? []
                print("📄 Found \(docs.count) projects")

                self.projects = docs.compactMap {
                    try? $0.data(as: ProjectModel.self)
                }
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
