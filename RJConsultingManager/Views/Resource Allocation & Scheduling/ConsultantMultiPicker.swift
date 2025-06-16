//
//  ConsultantMultiPicker.swift
//  RJConsultingManager
//
//  Created by Likhitha Mandapati on 6/4/25.
//

import SwiftUI

struct ConsultantMultiPicker: View {
    let allConsultants: [ConsultantModel]
    @Binding var selectedIds: Set<String>

    var body: some View {
        List {
            ForEach(allConsultants) { consultant in
                MultipleSelectionRow(
                    title: consultant.name,
                    isSelected: selectedIds.contains(consultant.id ?? "")
                ) {
                    toggleSelection(for: consultant)
                }
            }
        }
        .navigationTitle("Select Consultants")
    }

    private func toggleSelection(for consultant: ConsultantModel) {
        guard let id = consultant.id else { return }
        if selectedIds.contains(id) {
            selectedIds.remove(id)
        } else {
            selectedIds.insert(id)
        }
    }
}

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}



struct ConsultantMultiPicker_Previews: PreviewProvider {
    struct Wrapper: View {
        @State private var selected: Set<Consultant> = []

        var body: some View {
            let context = PersistenceController.preview.container.viewContext

            let consultant1 = Consultant(context: context)
            consultant1.name = "Alice"

            let consultant2 = Consultant(context: context)
            consultant2.name = "Bob"

            let mockConsultants: [Consultant] = [consultant1, consultant2]

            // Convert array to ForEach-compatible
            return NavigationView {
                ConsultantMultiPickerMock(
                    allConsultants: mockConsultants,
                    selectedConsultants: $selected
                )
            }
        }
    }

    static var previews: some View {
        Wrapper()
    }
}


struct ConsultantMultiPickerMock: View {
    var allConsultants: [Consultant]
    @Binding var selectedConsultants: Set<Consultant>

    var body: some View {
        List {
            ForEach(allConsultants, id: \.self) { consultant in
                MultipleSelectionRow(
                    title: consultant.name ?? "Unnamed",
                    isSelected: selectedConsultants.contains(consultant)
                ) {
                    if selectedConsultants.contains(consultant) {
                        selectedConsultants.remove(consultant)
                    } else {
                        selectedConsultants.insert(consultant)
                    }
                }
            }
        }
        .navigationTitle("Select Consultants")
    }
}
