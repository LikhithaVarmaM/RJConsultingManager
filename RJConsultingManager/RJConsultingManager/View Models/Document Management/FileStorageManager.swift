//
//  FileStorageManager.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/2/25.
//

import Foundation
import UniformTypeIdentifiers

class FileStorageManager {
    static let shared = FileStorageManager()
    private init() {}

    // Save file data with a given name, returns local file URL
    func saveFile(data: Data, fileName: String) throws -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)

        try data.write(to: fileURL, options: .atomic)
        return fileURL
    }

    // Retrieve file URL from filename (for reading/viewing)
    func getFileURL(fileName: String) -> URL? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        return FileManager.default.fileExists(atPath: fileURL.path) ? fileURL : nil
    }
}

