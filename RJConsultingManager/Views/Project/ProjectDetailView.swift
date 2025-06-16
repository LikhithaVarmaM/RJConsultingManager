//
//  ProjectDetailView.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/4/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ProjectDetailView: View {
    let project: ProjectModel

    @State private var client: ClientModel?
    @State private var consultants: [ConsultantModel] = []
    @State private var tasks: [TaskModel] = []
    @State private var documents: [DocumentModel] = []

    @State private var showEditView = false
    @State private var showAddTaskView = false

    var body: some View {
        VStack {
            Form {
                // Project Info Section
                Section(header: Text("Project Info")) {
                    Text(project.name)
                        .font(.title3)
                        .bold()

                    Text("Deadline: \(project.deadline?.formatted(date: .abbreviated, time: .omitted) ?? "No deadline")")
                        .foregroundColor(.secondary)

                    HStack {
                        Text("Client:")
                        Spacer()
                        Text(client?.name ?? "None")
                            .foregroundColor(.secondary)
                    }
                }

                // Consultants Section
                Section(header: HStack {
                    Text("Consultants")
                    Spacer()
                    NavigationLink("Edit") {
                        ProjectConsultantsView(projectId: project.id ?? "", currentConsultants: project.consultantUserIds)
                    }
                }) {
                    if consultants.isEmpty {
                        Text("No consultants assigned")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(consultants.prefix(2)) {
                            Text($0.name)
                        }
                    }
                }

                // Tasks Section
                Section(header: HStack {
                    Text("Tasks")
                    Spacer()
                    NavigationLink("See All") {
                        ProjectTasksView(project: project)
                    }
                }) {
                    if tasks.isEmpty {
                        Text("No tasks yet")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(tasks.prefix(2)) { task in
                            VStack(alignment: .leading) {
                                Text(task.title)
                                    .font(.subheadline)
                                Text("Due: \(task.dueDate?.formatted(date: .abbreviated, time: .omitted) ?? "No date")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                // Documents Section
                Section(header: HStack {
                    Text("Documents")
                    Spacer()
                    NavigationLink("Manage") {
                        ProjectDocumentsView(project: project)
                    }
                }) {
                    if documents.isEmpty {
                        Text("No documents")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(documents.prefix(2)) { doc in
                            Text(doc.name)
                        }
                    }
                }
            }
        }
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showEditView = true
                }
            }
        }
        .sheet(isPresented: $showEditView) {
            EditProjectView(project: project) {
                showEditView = false
                fetchClient()
                fetchConsultants()
            }
        }
        .sheet(isPresented: $showAddTaskView) {
            AddTaskView(
                projectId: project.id ?? "",
                projectClientId: project.clientId
            ) {
                showAddTaskView = false
                fetchTasks()
            }
        }
        .onAppear {
            fetchClient()
            fetchConsultants()
            fetchTasks()
            fetchDocuments()
        }
    }

    // MARK: - Firestore Fetch Methods

    private func fetchClient() {
        Firestore.firestore().collection("clients").document(project.clientId)
            .getDocument { snapshot, _ in
                if let doc = try? snapshot?.data(as: ClientModel.self) {
                    self.client = doc
                }
            }
    }

    private func fetchConsultants() {
        let ids = project.consultantUserIds
        guard !ids.isEmpty else { return }

        Firestore.firestore().collection("consultants")
            .whereField(FieldPath.documentID(), in: ids)
            .getDocuments { snapshot, _ in
                self.consultants = snapshot?.documents.compactMap {
                    try? $0.data(as: ConsultantModel.self)
                } ?? []
            }
    }

    private func fetchTasks() {
        guard let projectId = project.id else { return }

        Firestore.firestore().collection("tasks")
            .whereField("projectId", isEqualTo: projectId)
            .order(by: "dueDate")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Error fetching tasks: \(error.localizedDescription)")
                    return
                }

                self.tasks = snapshot?.documents.compactMap {
                    try? $0.data(as: TaskModel.self)
                } ?? []
            }
    }

    private func fetchDocuments() {
        guard let projectId = project.id else { return }

        Firestore.firestore().collection("documents")
            .whereField("projectId", isEqualTo: projectId)
            .order(by: "createdAt")
            .getDocuments { snapshot, _ in
                self.documents = snapshot?.documents.compactMap {
                    try? $0.data(as: DocumentModel.self)
                } ?? []
            }
    }
}

// MARK: - Preview

struct ProjectDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProjectDetailView(project: ProjectModel(
                id: "abc123",
                name: "Sample Firebase Project",
                deadline: Date(),
                clientId: "client1",
                documents: [],
                consultantUserIds: ["user123"]
            ))
        }
    }
}
