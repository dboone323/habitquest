import SwiftUI

public struct SearchHeaderComponent: View {
    @Binding var searchText: String
    @Binding var selectedFilter: SearchFilter
    var onSearchChanged: (() -> Void)?

    public init(searchText: Binding<String>, selectedFilter: Binding<SearchFilter>, onSearchChanged: (() -> Void)? = nil) {
        self._searchText = searchText
        self._selectedFilter = selectedFilter
        self.onSearchChanged = onSearchChanged
    }

    public var body: some View {
        VStack(spacing: 16) {
            // Search Text Field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search...", text: $searchText).accessibilityLabel("Text Field")
                    .textFieldStyle(.plain)
                    .onChange(of: searchText) { _ in
                        onSearchChanged?()
                    }
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        onSearchChanged?()
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
            Picker("Filter", selection: $selectedFilter) {
                ForEach(SearchFilter.allCases) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(.horizontal)
    }
}
