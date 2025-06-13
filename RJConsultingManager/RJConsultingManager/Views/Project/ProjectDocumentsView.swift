//
//  ProjectDocumentsView.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/4/25.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ProjectDocumentsView: View {
    let project: ProjectModel

    @State private var documentNames: [String] = []
    @State private var showDocumentPicker = false
    @State private var selectedPreviewURL: IdentifiableURL?
    @State private var documentModels: [DocumentModel] = []

    let columns = [GridItem(.adaptive(minimum: 100), spacing: 16)]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(documentModels) { document in
                    Button {
                        if let url = URL(string: document.fileURL) {
                            selectedPreviewURL = IdentifiableURL(url: url)
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: "doc.text.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 60)
                                .foregroundColor(.blue)
                            Text(document.name)
                                .font(.caption)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Project Documents")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showDocumentPicker = true
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
        }
        .fullScreenCover(item: $selectedPreviewURL) { identifiable in
            NavigationView {
                DocumentPreview(url: identifiable.url)
                    .navigationBarTitle("Preview", displayMode: .inline)
                    .navigationBarItems(trailing: Button("Done") {
                        selectedPreviewURL = nil
                    })
            }
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker { url in
                uploadDocument(url: url)
                showDocumentPicker = false
            }
        }
        .onAppear {
            fetchLatestProjectDocuments()
        }
    }

    private func fetchLatestProjectDocuments() {
        guard let projectId = project.id else { return }

        Firestore.firestore().collection("projects").document(projectId)
            .getDocument { snapshot, error in
                if let error = error {
                    print("❌ Error fetching updated project: \(error.localizedDescription)")
                    return
                }

                if let data = try? snapshot?.data(as: ProjectModel.self) {
                    self.documentNames = data.documents ?? []
                }
            }
    }

    private func uploadDocument(url: URL) {
        let fileName = UUID().uuidString + "_" + url.lastPathComponent
        let storageRef = Storage.storage().reference().child("documents/\(fileName)")

        do {
            let data = try Data(contentsOf: url)

            storageRef.putData(data, metadata: nil) { metadata, error in
                if let error = error {
                    print("❌ Upload error: \(error.localizedDescription)")
                    return
                }

                // ✅ Get public URL for preview
                storageRef.downloadURL { url, error in
                    if let url = url {
                        let newDoc = DocumentModel(
                            id: UUID().uuidString,
                            name: fileName,
                            fileURL: url.absoluteString,
                            createdAt: Date(),
                            projectId: project.id ?? ""
                        )

                        do {
                            try Firestore.firestore()
                                .collection("project_documents")
                                .document(newDoc.id!)
                                .setData(from: newDoc)

                            // Refresh local list
                            fetchDocuments()

                        } catch {
                            print("❌ Firestore save error: \(error.localizedDescription)")
                        }

                    } else {
                        print("❌ Failed to fetch download URL")
                    }
                }
            }

        } catch {
            print("❌ Read file error: \(error.localizedDescription)")
        }
    }
    
    private func fetchDocuments() {
        guard let projectId = project.id else { return }

        Firestore.firestore()
            .collection("project_documents")
            .whereField("projectId", isEqualTo: projectId)
            .order(by: "createdAt")
            .getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Error fetching documents: \(error.localizedDescription)")
                    return
                }

                self.documentModels = snapshot?.documents.compactMap {
                    try? $0.data(as: DocumentModel.self)
                } ?? []
            }
    }

    
    
    private func downloadAndPreview(fileName: String) {
        let storageRef = Storage.storage().reference().child("documents/\(fileName)")
        let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        storageRef.write(toFile: tmpURL) { url, error in
            if let url = url {
                selectedPreviewURL = IdentifiableURL(url: url)
            } else {
                print("Download error: \(error?.localizedDescription ?? "unknown error")")
            }
        }
    }
}

struct ProjectDocumentsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProjectDocumentsView(project: ProjectModel.preview)
        }
    }
}
