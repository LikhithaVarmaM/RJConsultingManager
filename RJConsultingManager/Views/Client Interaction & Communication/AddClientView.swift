//
//  AddClientView.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/2/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct AddClientView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var notes = ""

    @State private var isSaving = false
    @State private var alertError: IdentifiableError?

    var onClientAdded: (() -> Void)? = nil

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Client Info")) {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                    TextField("Phone Number", text: $phone)
                        .keyboardType(.phonePad)
                    TextEditor(text: $notes)
                        .frame(height: 80)
                }

                Button("Save") {
                    saveClient()
                }
                .disabled(name.isEmpty || isSaving)
            }
            .navigationTitle("New Client")
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

    private func saveClient() {
        isSaving = true

        let client = ClientModel(
            id: UUID().uuidString,
            name: name,
            email: email,
            phone: phone
        )

        do {
            try Firestore.firestore().collection("clients").document(client.id!).setData(from: client) { error in
                isSaving = false
                if let error = error {
                    alertError = IdentifiableError(message: error.localizedDescription)
                } else {
                    onClientAdded?()
                    dismiss()
                }
            }
        } catch {
            isSaving = false
            alertError = IdentifiableError(message: error.localizedDescription)
        }
    }
}

struct AddClientView_Previews: PreviewProvider {
    static var previews: some View {
        AddClientView()
    }
}
