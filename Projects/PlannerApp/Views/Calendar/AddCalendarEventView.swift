import Foundation
import SwiftUI

public struct AddCalendarEventView: View {
    @Environment(\.dismiss) var dismiss // Use dismiss environment
    @Binding var events: [CalendarEvent] // Assumes using model from PlannerApp/Models/

    @State private var title = ""
    @State private var date = Date()

    // Focus state for iOS keyboard management
    @FocusState private var isTitleFocused: Bool

    private var isTitleValid: Bool {
        !self.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header with buttons for better macOS compatibility
            HStack {
                Button("Cancel", action: {
                    #if os(iOS)
                        HapticManager.lightImpact()
                    #endif
                    self.dismiss()
                })
                .accessibilityLabel("Button")
                #if os(iOS)
                    .buttonStyle(.iOSSecondary)
                #endif
                    .foregroundColor(.blue)

                Spacer()

                Text("New Event")
                    .font(.title3)
                    .fontWeight(.semibold)

                Spacer()

                Button("Save", action: {
                    #if os(iOS)
                        HapticManager.notificationSuccess()
                    #endif
                    self.saveEvent()
                    self.dismiss()
                })
                .accessibilityLabel("Button")
                #if os(iOS)
                    .buttonStyle(.iOSPrimary)
                #endif
                    .disabled(!self.isTitleValid)
                    .foregroundColor(self.isTitleValid ? .blue : .gray)
            }
            .padding()
            #if os(macOS)
                .background(Color(NSColor.controlBackgroundColor))
            #else
                .background(Color(.systemBackground))
            #endif
            #if os(iOS)
            .iOSEnhancedTouchTarget()
            #endif

            Form {
                TextField("Event Title", text: self.$title).accessibilityLabel("Text Field")
                    .focused(self.$isTitleFocused)
                #if os(iOS)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                    .onSubmit {
                        self.isTitleFocused = false
                    }
                #endif
                DatePicker(
                    "Event Date", selection: self.$date, displayedComponents: [.date, .hourAndMinute]
                )
            }
            #if os(iOS)
            .iOSKeyboardDismiss()
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done", action: {
                            self.isTitleFocused = false
                            UIApplication.shared.sendAction(
                                #selector(UIResponder.resignFirstResponder), to: nil, from: nil,
                                for: nil
                            )
                        })
                        .accessibilityLabel("Button")
                        .buttonStyle(.iOSPrimary)
                        .foregroundColor(.blue)
                        .font(.body.weight(.semibold))
                    }
                }
            }
            #endif
        }
        #if os(macOS)
        .frame(minWidth: 500, minHeight: 400)
        #else
        .iOSPopupOptimizations()
        #endif
    }

    private func saveEvent() {
        let newEvent = CalendarEvent(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            date: self.date
        )
        self.events.append(newEvent)

        CalendarDataManager.shared.save(events: self.events)
    }
}

// struct AddCalendarEventView_Previews: PreviewProvider {
//     static var previews: some View {
//         AddCalendarEventView(events: .constant([]))
//     }
// }
