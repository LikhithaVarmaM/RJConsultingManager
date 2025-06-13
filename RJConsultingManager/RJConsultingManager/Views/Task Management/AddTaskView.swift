//
//  AddTaskView.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/2/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

struct AddTaskView: View {
    var projectId: String
    var projectClientId: String
    var onTaskAdded: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var dueDate = Date()
    @State private var status = "Pending"
    @State private var isSaving = false
    @State private var alertError: IdentifiableError?
    
    // Optional: If you want to assign task to someone
    @State private var assignedToUserId: String = Auth.auth().currentUser?.uid ?? ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title", text: $title)
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    Picker("Status", selection: $status) {
                        Text("Pending").tag("Pending")
                        Text("Completed").tag("Completed")
                    }
                }

                Button("Save Task") {
                    saveTask()
                }
                .disabled(title.isEmpty || isSaving)
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert(item: $alertError) { err in
                Alert(title: Text("Error"), message: Text(err.message), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func saveTask() {
        isSaving = true
        let newTask = TaskModel(
            id: UUID().uuidString,
            title: title,
            dueDate: dueDate,
            status: status,
            projectId: projectId,
            clientId: projectClientId,
            assignedToUserId: assignedToUserId
        )

        do {
            try Firestore.firestore().collection("tasks").document(newTask.id!).setData(from: newTask) { error in
                isSaving = false
                if let error = error {
                    alertError = IdentifiableError(message: error.localizedDescription)
                } else {
                    onTaskAdded()
                    dismiss()
                }
            }
        } catch {
            isSaving = false
            alertError = IdentifiableError(message: error.localizedDescription)
        }
    }
}

// MARK: - Preview
struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView(
            projectId: "project123",
            projectClientId: "client456"
        ) {
            print("Task added")
        }
    }
}
