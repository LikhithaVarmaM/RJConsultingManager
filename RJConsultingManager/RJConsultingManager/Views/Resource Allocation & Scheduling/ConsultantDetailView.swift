//
//  ConsultantDetailView.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/12/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ConsultantDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State var consultant: ConsultantModel
    @State private var name: String
    @State private var email: String
    @State private var phone: String
    @State private var skillsText: String

    @State private var showDeleteAlert = false
    @State private var alertError: IdentifiableError?

    init(consultant: ConsultantModel) {
        self._consultant = State(initialValue: consultant)
        self._name = State(initialValue: consultant.name)
        self._email = State(initialValue: consultant.email)
        self._phone = State(initialValue: consultant.phone ?? "")
        self._skillsText = State(initialValue: consultant.skills?.joined(separator: ", ") ?? "")
    }

    var body: some View {
        Form {
            Section(header: Text("Consultant Info")) {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
                TextField("Phone", text: $phone)
                TextField("Skills (comma-separated)", text: $skillsText)
            }

            Section {
                Button("Save Changes") {
                    updateConsultant()
                }

                Button("Delete Consultant", role: .destructive) {
                    showDeleteAlert = true
                }
            }
        }
        .navigationTitle("Edit Consultant")
        .alert("Confirm Deletion", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteConsultant()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this consultant?")
        }
        .alert(item: $alertError) { err in
            Alert(title: Text("Error"), message: Text(err.message), dismissButton: .default(Text("OK")))
        }
    }

    private func updateConsultant() {
        let updatedConsultant = ConsultantModel(
            id: consultant.id,
            name: name,
            email: email,
            phone: phone.isEmpty ? nil : phone,
            skills: skillsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        )

        guard let id = updatedConsultant.id else {
            alertError = IdentifiableError(message: "Invalid consultant ID.")
            return
        }

        do {
            try Firestore.firestore()
                .collection("consultants")
                .document(id)
                .setData(from: updatedConsultant) { error in
                    if let error = error {
                        alertError = IdentifiableError(message: error.localizedDescription)
                    } else {
                        dismiss()
                    }
                }
        } catch {
            alertError = IdentifiableError(message: error.localizedDescription)
        }
    }

    private func deleteConsultant() {
        guard let id = consultant.id else {
            alertError = IdentifiableError(message: "Invalid consultant ID.")
            return
        }

        Firestore.firestore().collection("consultants").document(id).delete { error in
            if let error = error {
                alertError = IdentifiableError(message: error.localizedDescription)
            } else {
                dismiss()
            }
        }
    }
}

struct ConsultantDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ConsultantDetailView(consultant: ConsultantModel.preview)
        }
    }
}
