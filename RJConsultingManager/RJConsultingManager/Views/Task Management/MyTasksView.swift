//
//  MyTasksView.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/8/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct MyTasksView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var taskVM = TaskViewModel()
    @State private var showAddTask = false

    var body: some View {
        NavigationView {
            List {
                if taskVM.tasks.isEmpty {
                    Text("No tasks yet")
                        .foregroundColor(.gray)
                } else {
                    ForEach(taskVM.tasks) { task in
                        NavigationLink(destination: TaskDetailView(task: task, taskId: task.id ?? "")) {
                            VStack(alignment: .leading) {
                                Text(task.title)
                                    .font(.headline)

                                Text("Due: \(task.dueDate?.formatted(date: .abbreviated, time: .omitted) ?? "\(Date())")")
                                    .font(.subheadline)

                                Text("Status: \(task.status.capitalized)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddTask = true
                    } label: {
                        Label("Add Task", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddTask) {
                AddTaskView(
                    projectId: ProjectModel.preview.id ?? "",
                    projectClientId: ProjectModel.preview.clientId,
                    onTaskAdded: {
                        showAddTask = false
                        taskVM.fetchTasks(for: authViewModel.userId)
                    }
                )
            }
            .onAppear {
                if !authViewModel.userId.isEmpty {
                    taskVM.fetchTasks(for: authViewModel.userId)
                }
            }
        }
    }
}
struct MyTasksView_Previews: PreviewProvider {
    static var previews: some View {
        MyTasksView()
    }
}
