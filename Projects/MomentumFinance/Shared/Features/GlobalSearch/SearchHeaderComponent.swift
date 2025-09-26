import SwiftUI

public struct SearchHeaderComponent: View {
    @Binding var searchText: String
    @Binding var selectedFilter: SearchFilter
    var onSearchChanged: (() -> Void)?

    public init(searchText: Binding<String>, selectedFilter: Binding<SearchFilter>, onSearchChanged: (() -> Void)? = nil) {
        _searchText = searchText
        _selectedFilter = selectedFilter
        self.onSearchChanged = onSearchChanged
    }

    public var body: some View {
        VStack(spacing: 16) {
            // Search Text Field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search...", text: self.$searchText).accessibilityLabel("Text Field").accessibilityLabel("Text Field")
                    .textFieldStyle(.plain)
                    .onChange(of: self.searchText) { _ in
                        self.onSearchChanged?()
                    }
                if !self.searchText.isEmpty {
                    Button(action: {
                        self.searchText = ""
                        self.onSearchChanged?()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)

            // Filter Picker
            Picker("Filter", selection: self.$selectedFilter) {
                ForEach(SearchFilter.allCases) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(.horizontal)
    }
}
