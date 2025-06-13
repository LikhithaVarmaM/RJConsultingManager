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
    @State private var name = ""
    @State private var role = ""
    @State private var email = ""

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)

            Text(name)
                .font(.title)
                .bold()

            Text(role.capitalized)
                .foregroundColor(.gray)

            Text(email)
                .foregroundColor(.gray)
                .font(.caption)

            Spacer()
        }
        .padding()
        .navigationTitle("Profile")
        .onAppear(perform: loadProfile)
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
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
