import XCTest
@testable import TensorSwift

class DimensionTest: XCTestCase {
    func testAdd() {
        do {
            let a: Dimension = 2
            let b: Dimension = 3
            XCTAssertEqual(a + b, 5)
        }
    }
    
    func testSub() {
        do {
            let a: Dimension = 3
            let b: Dimension = 2
            XCTAssertEqual(a - b, 1)
        }
    }

    func testMul() {
        do {
            let a: Dimension = 2
            let b: Dimension = 3
            XCTAssertEqual(a * b, 6)
        }
    }

    func testDiv() {
        do {
            let a: Dimension = 6
            let b: Dimension = 2
            XCTAssertEqual(a / b, 3)
        }
    }
}