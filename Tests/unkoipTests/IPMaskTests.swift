//
//  IPMaskTests.swift
//  unkoipTests
//
//  Created by unko on 2019/3/14.
//

import XCTest
@testable import unkoip

class IPMaskTests: XCTestCase {

    func testInit() {
        let net = IPNet(CIDR: "192.168.0.1/24")!
        let mask = net.mask
        let ip = net.ip.toIPv4()!
        XCTAssertEqual(mask.numberOfHost, 8)
        XCTAssertEqual(mask.numberOfNetwork, 24)
        XCTAssert(ip.defaultMask().bytes == [255,255,255,0], "\(ip.defaultMask().bytes)")
    }

    static var allTests = [
        ("testInit", testInit),
    ]
    
}
