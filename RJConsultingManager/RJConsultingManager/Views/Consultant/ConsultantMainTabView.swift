//
//  ConsultantMainTabView.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/6/25.
//

import SwiftUI

struct ConsultantMainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
            
            
            
            MyProjectsView()
                .tabItem {
                    Label("My Projects", systemImage: "folder")
                }
            
            MyTasksView()
                .tabItem {
                    Label("My Tasks", systemImage: "checkmark.circle")
                }
            
            ConsultantListView()
                .tabItem {
                    Label("Consultants", systemImage: "person.2.fill")
                }
            
            ClientListView()
                .tabItem {
                    Label("Clients", systemImage: "briefcase.fill")
                }
        }
    }
}

struct ConsultantMainTabView_Previews: PreviewProvider {
    static var previews: some View {
        ConsultantMainTabView()
    }
}
