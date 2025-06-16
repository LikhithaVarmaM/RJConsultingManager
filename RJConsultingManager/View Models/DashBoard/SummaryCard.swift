//
//  SummaryCard.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/2/25.
//

import Foundation
import SwiftUI

struct SummaryCard: View {
    var title: String
    var count: Int
    var color: Color

    var body: some View {
        VStack {
            Text("\(count)")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(width: 150, height: 100)
        .background(color)
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

