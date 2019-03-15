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
        let mask = IPMask(ipv4: 24)!
        XCTAssert(mask.bytes == [255,255,255,0])
    }

    static var allTests = [
        ("testInit", testInit),
    ]
    
}
