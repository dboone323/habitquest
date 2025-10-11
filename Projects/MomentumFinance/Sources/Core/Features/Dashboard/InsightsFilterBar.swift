import SwiftUI

public struct InsightsFilterBar: View {
    @Binding var filterPriority: InsightPriority?
    @Binding var filterType: InsightType?

    public init(filterPriority: Binding<InsightPriority?>, filterType: Binding<InsightType?>) {
        _filterPriority = filterPriority
        _filterType = filterType
    }

    public var body: some View {
        HStack(spacing: 16) {
            // Priority Filter
            VStack(alignment: .leading, spacing: 8) {
                Text("Priority")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Picker("Priority", selection: self.$filterPriority) {
                    Text("All").tag(nil as InsightPriority?)
                    ForEach(InsightPriority.allCases) { priority in
                        Text(priority.rawValue).tag(priority as InsightPriority?)
                    }
                }
                .pickerStyle(.segmented)
            }

            // Type Filter
            VStack(alignment: .leading, spacing: 8) {
                Text("Type")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Picker("Type", selection: self.$filterType) {
                    Text("All").tag(nil as InsightType?)
                    ForEach(InsightType.allCases) { type in
                        Text(type.rawValue).tag(type as InsightType?)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
