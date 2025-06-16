//
//  ProjectTasksView.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/4/25.
//

import SwiftUI
import FirebaseFirestore

struct ProjectTasksView: View {
    @ObservedObject var viewModel: ProjectTasksViewModel
    @State private var showAddTask = false
    var project: ProjectModel

    init(project: ProjectModel) {
        self.project = project
        self.viewModel = ProjectTasksViewModel(projectId: project.id ?? "")
    }

    var body: some View {
        List {
            ForEach(viewModel.tasks) { task in
                NavigationLink(destination: TaskDetailView(task: task, taskId: task.id ?? UUID().uuidString)) {
                    VStack(alignment: .leading) {
                        Text(task.title)
                            .font(.headline)
                        Text("Due: \(task.dueDate?.formatted(date: .abbreviated, time: .omitted) ?? "\(Date())")")
                            .font(.subheadline)
                        Text("Status: \(task.status.capitalized)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .onDelete(perform: deleteTasks)
        }
        .navigationTitle(project.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddTask = true
                } label: {
                    Label("Add Task", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddTask) {
            AddTaskView(
                projectId: project.id ?? "",
                projectClientId: project.clientId,
                onTaskAdded: {
                    showAddTask = false
                    viewModel.fetchTasks()
                }
            )
        }
    }

    private func deleteTasks(at offsets: IndexSet) {
        offsets.forEach { index in
            let task = viewModel.tasks[index]
            viewModel.deleteTask(task)
        }
    }
}

struct ProjectTasksView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleProject = ProjectModel(
            id: "project1",
            name: "Sample Project",
            description: "A test project",
            clientId: ClientModel.preview.id ?? "client123",
            consultantUserIds: [""] // fallback if nil
        )
        ProjectTasksView(project: sampleProject)
    }
}

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class ProjectTasksViewModel: ObservableObject {
    @Published var tasks: [TaskModel] = []
    private var db = Firestore.firestore()
    private var projectId: String

    init(projectId: String) {
        self.projectId = projectId
        fetchTasks()
    }

    func fetchTasks() {
        db.collection("tasks")
            .whereField("projectId", isEqualTo: projectId)
            .order(by: "dueDate", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching tasks: \(error)")
                    return
                }
                self?.tasks = snapshot?.documents.compactMap {
                    try? $0.data(as: TaskModel.self)
                } ?? []
            }
    }

    func deleteTask(_ task: TaskModel) {
        guard let id = task.id else { return }
        db.collection("tasks").document(id).delete { error in
            if let error = error {
                print("Error deleting task: \(error)")
            }
        }
    }
}
