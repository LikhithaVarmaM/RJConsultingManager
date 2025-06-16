//
//  TaskModel.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/8/25.
//

import Foundation
import FirebaseFirestoreSwift

struct TaskModel: Identifiable, Codable {
    @DocumentID var id: String?              // Firestore document ID
    var title: String
    var dueDate: Date?
    var status: String
    var projectId: String
    var clientId: String
    var assignedToUserId: String
}


extension TaskModel {
    static var preview: TaskModel {
        return TaskModel(
            id: "sampleTaskId123",
            title: "Design Dashboard UI",
            dueDate: Date().addingTimeInterval(86400), status: "In Progress", // 1 day from now
            projectId: "consultant123",
            clientId: "client456",
            assignedToUserId: "project789"
        )
    }
}
