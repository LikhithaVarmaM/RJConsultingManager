//
//  ProjectModel.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/8/25.
//

import Foundation
import FirebaseFirestoreSwift

struct ProjectModel: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var description: String?
    var deadline: Date?
    var clientId: String
    var documents: [String]?
    var consultantUserIds: [String]
}

extension ProjectModel {
    static var preview: ProjectModel {
        ProjectModel(
            id: "previewProjectId",
            name: "Preview Project",
            description: "This is a preview project.",
            deadline: Date().addingTimeInterval(60 * 60 * 24 * 7), // 1 week from now
            clientId: ClientModel.preview.id ?? "previewClientId",
            documents: [],
            consultantUserIds: ["testUserId"]
        )
    }
}
