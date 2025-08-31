//
//  TestFile2.swift
//  Manual Test File 2
//

import Foundation
import SwiftUI

class TestClass2: ObservableObject {
    @Published var data: [String] = []

    func loadData() {
        data = Array(1 ... 10).map { "Item $0 from TestFile2" }
    }

    func processData() {
        print("Processing data in TestFile2")
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

struct TestView2: View {
    @StateObject private var testClass = TestClass2()

    var body: some View {
        VStack {
            Text("Test View 2")
                .font(.title)

            Button("Load Data") {
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
