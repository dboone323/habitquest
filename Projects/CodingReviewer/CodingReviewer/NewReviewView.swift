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
                    TextField("Project Name", text: self.$projectName)
                    TextField("Repository URL", text: self.$repositoryURL)
                    TextField("Branch", text: self.$branchName)
                }

                Section {
                    Button("Create Review") {
                        // TODO: Implement review creation logic
                        self.dismiss()
                    }
                    .disabled(self.projectName.isEmpty || self.repositoryURL.isEmpty)
                }
            }
            .navigationTitle("New Code Review")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        self.dismiss()
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
