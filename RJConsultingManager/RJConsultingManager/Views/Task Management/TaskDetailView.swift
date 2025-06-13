//
//  TaskDetailView.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/5/25.
//

import SwiftUI
import FirebaseFirestore

struct TaskDetailView: View {
    @Environment(\.dismiss) private var dismiss

    @State var task: TaskModel
    let taskId: String // Firestore Document ID

    @State private var showDeleteConfirmation = false
    @State private var errorMessage = ""

    var body: some View {
        Form {
            Section(header: Text("Task Info")) {
                TextField("Title", text: $task.title)

                DatePicker("Due Date", selection: Binding(
                    get: { task.dueDate ?? Date() },
                    set: { task.dueDate = $0 }
                ), displayedComponents: .date)

                TextField("Status", text: $task.status)
            }

            Section {
                Button("Save Changes") {
                    updateTaskInFirestore()
                }

                Button("Delete Task", role: .destructive) {
                    showDeleteConfirmation = true
                }
            }

            if !errorMessage.isEmpty {
                Section {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Task Details")
        .confirmationDialog("Are you sure you want to delete this task?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                deleteTaskFromFirestore()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func updateTaskInFirestore() {
        let db = Firestore.firestore()
        db.collection("tasks").document(taskId).updateData([
            "title": task.title,
            "dueDate": Timestamp(date: task.dueDate ?? Date()),
            "status": task.status,
            "assignedToUserId": task.assignedToUserId,
            "clientId": task.clientId,
            "projectId": task.projectId
        ]) { error in
            if let error = error {
                errorMessage = "Error updating task: \(error.localizedDescription)"
            } else {
                dismiss()
            }
        }
    }

    private func deleteTaskFromFirestore() {
        let db = Firestore.firestore()
        db.collection("tasks").document(taskId).delete { error in
            if let error = error {
                errorMessage = "Error deleting task: \(error.localizedDescription)"
            } else {
                dismiss()
            }
        }
    }
}

struct TaskDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TaskDetailView(task: TaskModel.preview, taskId: "")
    }
}
