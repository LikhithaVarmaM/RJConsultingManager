//
//  MainTabView.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/2/25.
//

import SwiftUI

struct MainTabView: View {
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

//            TeamView()
//                .tabItem {
//                    Label("Team", systemImage: "person.3.fill")
//                }
        }
    }
}


struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
