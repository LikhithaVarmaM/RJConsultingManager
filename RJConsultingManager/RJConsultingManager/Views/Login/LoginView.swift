//
//  LoginView.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/6/25.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                if !authViewModel.error.isEmpty {
                    Text(authViewModel.error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                Button("Login") {
                    authViewModel.login(email: email, password: password)
                }
                .padding(.top)

                NavigationLink(destination: SignupView()) {
                    Text("Don't have an account? Register")
                        .foregroundColor(.blue)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Login")
        }
        .fullScreenCover(isPresented: $authViewModel.isAuthenticated) {
            if authViewModel.role == "admin" {
                AdminMainTabView()
            } else {
                ConsultantMainTabView()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}
