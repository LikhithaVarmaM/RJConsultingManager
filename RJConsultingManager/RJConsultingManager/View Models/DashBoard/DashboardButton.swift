//
//  DashboardButton.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/2/25.
//

import Foundation
import SwiftUI

struct DashboardButton: View {
    var label: String
    var icon: String
    var color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(color)
                .clipShape(Circle())

            Text(label)
                .font(.headline)
                .foregroundColor(.primary)

            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
