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
                ForEach(projects) { project in
                    NavigationLink(destination: ProjectDetailView(project: project)) {
                        VStack(alignment: .leading) {
                            Text(project.name)
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
        guard let userId = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore().collection("projects")
            .whereField("consultantUserIds", arrayContains: userId)
            .order(by: "deadline")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    self.errorMessage = IdentifiableError(message: error.localizedDescription)
                    return
                }

                self.projects = snapshot?.documents.compactMap {
                    try? $0.data(as: ProjectModel.self)
                } ?? []
            }
    }
}

struct MyProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        MyProjectsView()
    }
}
