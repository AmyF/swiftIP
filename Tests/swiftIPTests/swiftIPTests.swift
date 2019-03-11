import XCTest
@testable import swiftIP

final class swiftIPTests: XCTestCase {
    func testExample() {
        
    }
    
    func testCreate() {
        let bytesTest = {
            XCTAssert(IPv4(from: [255,255,255,255]) != nil)
            XCTAssert(IPv4(from: [0,0,0,0]) != nil)
            XCTAssert(IPv4(from: [1,1,1,1,]) != nil)
            XCTAssert(IPv4(from: []) == nil)
            XCTAssert(IPv4(from: [255,255,255,255,255]) == nil)
        }
        let stringTest = {
            XCTAssert(IPv4(from: "0.0.0.0") != nil)
            XCTAssert(IPv4(from: "255.255.255.255") != nil)
            XCTAssert(IPv4(from: "") == nil)
            XCTAssert(IPv4(from: "256.256.256.256") == nil)
            XCTAssert(IPv4(from: "0,0,0,0") == nil)
            XCTAssert(IPv4(from: "-1.-1.-1.-1") == nil)
        }
        
        let lengthTest = {
            XCTAssert(IPv4(from: [0,0,0,0,0]) == nil)
            XCTAssert(IPv4(from: [0,0,0,0]) != nil)
            XCTAssert(IPv4(from: [0,0,0]) == nil)
            XCTAssert(IPv4(from: [0,0]) == nil)
            XCTAssert(IPv4(from: [0]) == nil)
            XCTAssert(IPv4(from: "0.0.0.0.0") == nil)
            XCTAssert(IPv4(from: "0.0.0.0") != nil)
            XCTAssert(IPv4(from: "0.0.0") == nil)
            XCTAssert(IPv4(from: "0.0") == nil)
            XCTAssert(IPv4(from: "0") == nil)
        }
        
        bytesTest()
        stringTest()
        lengthTest()
    }
    
    func testFormat() {
        let bytesTest = {
            let testIP = IPv4(from: [255,255,255,255])!
            XCTAssert(testIP.string() == "255.255.255.255")
            XCTAssert(testIP.string(formatter: .dotHexadecimal) == "0xFF.0xFF.0xFF.0xFF", "result is " + testIP.string(formatter: .dotHexadecimal))
        }
        let stringTest = {
            let testIP = IPv4(from: "192.0.2.235")!
            XCTAssert(testIP.string() == "192.0.2.235")
            XCTAssert(testIP.string(formatter: .dotHexadecimal) == "0xC0.0x00.0x02.0xEB", "result is " + testIP.string(formatter: .dotHexadecimal) + ", not is 0xC0.0x00.0x02.0xEB")
            XCTAssert(testIP.string(formatter: .dotOctal) == "0300.0000.0002.0353", "result is " + testIP.string(formatter: .dotOctal) + ", not is 0300.0000.0002.0353")
            XCTAssert(testIP.string(formatter: .hexadecimal) == "0xC00002EB", "result is " + testIP.string(formatter: .hexadecimal) + ", not is 0xC00002EB")
            XCTAssert(testIP.string(formatter: .decimal) == "3221226219", "result is " + testIP.string(formatter: .decimal) + ", not is 3221226219")
            XCTAssert(testIP.string(formatter: .octal) == "030000001353", "result is " + testIP.string(formatter: .octal) + ", not is 030000001353")
        }
        
        bytesTest()
        stringTest()
    }
    
    static var allTests = [
        ("testCreate", testCreate),
        ("testFormat", testFormat),
        ]
}
