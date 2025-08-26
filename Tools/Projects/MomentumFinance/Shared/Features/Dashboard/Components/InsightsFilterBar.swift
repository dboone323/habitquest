import SwiftUI

struct InsightsFilterBar: View {
    @Binding var filterPriority: InsightPriority?
    @Binding var filterType: InsightType?

    var body: some View {
        HStack {
            // Priority Filter
            Menu {
                Button("All Priorities") {
                    filterPriority = nil
                }

                ForEach(InsightPriority.allCases, id: \.self) { priority in
                    Button(priority.rawValue.capitalized) {
                        filterPriority = priority
                    }
                }
            } label: {
                HStack {
                    Text(filterPriority?.rawValue.capitalized ?? "All Priorities")
                    Image(systemName: "chevron.down")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }

            // Type Filter
            Menu {
                Button("All Types") {
                    filterType = nil
                }

                ForEach(InsightType.allCases, id: \.self) { type in
                    Button(type.rawValue.capitalized) {
                        filterType = type
                    }
                }
            } label: {
                HStack {
                    Text(filterType?.rawValue.capitalized ?? "All Types")
                    Image(systemName: "chevron.down")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

#Preview {
    InsightsFilterBar(
        filterPriority: .constant(nil),
        filterType: .constant(nil)
    )
}
