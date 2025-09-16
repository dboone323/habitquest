//
//  TestFile8.swift
//  Manual Test File 8
//

import Foundation
import SwiftUI

class TestClass8: ObservableObject {
    @Published var data: [String] = []

    func loadData() {
        data = Array(1...10).map { "Item \($0) from TestFile8" }
    }

    func processData() {
        print("Processing data in TestFile8")
        for item in data {
            print("  - \(item)")
        }
    }

    func complexMethod(param1: String, param2: Int) -> String {
        if param2 > 5 {
            "Complex result from \(param1) with value \(param2)"
        } else {
            "Simple result from \(param1)"
        }
    }
}

struct TestView8: View {
    @StateObject private var testClass = TestClass8()

    var body: some View {
        VStack {
            Text("Test View 8")
                .font(.title)

            Button("Load Data").accessibilityLabel("Button").accessibilityLabel("Button") {
                testClass.loadData()
            }
            .accessibilityLabel("Button")

            List(testClass.data, id: \.self) { item in
                Text(item)
            }
        }
        .onAppear {
            testClass.loadData()
        }
    }
}
