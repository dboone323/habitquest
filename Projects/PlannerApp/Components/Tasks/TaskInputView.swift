// PlannerApp/Components/Tasks/TaskInputView.swift
import Foundation
import SwiftUI

public struct TaskInputView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var newTaskTitle: String
    var isInputFieldFocused: FocusState<Bool>.Binding
    var onAddTask: () -> Void

    public var body: some View {
        HStack {
            TextField("New Task", text: $newTaskTitle, onCommit: onAddTask)
                .focused(isInputFieldFocused)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)

            Button(action: onAddTask) {
                Image(systemName: "plus.circle.fill")
            }
            .disabled(newTaskTitle.isEmpty)
        }
        .padding()
    }
}
