import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(IPv4Tests.allTests),
        testCase(IPv6Tests.allTests),
    ]
}
#endif
