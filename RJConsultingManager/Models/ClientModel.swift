//
//  ClientModel.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/9/25.
//

import Foundation
import FirebaseFirestoreSwift

struct ClientModel: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    var email: String
    var phone: String
}

extension ClientModel {
    static var preview: ClientModel {
        ClientModel(
            id: "client123",
            name: "Sample Client",
            email: "client@example.com",
            phone: "123-456-7890"
        )
    }
}



struct ClientDocumentModel: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    var fileURL: String
    var createdAt: Date
    var clientId: String
}

extension ClientDocumentModel {
    static var preview: ClientDocumentModel {
        ClientDocumentModel(
            id: "doc123",
            name: "Agreement.pdf",
            fileURL: "documents/agreement_12345.pdf",
            createdAt: Date(),
            clientId: "client123"
        )
    }
}
