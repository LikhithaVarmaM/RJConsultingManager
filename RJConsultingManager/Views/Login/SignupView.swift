//
//  SignupView.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/6/25.
//

import SwiftUI

struct SignupView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var selectedRole = "consultant"

    let roles = ["admin", "consultant"]

    var body: some View {
        VStack(spacing: 20) {
            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Email", text: $email)
                .autocapitalization(.none)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Picker("Role", selection: $selectedRole) {
                ForEach(roles, id: \.self) {
                    Text($0.capitalized)
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            if !authViewModel.error.isEmpty {
                Text(authViewModel.error)
                    .foregroundColor(.red)
            }

            Button("Sign Up") {
                authViewModel.signUp(name: name, email: email, password: password, role: selectedRole)
            }
        }
        .padding()
        .navigationTitle("Sign Up")
    }
}


struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}
