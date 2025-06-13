//
//  AddConsultantView.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/2/25.
//

import SwiftUI
import FirebaseFirestore

struct AddConsultantView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    
    var onConsultantAdded: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Consultant Details")) {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                    TextField("Phone", text: $phone)
                }

                Button("Add Consultant") {
                    addConsultant()
                }
                .disabled(name.isEmpty || email.isEmpty)
            }
            .navigationTitle("New Consultant")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func addConsultant() {
        let consultant = ConsultantModel(
            id: nil,
            name: name,
            email: email,
            phone: phone,
            skills: []
        )
        
        do {
            try Firestore.firestore()
                .collection("consultants")
                .addDocument(from: consultant) { error in
                    if let error = error {
                        print("Error adding consultant: \(error.localizedDescription)")
                    } else {
                        onConsultantAdded()
                        dismiss()
                    }
                }
        } catch {
            print("Encoding error: \(error.localizedDescription)")
        }
    }
}

struct AddConsultantView_Previews: PreviewProvider {
    static var previews: some View {
        AddConsultantView(onConsultantAdded: {})
    }
}
