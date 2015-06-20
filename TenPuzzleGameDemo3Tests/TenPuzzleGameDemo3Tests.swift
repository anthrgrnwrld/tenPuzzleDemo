//
//  TenPuzzleGameDemo3Tests.swift
//  TenPuzzleGameDemo3Tests
//
//  Created by Masaki Horimoto on 2015/06/01.
//  Copyright (c) 2015年 Masaki Horimoto. All rights reserved.
//

import UIKit
import XCTest

class TenPuzzleGameDemo3Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
    // "+", "-", "×", "÷"

    func testCalc1() {
        let result = ViewController.calc(["1", "+", "2", "+", "3", "+", "4"])
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, Float(10.0), "result is 20")
    }
    
    func testCalc2() {
        let result = ViewController.calc(["1", "+", "2", "×", "3", "+", "4"])
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, Float(11.0), "result is 11")
    }
    
    func testCalc3() {
        let result = ViewController.calc(["1", "+", "2", "-", "3", "+", "4"])
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, Float(4.0), "result is 4")
    }
    
    func testCalc4() {
        let result = ViewController.calc(["1", "+", "2.0", "÷", "3.0", "+", "4"]) // 5.6666666666
        XCTAssertNotNil(result)
        XCTAssertEqualWithAccuracy(result!, Float(5.666666), 0.00001, "result is 5.666666")
    }
    
    func testCalc5() {
        let result = ViewController.calc(["(", "1", "+", "2", ")", "×", "(", "3", "+", "4", ")"])
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, Float(21.0), "result is 21")
    }
}
