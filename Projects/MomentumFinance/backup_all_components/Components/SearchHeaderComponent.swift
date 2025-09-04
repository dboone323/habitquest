import SwiftUI

// MARK: - Search Header Component

struct SearchHeaderComponent: View {
    @Binding var searchText: String
    @Binding var selectedFilter: Features.GlobalSearchView.SearchFilter
    let onSearchChanged: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField("Search everything...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onChange(of: searchText) { _, _ in
                        onSearchChanged()
                    }

                if !searchText.isEmpty {
                    Button("Clear") {
                        searchText = ""
                        onSearchChanged()
                    }
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)

            // Filter Segments
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Features.GlobalSearchView.SearchFilter.allCases, id: \.self) { filter in
                        SearchFilterChipComponent(
                            filter: filter,
                            isSelected: selectedFilter == filter,
                            onTap: {
                                selectedFilter = filter
                                onSearchChanged()
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 16)
        .background(Color.primary.colorInvert())
    }
}

// MARK: - Search Filter Chip Component

struct SearchFilterChipComponent: View {
    let filter: Features.GlobalSearchView.SearchFilter
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: filter.icon)
                    .font(.caption)
                Text(filter.rawValue)
                    .font(.caption.weight(.medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected ? Color.blue : Color.gray.opacity(0.2)
            )
            .foregroundColor(
                isSelected ? .white : .primary
            )
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SearchHeaderComponent(
        searchText: .constant(""),
        selectedFilter: .constant(.all),
        onSearchChanged: {}
    )
}
