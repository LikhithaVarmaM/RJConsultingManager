//
//  TaskViewModel.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/8/25.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class TaskViewModel: ObservableObject {
    @Published var tasks: [TaskModel] = []
    private let db = Firestore.firestore()

    func fetchTasks(for userId: String) {
        db.collection("tasks")
            .whereField("assignedToUserId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching tasks: \(error)")
                    return
                }
                self.tasks = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: TaskModel.self)
                } ?? []
            }
    }
}

