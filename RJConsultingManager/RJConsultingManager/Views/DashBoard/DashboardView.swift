//
//  DashboardView.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/2/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var tasks: [TaskModel] = []
    @State private var projects: [ProjectModel] = []
    @State private var clients: [ClientModel] = []

    private let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Row 1
                    HStack(spacing: 16) {
                        SummaryCard(title: "Clients", count: clients.count, color: .blue)
                        SummaryCard(title: "Projects", count: projects.count, color: .green)
                    }

                    // Row 2
                    HStack(spacing: 16) {
                        SummaryCard(title: "Total Tasks", count: tasks.count, color: .orange)
                        SummaryCard(title: "Incomplete Tasks", count: incompleteTasksCount, color: .yellow)
                    }

                    // Row 3
                    HStack(spacing: 16) {
                        SummaryCard(title: "Overdue Tasks", count: overdueTasksCount, color: .red)
                        SummaryCard(title: "Assigned To Me", count: assignedTaskCount, color: .purple)
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    TopBarProfileButtonView()
                }
            }
            .onAppear {
                fetchData()
            }
        }
    }

    // MARK: - Computed Properties

    private var incompleteTasksCount: Int {
        tasks.filter { $0.status.lowercased() != "completed" }.count
    }

    private var overdueTasksCount: Int {
        let now = Date()
        return tasks.filter {
            if let dueDate = $0.dueDate {
                return $0.status.lowercased() != "completed" && dueDate < now
            }
            return false
        }.count
    }

    private var assignedTaskCount: Int {
        tasks.filter { $0.assignedToUserId == authViewModel.userId }.count
    }

    // MARK: - Firestore Fetch

    private func fetchData() {
        if authViewModel.role == "admin" {
            fetchAllClients()
            fetchAllProjects()
            fetchAllTasks()
        } else {
            fetchTasksForConsultant()
            fetchProjectsForConsultant()
            // Clients are not fetched for consultants in this example
        }
    }

    private func fetchAllClients() {
        db.collection("clients").getDocuments { snapshot, error in
            if let docs = snapshot?.documents {
                self.clients = docs.compactMap { try? $0.data(as: ClientModel.self) }
            }
        }
    }

    private func fetchAllProjects() {
        db.collection("projects").getDocuments { snapshot, error in
            if let docs = snapshot?.documents {
                self.projects = docs.compactMap { try? $0.data(as: ProjectModel.self) }
            }
        }
    }

    private func fetchAllTasks() {
        db.collection("tasks").getDocuments { snapshot, error in
            if let docs = snapshot?.documents {
                self.tasks = docs.compactMap { try? $0.data(as: TaskModel.self) }
            }
        }
    }

    private func fetchTasksForConsultant() {
        db.collection("tasks")
            .whereField("assignedToUserId", isEqualTo: authViewModel.userId)
            .getDocuments { snapshot, error in
                if let docs = snapshot?.documents {
                    self.tasks = docs.compactMap { try? $0.data(as: TaskModel.self) }
                }
            }
    }

    private func fetchProjectsForConsultant() {
        db.collection("projects").getDocuments { snapshot, error in
            if let docs = snapshot?.documents {
                let allProjects = docs.compactMap { try? $0.data(as: ProjectModel.self) }
                let relevantProjectIds = Set(tasks.map { $0.projectId })
                self.projects = allProjects.filter { relevantProjectIds.contains($0.id ?? "") }
            }
        }
    }
}

// Preview Provider
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
