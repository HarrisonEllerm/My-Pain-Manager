//
//  UIFlowSequenceTests.swift
//  MPM-Sft-Eng-ProjUITests
//
//  Created by Harrison Ellerm on 8/08/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import Foundation

import XCTest

class OnBoardingUITest: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-ui_tests")
    }
    
    override func tearDown() {
        super.tearDown()
        
    }
    
    /**
        Passes in a command line argument to the app in order to
        test that OnBoarding is triggered, as it would be for a
        freshly installed application on a users device. Then tests
        that the "lets go" button, when tapped, takes a user to the
        login page.
    */
    func testOnboarding() {
        app.launchArguments.append("-ui_tests")
        app.launch()
        XCTAssertTrue(app.onBoardingTriggered)
        app.swipeLeft()
        app.swipeLeft()
        app/*@START_MENU_TOKEN@*/.collectionViews.buttons["Let's go"]/*[[".otherElements[\"onboardingController\"].collectionViews",".cells.buttons[\"Let's go\"]",".buttons[\"Let's go\"]",".collectionViews"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.tap()
        XCTAssertTrue(app.loginScreenTriggered)
    }
    
}

extension XCUIApplication {
    
    var onBoardingTriggered: Bool {
        return otherElements["onboardingController"].exists
    }
    
    var loginScreenTriggered: Bool {
        return otherElements["welcomeController"].exists
    }
    
    var signUpScreenTriggered: Bool {
        return otherElements["signUserUpController"].exists
    }
    
    var signInScreenTriggered: Bool {
        return otherElements["loginViewController"].exists
    }
    
}
