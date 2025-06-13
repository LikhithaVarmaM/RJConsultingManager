//
//  EditProjectView.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/4/25.
//

import SwiftUI
import FirebaseFirestore

struct EditProjectView: View {
    var project: ProjectModel
    var onSaved: () -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var deadline: Date = Date()
    @State private var errorMessage: IdentifiableError?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Project Name")) {
                    TextField("Name", text: $name)
                }

                Section(header: Text("Deadline")) {
                    DatePicker("Deadline", selection: $deadline, displayedComponents: [.date])
                }

                Button("Save Changes") {
                    saveChanges()
                }
            }
            .navigationTitle("Edit Project")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                name = project.name
                deadline = project.deadline ?? Date()
            }
            .alert(item: $errorMessage) { err in
                Alert(title: Text("Error"), message: Text(err.message), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func saveChanges() {
        guard let id = project.id else { return }

        let updatedData: [String: Any] = [
            "name": name,
            "deadline": Timestamp(date: deadline)
        ]

        Firestore.firestore().collection("projects").document(id).updateData(updatedData) { error in
            if let error = error {
                errorMessage = IdentifiableError(message: error.localizedDescription)
            } else {
                onSaved()
                dismiss()
            }
        }
    }
}

struct EditProjectView_Previews: PreviewProvider {
    static var previews: some View {
        EditProjectView(
            project: ProjectModel.preview,
            onSaved: {}
        )
    }
}
