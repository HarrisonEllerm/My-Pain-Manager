//
//  SummaryControllerTests.swift
//  MPM-Sft-Eng-ProjTests
//
//  Created by Harrison Ellerm on 7/08/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import XCTest

@testable import MPM_Sft_Eng_Proj

class SummaryControllerTests: XCTestCase {
    
    var controller : SummaryController!
    
    override func setUp() {
        super.setUp()
        controller = SummaryController()
    }
    
    /**
        Tests the function defined inside Summary controller
        to ensure that it is returning the correct number of
        days. This is vital to ensure that we are scaling
        the data correctly when graphing.
    */
    func testDaysBetweenDates() {
        guard let date1 = "04/08/2018".toDate("dd/MM/yyyy")?.date else { return }
        guard let date2 = "07/08/2018".toDate("dd/MM/yyyy")?.date else { return }
        let expectation = controller.getDaysBetweenDates(firstDate: date1, secondDate: date2)
        XCTAssertEqual(expectation, 3)
    }
    
    /**
        Tests the function that defines an x value for each
        log. This function takes into account the day in the
        period that the value falls, and uses that to figure
        out how the value should be scaled.
    */
    func testGetXValueForLog() {
        //First test a date that falls on the "first day" or
        //0'th period, therefore its x value should just be a
        //double representation of the time string.
        let inputString1 = "2018-Jul-25 21:05:49"
        let difference1 = 0.0;
        let expectation1 = controller.getDoubleFromTimeString(input: inputString1, difference: difference1)
        
        //Second test a date that falls on the "second day" or
        //1st period, therefore its x value should be scaled
        //up by 24 hours (1 unit).
        let inputString2 = "2018-Jul-26 21:05:49"
        let difference2 = 1.0;
        let expectation2 = controller.getDoubleFromTimeString(input: inputString2, difference: difference2)
        
        XCTAssertEqual(expectation1, 21.05)
        XCTAssertEqual(expectation2, 24.0+21.05)
    }
    
    
}
