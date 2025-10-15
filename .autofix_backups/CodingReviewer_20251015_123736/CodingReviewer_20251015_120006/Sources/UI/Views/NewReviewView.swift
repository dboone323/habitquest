//
//  NewReviewView.swift
//  CodingReviewer
//
//  View for creating a new code review
//

import SwiftUI

struct NewReviewView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var projectName = ""
    @State private var repositoryURL = ""
    @State private var branchName = "main"

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Project Details")) {
                    TextField("Project Name", text: $projectName)
                    TextField("Repository URL", text: $repositoryURL)
                    TextField("Branch", text: $branchName)
                }

                Section {
                    Button("Create Review") {
                        // TODO: Implement review creation logic
                        dismiss()
                    }
                    .disabled(projectName.isEmpty || repositoryURL.isEmpty)
                }
            }
            .navigationTitle("New Code Review")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 400, height: 300)
    }
}

#Preview {
    NewReviewView()
}
