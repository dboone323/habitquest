//
//  TestFile16.swift
//  Manual Test File 16
//

import Foundation
import SwiftUI

class TestClass16: ObservableObject {
    @Published var data: [String] = []

    func loadData() {
        data = Array(1 ... 10).map { "Item \($0) from TestFile16" }
    }

    func processData() {
        print("Processing data in TestFile16")
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

struct TestView16: View {
    @StateObject private var testClass = TestClass16()

    var body: some View {
        VStack {
            Text("Test View 16")
                .font(.title)

            Button("Load Data").accessibilityLabel("Button") {
                testClass.loadData()
            }

            List(testClass.data, id: \.self) { item in
                Text(item)
            }
        }
        .onAppear {
            testClass.loadData()
        }
    }
}
