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
    
    /**
        Tests the function defined inside Summary controller
        to ensure that it is returning the correct number of
        days. This is vital to ensure that we are scaling
        the data correctly when graphing.
    */
    func testDaysBetweenDates() {
        let controller = SummaryController()
        guard let date1 = "04/08/2018".toDate("dd/MM/yyyy")?.date else { return }
        guard let date2 = "07/08/2018".toDate("dd/MM/yyyy")?.date else { return }
        let expectation = controller.getDaysBetweenDates(firstDate: date1, secondDate: date2)
        XCTAssertEqual(expectation, 3)
    }
    
}
