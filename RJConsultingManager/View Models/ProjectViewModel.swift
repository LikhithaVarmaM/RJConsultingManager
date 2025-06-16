//
//  ProjectViewModel.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/2/25.
//

import Firebase

class ProjectViewModel: ObservableObject {
    @Published var projects: [ProjectModel] = []

    private let db = Firestore.firestore()

    func fetchAllProjects() {
        db.collection("projects").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching projects: \(error.localizedDescription)")
                return
            }

            self.projects = snapshot?.documents.compactMap { doc in
                try? doc.data(as: ProjectModel.self)
            } ?? [] as! [ProjectModel]
        }
    }
}
