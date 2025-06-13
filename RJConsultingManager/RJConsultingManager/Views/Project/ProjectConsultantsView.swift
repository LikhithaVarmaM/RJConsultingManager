//
//  ProjectConsultantsView.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/4/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ProjectConsultantsView: View {
    let projectId: String
    let currentConsultants: [String]

    @Environment(\.dismiss) private var dismiss
    @State private var allConsultants: [ConsultantModel] = []
    @State private var selectedConsultantIds: Set<String> = []

    var body: some View {
        List {
            ForEach(allConsultants) { consultant in
                MultipleSelectionRow(
                    title: consultant.name,
                    isSelected: selectedConsultantIds.contains(consultant.id ?? "")
                ) {
                    toggleSelection(consultant.id ?? "")
                }
            }
        }
        .navigationTitle("Assign Consultants")
        .onAppear {
            selectedConsultantIds = Set(currentConsultants)
            fetchConsultants()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveConsultants()
                }
            }
        }
    }

    private func fetchConsultants() {
        Firestore.firestore().collection("consultants").getDocuments { snapshot, error in
            if let docs = snapshot?.documents {
                self.allConsultants = docs.compactMap { try? $0.data(as: ConsultantModel.self) }
            }
        }
    }

    private func toggleSelection(_ id: String) {
        if selectedConsultantIds.contains(id) {
            selectedConsultantIds.remove(id)
        } else {
            selectedConsultantIds.insert(id)
        }
    }

    private func saveConsultants() {
        Firestore.firestore().collection("projects").document(projectId).updateData([
            "consultantUserIds": Array(selectedConsultantIds)
        ]) { _ in
            dismiss()
        }
    }
}

struct ProjectConsultantsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProjectConsultantsView(
                projectId: "sampleProject123",
                currentConsultants: ["consultantId1", "consultantId2"]
            )
        }
    }
}
