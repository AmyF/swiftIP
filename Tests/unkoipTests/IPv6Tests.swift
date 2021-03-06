//
//  IPv6Tests.swift
//  unkoipTests
//
//  Created by unko on 2019/3/14.
//

import XCTest
@testable import unkoip

class IPv6Tests: XCTestCase {

    func testInit() {
        XCTAssert(IPv6(string: "::") != nil)
        XCTAssert(IPv6(string: "::")!.isEqual(to: IPv6.zero))
    }
    
    func testConvert() {
        let ipv4 = IPv4(string: "135.75.43.52")!
        XCTAssert(ipv4.string() == "135.75.43.52", ipv4.string())
        
        let ipv6 = IPv6(string: "0000:0000:0000:0000:0000:FFFF:874B:2B34")!
        XCTAssert(ipv6.toIPv4()!.string() == "135.75.43.52", ipv6.toIPv4()!.string())
        
        XCTAssert(ipv4.toIPv6()!.isEqual(to: ipv6))
        XCTAssert(ipv6.toIPv4()!.isEqual(to: ipv4))
        
        let colonIP = IPv6(string: "::FFFF:874B:2B34")!
        XCTAssert(colonIP.toIPv4()!.string() == "135.75.43.52", colonIP.toIPv4()!.string())
        XCTAssert(ipv4.toIPv6()!.isEqual(to: colonIP))
        XCTAssert(colonIP.toIPv4()!.isEqual(to: ipv4))
    }
    
    static var allTests = [
        ("testConvert", testConvert),
        ]

}
