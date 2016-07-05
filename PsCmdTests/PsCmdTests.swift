//
//  PsCmdTests.swift
//  PsCmdTests
//
//  Created by hnw on 2016/07/06.
//  Copyright © 2016年 hnw. All rights reserved.
//

import XCTest
@testable import PsCmd

class PsCmdTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let cmd = PsCmd(["ps", "aux"])
        cmd.exec()
        print("cout=\(cmd.cout)")
        print("cerr=\(cmd.cerr)")
        print("retval=\(cmd.retval)")
        XCTAssert(true)
    }
}
