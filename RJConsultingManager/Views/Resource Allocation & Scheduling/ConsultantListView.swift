//
//  ConsultantListView.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/2/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ConsultantListView: View {
    @State private var consultants: [ConsultantModel] = []
    @State private var showAddConsultant = false
    @State private var alertError: IdentifiableError?

    var body: some View {
        NavigationView {
            List {
                ForEach(consultants) { consultant in
                    NavigationLink(destination: ConsultantDetailView(consultant: consultant)) {
                        VStack(alignment: .leading) {
                            Text(consultant.name)
                                .font(.headline)
                            Text(consultant.email)
                                .font(.subheadline)
                        }
                    }
                }
                .onDelete(perform: deleteConsultants)
            }
            .navigationTitle("Consultants")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddConsultant.toggle() }) {
                        Label("Add Consultant", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddConsultant) {
                AddConsultantView(onConsultantAdded: fetchConsultants)
            }
            .onAppear {
                fetchConsultants()
            }
            .alert(item: $alertError) { err in
                Alert(title: Text("Error"), message: Text(err.message), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func fetchConsultants() {
        Firestore.firestore().collection("consultants").getDocuments { snapshot, error in
            if let error = error {
                alertError = IdentifiableError(message: error.localizedDescription)
                return
            }
            consultants = snapshot?.documents.compactMap {
                try? $0.data(as: ConsultantModel.self)
            } ?? []
        }
    }

    private func deleteConsultants(at offsets: IndexSet) {
        for index in offsets {
            let consultant = consultants[index]
            guard let id = consultant.id else { continue }
            Firestore.firestore().collection("consultants").document(id).delete { error in
                if let error = error {
                    alertError = IdentifiableError(message: error.localizedDescription)
                } else {
                    consultants.remove(at: index)
                }
            }
        }
    }
}

struct ConsultantListView_Previews: PreviewProvider {
    static var previews: some View {
        ConsultantListView()
    }
}
