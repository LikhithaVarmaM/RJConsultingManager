//
//  AuthViewModel.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/6/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var error = ""
    @Published var role = ""
    @Published var userId = ""

    private var db = Firestore.firestore()

    init() {
        // Observe auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            if let user = user {
                self.userId = user.uid
                self.fetchUserRole(uid: user.uid)
            } else {
                self.isAuthenticated = false
                self.userId = ""
                self.role = ""
            }
        }
    }

    func login(email: String, password: String) {
        error = ""
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, err in
            guard let self = self else { return }
            if let err = err {
                self.error = err.localizedDescription
            } else if let user = result?.user {
                self.userId = user.uid
                self.fetchUserRole(uid: user.uid)
            }
        }
    }

    func signUp(name: String, email: String, password: String, role: String) {
        error = ""
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, err in
            guard let self = self else { return }
            if let err = err {
                self.error = err.localizedDescription
            } else if let user = result?.user {
                let userData: [String: Any] = [
                    "email": email,
                    "name": name,
                    "role": role
                ]
                self.userId = user.uid
                self.db.collection("users").document(user.uid).setData(userData) { error in
                    if let error = error {
                        self.error = error.localizedDescription
                    } else {
                        self.role = role
                        self.isAuthenticated = true
                    }
                }
            }
        }
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            self.isAuthenticated = false
            self.userId = ""
            self.role = ""
        } catch {
            self.error = "Failed to log out: \(error.localizedDescription)"
        }
    }

    private func fetchUserRole(uid: String) {
        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            if let data = snapshot?.data(), let userRole = data["role"] as? String {
                self.role = userRole
                self.isAuthenticated = true
            } else {
                self.error = "Role not found"
            }
        }
    }
}
