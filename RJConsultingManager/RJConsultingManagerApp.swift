//
//  RJConsultingManagerApp.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/2/25.
//

import SwiftUI
import Firebase

@main
struct RJConsultingManagerApp: App {
    
    @StateObject private var authViewModel = AuthViewModel()
    
    init() {
            FirebaseApp.configure()
        }
    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
                LoginView()
                    .environmentObject(authViewModel)
        }
    }
}
