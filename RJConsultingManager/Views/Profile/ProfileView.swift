//
//  ProfileView.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/2/25.
//

// ProfileView.swift

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var name = ""
    @State private var role = ""
    @State private var email = ""
    @State private var isEditing = false
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)

            if isEditing {
                TextField("Name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Role", text: $role)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Save Changes") {
                    saveProfile()
                }
                .buttonStyle(.borderedProminent)
            } else {
                Text(name).font(.title).bold()
                Text(role.capitalized).foregroundColor(.gray)
                Text(email).foregroundColor(.gray).font(.caption)
            }

            Spacer()

            if !isEditing {
                Button("Edit Profile") {
                    isEditing = true
                }

                Button("Logout", role: .destructive) {
                    logout()
                }

                Button("Delete Account", role: .destructive) {
                    showDeleteConfirmation = true
                }
            }
        }
        .padding()
        .navigationTitle("Profile")
        .onAppear(perform: loadProfile)

        // Success Alert
        .alert("Changes Saved", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) {
                isEditing = false
            }
        } message: {
            Text("Your profile was updated successfully.")
        }

        // Error Alert
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }

        // Delete Confirmation
        .alert("Delete Account?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete your account.")
        }
    }

    private func loadProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                self.name = data["name"] as? String ?? "Unknown"
                self.role = data["role"] as? String ?? "User"
                self.email = data["email"] as? String ?? ""
            }
        }
    }

    private func saveProfile() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(uid).updateData([
            "name": name,
            "role": role
        ]) { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.showErrorAlert = true
            } else {
                self.showSuccessAlert = true
            }
        }
    }

    private func logout() {
        do {
            try Auth.auth().signOut()
            authViewModel.isAuthenticated = false
            authViewModel.userId = ""
            authViewModel.role = ""
        } catch {
            self.errorMessage = "Failed to log out: \(error.localizedDescription)"
            self.showErrorAlert = true
        }
    }

    private func deleteAccount() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()

        // Delete user document
        db.collection("users").document(user.uid).delete { error in
            if let error = error {
                self.errorMessage = "Failed to delete data: \(error.localizedDescription)"
                self.showErrorAlert = true
                return
            }

            // Delete authentication
            user.delete { error in
                if let error = error {
                    self.errorMessage = "Failed to delete account: \(error.localizedDescription)"
                    self.showErrorAlert = true
                } else {
                    authViewModel.isAuthenticated = false
                    authViewModel.userId = ""
                    authViewModel.role = ""
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
