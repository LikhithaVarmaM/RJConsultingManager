//
//  TaskListView.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/2/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

struct TaskListView: View {
    var project: ProjectModel

    @State private var tasks: [TaskModel] = []
    @State private var showAddTask = false
    @State private var alertError: IdentifiableError?

    var body: some View {
        NavigationView {
            List {
                if tasks.isEmpty {
                    Text("No tasks yet")
                        .foregroundColor(.gray)
                } else {
                    ForEach(tasks) { task in
                        VStack(alignment: .leading) {
                            Text(task.title)
                                .font(.headline)
                            if let dueDate = task.dueDate {
                                Text("Due: \(dueDate.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.subheadline)
                            }
                            Text("Status: \(task.status)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle(project.name)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddTask.toggle() }) {
                        Label("Add Task", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddTask) {
                AddTaskView(projectId: project.id ?? "", projectClientId: project.clientId) {
                    showAddTask = false
                    fetchTasks()
                }
            }
            .onAppear {
                fetchTasks()
            }
            .alert(item: $alertError) { err in
                Alert(title: Text("Error"), message: Text(err.message), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func fetchTasks() {
        let db = Firestore.firestore()
        db.collection("tasks")
            .whereField("projectId", isEqualTo: project.id ?? "")
            .order(by: "dueDate", descending: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    alertError = IdentifiableError(message: error.localizedDescription)
                    return
                }
                if let documents = snapshot?.documents {
                    tasks = documents.compactMap { try? $0.data(as: TaskModel.self) }
                }
            }
    }
}

struct TaskListView_Previews: PreviewProvider {
    static var previews: some View {
        TaskListView(project: ProjectModel.preview)
    }
}
