//
//  DocumentModel.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/11/25.
//

import Foundation
import FirebaseFirestoreSwift

struct DocumentModel: Identifiable, Codable {
    @DocumentID var id: String?         // Firebase document ID
    var name: String                    // Display name of the document
    var fileURL: String                 // File name or path (used for downloading or preview)
    var createdAt: Date                 // Timestamp when the document was added

    // Optional project association
    var projectId: String?
}
