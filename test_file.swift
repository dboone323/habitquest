// Test file for UI responsiveness
// This file contains various code patterns to test analysis

import Foundation

class TestClass {
    var name: String
    var age: Int

    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }

    func doSomething() {
        print("Doing something")
        // TODO: Implement this method
        // FIXME: This needs fixing
    }

    func forceUnwrap(value: String?) -> String {
        value! // Force unwrap - potential crash
    }

    func longLineFunction(parameter1: String, parameter2: String, parameter3: String, parameter4: String, parameter5: String) -> String {
        parameter1 + parameter2 + parameter3 + parameter4 + parameter5 // This line is intentionally very long to test line length detection
    }

    func arrayOperations() {
        let array = [1, 2, 3, 4, 5]
        let filtered = array.filter { $0 > 2 }
        let mapped = filtered.map { $0 * 2 }
        let result = mapped.reduce(0, +)
        print(result)
    }
}

func testFunction() {
    let test = TestClass(name: "Test", age: 25)
    test.doSomething()
    let result = test.forceUnwrap(value: "test")
    print(result)
}
