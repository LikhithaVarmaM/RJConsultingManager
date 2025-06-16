//
//  TopBarProfileButtonView.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/2/25.
//

import SwiftUI

struct TopBarProfileButtonView: View {
    var body: some View {
        NavigationLink(destination: ProfileView()) {
            Image(systemName: "person.crop.circle")
                .imageScale(.large)
                .foregroundColor(.primary)
                .accessibilityLabel("Profile")
        }
    }
}

struct TopBarProfileButtonView_Previews: PreviewProvider {
    static var previews: some View {
        TopBarProfileButtonView()
    }
}
