//
//  MyProjectsView.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/8/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

struct MyProjectsView: View {
    @State private var projects: [ProjectModel] = []
    @State private var showAddProjectSheet = false
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
                                Text(project.name.isEmpty ? "Untitled Project" : project.name)
                                    .font(.headline)

                                if let deadline = project.deadline {
                                    Text("Deadline: \(deadline.formatted(date: .abbreviated, time: .omitted))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("No deadline")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
            }
            .navigationTitle("My Projects")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddProjectSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddProjectSheet) {
                AddProjectView(onProjectAdded: {
                    showAddProjectSheet = false
                    fetchProjects()
                })
            }
            .onAppear {
                fetchProjects()
            }
            .alert(item: $errorMessage) { error in
                Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func fetchProjects() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ User not authenticated")
            return
        }

        print("🔎 Fetching projects for user ID: \(userId)")

        Firestore.firestore().collection("projects")
            .whereField("consultantUserIds", arrayContains: userId)
            .order(by: "deadline")
            // 🔁 Temporarily remove the ordering to avoid filtering out any documents
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    self.errorMessage = IdentifiableError(message: error.localizedDescription)
                    return
                }

                let documents = snapshot?.documents ?? []
                print("📦 Snapshot contains \(documents.count) documents")

                var loadedProjects: [ProjectModel] = []

                for doc in documents {
                    print("📄 Raw document data: \(doc.data())")
                    do {
                        let project = try doc.data(as: ProjectModel.self)
                        print("✅ Decoded project: \(project.name)")
                        loadedProjects.append(project)
                    } catch {
                        print("❌ Failed to decode document: \(error.localizedDescription)")
                    }
                }

                self.projects = loadedProjects
                print("✅ Final project count assigned: \(self.projects.count)")
            }
    }
}

struct MyProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        MyProjectsView()
    }
}
