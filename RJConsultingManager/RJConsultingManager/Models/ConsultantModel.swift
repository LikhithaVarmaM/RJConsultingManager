//
//  ConsultantModel.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/9/25.
//

import Foundation
import FirebaseFirestoreSwift

struct ConsultantModel: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var email: String
    var phone: String?
    var skills: [String]?

    // Add other relevant fields as needed
}

extension ConsultantModel {
    static var preview: ConsultantModel {
        ConsultantModel(
            id: "previewConsultantId",
            name: "John Doe",
            email: "john@example.com",
            phone: "123-456-7890",
            skills: ["iOS", "Swift", "Firebase"]
        )
    }
}
