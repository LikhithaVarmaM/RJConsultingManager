//
//  IdentifiableURL.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/2/25.
//

import Foundation

struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

struct IdentifiableError: Identifiable {
    var id: String { message }
    let message: String
}

