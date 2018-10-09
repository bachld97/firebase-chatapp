//
//  MessagingTests.swift
//  MessagingTests
//
//  Created by CPU12071 on 10/9/18.
//  Copyright © 2018 Le Duy Bach. All rights reserved.
//


import XCTest
@testable import Messaging

class MessagingTests: XCTestCase {
    private var dateAsToday: Date = Date()
    
    override func setUp() {
        // 7:30 8/10/2018 in Local timezone
        var dateComponents = DateComponents()
        dateComponents.year = 2018
        dateComponents.month = 10
        dateComponents.day = 11
        dateComponents.timeZone = NSTimeZone.local
        dateComponents.hour = 7
        dateComponents.minute = 30
        
        // Create date from components
        let userCalendar = Calendar.current // user calendar
        dateAsToday = userCalendar.date(from: dateComponents)!
    }

    override func tearDown() {
    }

    func testDateFormatStringSameDate() {
        var dateComponents = DateComponents()
        dateComponents.year = 2018
        dateComponents.month = 10
        dateComponents.day = 11
        dateComponents.timeZone = NSTimeZone.local
        dateComponents.hour = 5
        dateComponents.minute = 30
        
        // Create date from components
        let userCalendar = Calendar.current // user calendar
        let testDate = userCalendar.date(from: dateComponents)!
        
        let formatString = Converter.getHistoryFormatString(date1: testDate, date2: dateAsToday)
        XCTAssertEqual(formatString, "HH:mm")
    }
    
    
    func testDateFormatStringSameWeekSameMonth() {
        var dateComponents = DateComponents()
        dateComponents.year = 2018
        dateComponents.month = 10
        dateComponents.day = 08
        dateComponents.timeZone = NSTimeZone.local
        dateComponents.hour = 5
        dateComponents.minute = 30
        
        // Create date from components
        let userCalendar = Calendar.current // user calendar
        let testDate = userCalendar.date(from: dateComponents)!
        
        let formatString = Converter.getHistoryFormatString(date1: testDate, date2: dateAsToday)
        XCTAssertEqual(formatString, "EEEE")
    }
    
    func testDateFormatStringSameWeekDifferentMonth() {
        var dateComponents = DateComponents()
        dateComponents.year = 2018
        dateComponents.month = 7
        dateComponents.day = 30
        dateComponents.timeZone = NSTimeZone.local
        dateComponents.hour = 5
        dateComponents.minute = 30
        
        // Create date from components
        let userCalendar = Calendar.current // user calendar
        let userCalendar2 = Calendar.current // user calendar
        let testDate = userCalendar.date(from: dateComponents)!
        
        var dateComponents2 = DateComponents()
        dateComponents2.year = 2018
        dateComponents2.month = 8
        dateComponents2.day = 2
        dateComponents2.timeZone = NSTimeZone.local
        dateComponents2.hour = 5
        dateComponents2.minute = 30
        dateAsToday = userCalendar2.date(from: dateComponents2)!
        
        let formatString = Converter.getHistoryFormatString(date1: testDate, date2: dateAsToday)
        XCTAssertEqual(formatString, "EEEE")
    }
    
    
    func testDateFormatStringSameWeekSameYear() {
        var dateComponents = DateComponents()
        dateComponents.year = 2018
        dateComponents.month = 10
        dateComponents.day = 08
        dateComponents.timeZone = NSTimeZone.local
        dateComponents.hour = 5
        dateComponents.minute = 30
        
        // Create date from components
        let userCalendar = Calendar.current // user calendar
        let testDate = userCalendar.date(from: dateComponents)!
        
        let formatString = Converter.getHistoryFormatString(date1: testDate, date2: dateAsToday)
        XCTAssertEqual(formatString, "EEEE")
    }
    
    func testDateFormatStringSameWeekDifferentYear() {
        var dateComponents = DateComponents()
        dateComponents.year = 2014
        dateComponents.month = 10
        dateComponents.day = 08
        dateComponents.timeZone = NSTimeZone.local
        dateComponents.hour = 5
        dateComponents.minute = 30
        
        // Create date from components
        let userCalendar = Calendar.current // user calendar
        let testDate = userCalendar.date(from: dateComponents)!
        
        let formatString = Converter.getHistoryFormatString(date1: testDate, date2: dateAsToday)
        XCTAssertEqual(formatString, "dd/MM/yyyy")
    }
    
    func testDateFormatStringSameMonthSameYear() {
        var dateComponents = DateComponents()
        dateComponents.year = 2018
        dateComponents.month = 10
        dateComponents.day = 05
        dateComponents.timeZone = NSTimeZone.local
        dateComponents.hour = 5
        dateComponents.minute = 30
        
        // Create date from components
        let userCalendar = Calendar.current // user calendar
        let testDate = userCalendar.date(from: dateComponents)!
        
        let formatString = Converter.getHistoryFormatString(date1: testDate, date2: dateAsToday)
        XCTAssertEqual(formatString, "EE dd")
    }
    
    func testDateFormatStringDifferentMonthSameYear() {
        var dateComponents = DateComponents()
        dateComponents.year = 2018
        dateComponents.month = 10
        dateComponents.day = 05
        dateComponents.timeZone = NSTimeZone.local
        dateComponents.hour = 5
        dateComponents.minute = 30
        
        // Create date from components
        let userCalendar = Calendar.current // user calendar
        let testDate = userCalendar.date(from: dateComponents)!
        
        let formatString = Converter.getHistoryFormatString(date1: testDate, date2: dateAsToday)
        XCTAssertEqual(formatString, "EE dd")
    }
    
    func testDateFormatStringSameMonthDifferentYear() {
        var dateComponents = DateComponents()
        dateComponents.year = 2015
        dateComponents.month = 10
        dateComponents.day = 05
        dateComponents.timeZone = NSTimeZone.local
        dateComponents.hour = 5
        dateComponents.minute = 30
        
        // Create date from components
        let userCalendar = Calendar.current // user calendar
        let testDate = userCalendar.date(from: dateComponents)!
        
        let formatString = Converter.getHistoryFormatString(date1: testDate, date2: dateAsToday)
        XCTAssertEqual(formatString, "dd/MM/yyyy")
    }
    
    func testDateFormatStringDifferentMonthDifferentYear() {
        var dateComponents = DateComponents()
        dateComponents.year = 2015
        dateComponents.month = 10
        dateComponents.day = 05
        dateComponents.timeZone = NSTimeZone.local
        dateComponents.hour = 5
        dateComponents.minute = 30
        
        // Create date from components
        let userCalendar = Calendar.current // user calendar
        let testDate = userCalendar.date(from: dateComponents)!
        
        let formatString = Converter.getHistoryFormatString(date1: testDate, date2: dateAsToday)
        XCTAssertEqual(formatString, "dd/MM/yyyy")
    }
    
    
//    func testExample() {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
