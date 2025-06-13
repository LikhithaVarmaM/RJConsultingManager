//
//  AdminMainTabView.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/6/25.
//

import SwiftUI

struct AdminMainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
            
            ProjectListView()
                .tabItem {
                    Label("Projects", systemImage: "folder.fill")
                }
            
            ClientListView()
                .tabItem {
                    Label("Clients", systemImage: "person.2.fill")
                }
            
            TaskListView(project: ProjectModel.preview)
                .tabItem {
                    Label("Tasks", systemImage: "doc.fill")
                }
            
            ConsultantListView()
                .tabItem {
                    Label("Consultant List", systemImage: "person.fill")
                }
        }
    }
}

struct AdminMainTabView_Previews: PreviewProvider {
    static var previews: some View {
        AdminMainTabView()
    }
}
