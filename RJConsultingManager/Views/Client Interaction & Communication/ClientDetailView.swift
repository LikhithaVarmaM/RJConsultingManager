//
//  ClientDetailView.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/2/25.
//

import SwiftUI
import FirebaseFirestore
import UniformTypeIdentifiers

struct ClientDetailView: View {
    let client: ClientModel

    @State private var documents: [ClientDocumentModel] = []
    @State private var showDocumentPicker = false
    @State private var selectedFileURL: IdentifiableURL?
    @State private var alertError: IdentifiableError?

    var body: some View {
        VStack(alignment: .leading) {
            List {
                Section(header: Text("Client Info")) {
                    Text("Name: \(client.name)")
                    Text("Email: \(client.email)")
                    Text("Phone: \(client.phone)")
                }

                Section(header: Text("Documents")) {
                    if documents.isEmpty {
                        Text("No documents uploaded.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(documents) { document in
                            Button(action: {
                                if let url = URL(string: document.fileURL) {
                                    selectedFileURL = IdentifiableURL(url: url)
                                }
                            }) {
                                Text(document.name)
                            }
                        }
                        .onDelete(perform: deleteDocuments)
                    }
                }
            }

            Button(action: {
                showDocumentPicker = true
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Add Document")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle(client.name)
        .onAppear {
            fetchDocuments()
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker { url in
                uploadDocument(url: url)
                showDocumentPicker = false
            }
        }
        .sheet(item: $selectedFileURL) { identifiable in
            DocumentPreview(url: identifiable.url)
        }
        .alert(item: $alertError) { err in
            Alert(title: Text("Error"), message: Text(err.message), dismissButton: .default(Text("OK")))
        }
    }

    private func fetchDocuments() {
        Firestore.firestore()
            .collection("client_documents")
            .whereField("clientId", isEqualTo: client.id ?? "")
            .order(by: "createdAt")
            .getDocuments { snapshot, error in
                if let error = error {
                    alertError = IdentifiableError(message: error.localizedDescription)
                    return
                }
                self.documents = snapshot?.documents.compactMap {
                    try? $0.data(as: ClientDocumentModel.self)
                } ?? []
            }
    }

    private func uploadDocument(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let filename = UUID().uuidString + "_" + url.lastPathComponent
            let fileURLString = "https://example.com/files/\(filename)" // Replace with real URL if using Firebase Storage

            let newDoc = ClientDocumentModel(
                id: UUID().uuidString,
                name: url.lastPathComponent,
                fileURL: fileURLString,
                createdAt: Date(),
                clientId: client.id ?? ""
            )

            try Firestore.firestore()
                .collection("client_documents")
                .document(newDoc.id!)
                .setData(from: newDoc)

            documents.append(newDoc)

        } catch {
            alertError = IdentifiableError(message: error.localizedDescription)
        }
    }

    private func deleteDocuments(at offsets: IndexSet) {
        for index in offsets {
            let doc = documents[index]
            guard let id = doc.id else { continue }

            Firestore.firestore().collection("client_documents").document(id).delete { error in
                if let error = error {
                    alertError = IdentifiableError(message: error.localizedDescription)
                } else {
                    documents.remove(at: index)
                }
            }
        }
    }
}

struct ClientDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let client = Client(context: context)
        client.id = UUID()
        client.name = "Acme Corp"
        client.contactEmail = "acme@example.com"
        client.phoneNumber = "123-456-7890"
        client.notes = "Top priority client with frequent updates."

        return NavigationView {
            ClientDetailView(client: ClientModel.preview)
                .environment(\.managedObjectContext, context)
        }
    }
}



extension Client {
    var documentsArray: [Document] {
        let set = documents as? Set<Document> ?? []
        return set.sorted { $0.createdAt ?? Date() < $1.createdAt ?? Date() }
    }
}



