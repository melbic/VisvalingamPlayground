import Foundation
import XCTest

public class PlaygroundTestObserver : NSObject, XCTestObservation {
    @objc public func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: UInt) {
        print("Test failed on line \(lineNumber): \(testCase.name), \(description)")
    }

    public class func observe() {
        let observer = PlaygroundTestObserver()
        let center = XCTestObservationCenter.shared()
        center.addTestObserver(observer)
    }
}


public class TestRunner {
    private let testClass: XCTestCase.Type
    
    public init(_ testClass:XCTestCase.Type) {
        self.testClass = testClass
    }
    
    public func run() {
        let testSuite = self.testClass.defaultTestSuite()
        testSuite.run()
        let run = testSuite.testRun as! XCTestSuiteRun
        
        print("Ran \(run.executionCount) tests in \(run.testDuration)s with \(run.totalFailureCount) failures")
    }
    
}
