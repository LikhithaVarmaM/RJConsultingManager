//
//  ConsultantPerformance.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/2/25.
//

import Foundation

struct ConsultantPerformance: Identifiable {
    let id = UUID()
    let name: String
    let hoursWorked: Int
    let tasksCompleted: Int
}

