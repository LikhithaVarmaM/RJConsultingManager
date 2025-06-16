//
//  AddProjectView.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/2/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift

struct AddProjectView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var deadline = Date()
    @State private var selectedClientId: String?
    @State private var selectedConsultantId: String?
    @State private var errorMessage: IdentifiableError?

    @State private var clients: [ClientModel] = []
    @State private var consultants: [ConsultantModel] = []

    var onProjectAdded: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Project Info")) {
                    TextField("Project Name", text: $name)
                    DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                }

                Section(header: Text("Assign Client")) {
                    Picker("Client", selection: $selectedClientId) {
                        Text("Select a client").tag(String?.none)
                        ForEach(clients) { client in
                            Text(client.name).tag(Optional(client.id))
                        }
                    }
                }

                Section(header: Text("Assign Consultant")) {
                    Picker("Consultant", selection: $selectedConsultantId) {
                        Text("Select a consultant").tag(String?.none)
                        ForEach(consultants) { consultant in
                            Text(consultant.name).tag(Optional(consultant.id))
                        }
                    }
                }

                Button("Save Project") {
                    saveProject()
                }
                .disabled(name.isEmpty || selectedClientId == nil || selectedConsultantId == nil)
            }
            .navigationTitle("New Project")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                fetchClients()
                fetchConsultants()
            }
            .alert(item: $errorMessage) { error in
                Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func fetchClients() {
        Firestore.firestore().collection("clients").getDocuments { snapshot, error in
            if let error = error {
                errorMessage = IdentifiableError(message: "Failed to fetch clients: \(error.localizedDescription)")
                return
            }
            clients = snapshot?.documents.compactMap {
                try? $0.data(as: ClientModel.self)
            } ?? []
        }
    }

    private func fetchConsultants() {
        Firestore.firestore().collection("consultants").getDocuments { snapshot, error in
            if let error = error {
                errorMessage = IdentifiableError(message: "Failed to fetch consultants: \(error.localizedDescription)")
                return
            }
            consultants = snapshot?.documents.compactMap {
                try? $0.data(as: ConsultantModel.self)
            } ?? []
        }
    }

    private func saveProject() {
        guard let clientId = selectedClientId,
              let selectedConsultantId = selectedConsultantId else {
            errorMessage = IdentifiableError(message: "Please select client and consultant.")
            return
        }

        guard let currentUserId = Auth.auth().currentUser?.uid else {
            errorMessage = IdentifiableError(message: "User not authenticated.")
            return
        }

        // ✅ Include both selected consultant and current user
        let consultantIds = Array(Set([selectedConsultantId, currentUserId]))

        let project = ProjectModel(
            id: UUID().uuidString,
            name: name,
            description: nil,
            deadline: deadline,
            clientId: clientId,
            documents: [],
            consultantUserIds: consultantIds
        )

        do {
            try Firestore.firestore()
                .collection("projects")
                .document(project.id!)
                .setData(from: project) { error in
                    if let error = error {
                        errorMessage = IdentifiableError(message: "Error saving project: \(error.localizedDescription)")
                    } else {
                        print("✅ Project added with consultants: \(consultantIds)")
                        onProjectAdded()
                        dismiss()
                    }
                }

        } catch {
            errorMessage = IdentifiableError(message: "Encoding error: \(error.localizedDescription)")
        }
    }
}

struct AddProjectView_Previews: PreviewProvider {
    static var previews: some View {
        AddProjectView(onProjectAdded: { })
    }
}
