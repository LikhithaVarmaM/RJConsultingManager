//
//  ClientListView.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/2/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ClientListView: View {
    @State private var clients: [ClientModel] = []
    @State private var showAddClient = false
    @State private var errorMessage: IdentifiableError?

    var body: some View {
        NavigationView {
            List {
                ForEach(clients) { client in
                    NavigationLink(destination: ClientDetailView(client: client)) {
                        VStack(alignment: .leading) {
                            Text(client.name)
                                .font(.headline)
                            Text(client.email)
                                .font(.subheadline)
                        }
                    }
                }
                .onDelete(perform: deleteClients)
            }
            .navigationTitle("Clients")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddClient.toggle() }) {
                        Label("Add Client", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddClient) {
                AddClientView(onClientAdded: fetchClients)
            }
            .onAppear {
                fetchClients()
            }
            .alert(item: $errorMessage) { error in
                Alert(title: Text("Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func fetchClients() {
        Firestore.firestore().collection("clients").getDocuments { snapshot, error in
            if let error = error {
                errorMessage = IdentifiableError(message: error.localizedDescription)
                return
            }
            clients = snapshot?.documents.compactMap {
                try? $0.data(as: ClientModel.self)
            } ?? []
        }
    }

    private func deleteClients(at offsets: IndexSet) {
        for index in offsets {
            let client = clients[index]
            guard let id = client.id else { continue }
            Firestore.firestore().collection("clients").document(id).delete { error in
                if let error = error {
                    errorMessage = IdentifiableError(message: error.localizedDescription)
                } else {
                    clients.remove(at: index)
                }
            }
        }
    }
}

struct ClientListView_Previews: PreviewProvider {
    static var previews: some View {
        ClientListView()
    }
}
