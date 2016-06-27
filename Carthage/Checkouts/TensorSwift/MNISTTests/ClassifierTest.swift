import XCTest
import TensorSwift
import MNIST

class ClassifierTest: XCTestCase {
    func testClassify() {
        let classifier = Classifier(path: NSBundle(forClass: ClassifierTest.self).resourcePath!)
        let (images, labels) = downloadTestData()
        
        let xArray: [[Float]] = [UInt8](UnsafeBufferPointer(start: UnsafePointer<UInt8>(images.bytes + 16), count: 28 * 28 * 10000)).map { Float($0) / 255.0 }.grouped(28 * 28)
        let yArray: [Int] = [UInt8](UnsafeBufferPointer(start: UnsafePointer<UInt8>(labels.bytes + 8), count: 10000)).map { Int($0) }
        
        let accuracy = Float(zip(xArray, yArray).reduce(0) { $0 + (classifier.classify(Tensor(shape: [28, 28, 1], elements: $1.0)) == $1.1 ? 1 : 0) }) / Float(yArray.count)
        
        XCTAssertGreaterThan(accuracy, 0.99)
    }
}