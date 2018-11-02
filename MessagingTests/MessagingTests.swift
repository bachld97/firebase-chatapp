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
    
    private let SAME_DATE_FORMAT = Converter.SAME_DATE_FORMAT
    private let SAME_WEEK_FORMAT = Converter.SAME_WEEK_FORMAT
    private let SAME_MONTH_FORMAT =  Converter.SAME_MONTH_FORMAT
    private let SAME_YEAR_FORMAT = Converter.SAME_YEAR_FORMAT
    private let DEFAULT_FORMAT = Converter.DEFAULT_FORMAT
    private let BANGKOK_TIMEZONE = NSTimeZone(name: "Asia/Bangkok")! as TimeZone
    
    override func setUp() {
        // 7:30 8/10/2018 in Local timezone
        var dateComponents = DateComponents()
        dateComponents.year = 2018
        dateComponents.month = 10
        dateComponents.day = 11
        dateComponents.timeZone = BANGKOK_TIMEZONE
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
        dateComponents.timeZone = BANGKOK_TIMEZONE
        dateComponents.hour = 5
        dateComponents.minute = 30
        
        // Create date from components
        let userCalendar = Calendar.current // user calendar
        let testDate = userCalendar.date(from: dateComponents)!
        
        let formatString = Converter.getHistoryFormatString(date1: testDate, date2: dateAsToday)
        XCTAssertEqual(formatString, SAME_DATE_FORMAT)
    }
    
    
    func testDateFormatStringSameWeekSameMonth() {
        var dateComponents = DateComponents()
        dateComponents.year = 2018
        dateComponents.month = 10
        dateComponents.day = 08
        dateComponents.timeZone = BANGKOK_TIMEZONE
        dateComponents.hour = 5
        dateComponents.minute = 30
        
        // Create date from components
        let userCalendar = Calendar.current // user calendar
        let testDate = userCalendar.date(from: dateComponents)!
        
        let formatString = Converter.getHistoryFormatString(date1: testDate, date2: dateAsToday)
        XCTAssertEqual(formatString, SAME_WEEK_FORMAT)
    }
    
    func testDateFormatStringSameWeekDifferentMonth() {
        var dateComponents = DateComponents()
        dateComponents.year = 2018
        dateComponents.month = 7
        dateComponents.day = 30
        dateComponents.timeZone = BANGKOK_TIMEZONE
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
        dateComponents2.timeZone = BANGKOK_TIMEZONE
        dateComponents2.hour = 5
        dateComponents2.minute = 30
        dateAsToday = userCalendar2.date(from: dateComponents2)!
        
        let formatString = Converter.getHistoryFormatString(date1: testDate, date2: dateAsToday)
        XCTAssertEqual(formatString, SAME_WEEK_FORMAT)
    }
    
    
    func testDateFormatStringSameWeekSameYear() {
        var dateComponents = DateComponents()
        dateComponents.year = 2018
        dateComponents.month = 10
        dateComponents.day = 08
        dateComponents.timeZone = BANGKOK_TIMEZONE
        dateComponents.hour = 5
        dateComponents.minute = 30
        
        // Create date from components
        let userCalendar = Calendar.current // user calendar
        let testDate = userCalendar.date(from: dateComponents)!
        
        let formatString = Converter.getHistoryFormatString(date1: testDate, date2: dateAsToday)
        XCTAssertEqual(formatString, SAME_WEEK_FORMAT)
    }
    
    func testDateFormatStringSameWeekDifferentYear() {
        var dateComponents = DateComponents()
        dateComponents.year = 2014
        dateComponents.month = 10
        dateComponents.day = 08
        dateComponents.timeZone = BANGKOK_TIMEZONE
        dateComponents.hour = 5
        dateComponents.minute = 30
        
        // Create date from components
        let userCalendar = Calendar.current // user calendar
        let testDate = userCalendar.date(from: dateComponents)!
        
        let formatString = Converter.getHistoryFormatString(date1: testDate, date2: dateAsToday)
        XCTAssertEqual(formatString, DEFAULT_FORMAT)
    }
    
    func testDateFormatStringSameMonthSameYear() {
        var dateComponents = DateComponents()
        dateComponents.year = 2018
        dateComponents.month = 10
        dateComponents.day = 05
        dateComponents.timeZone = BANGKOK_TIMEZONE
        dateComponents.hour = 5
        dateComponents.minute = 30
        
        // Create date from components
        let userCalendar = Calendar.current // user calendar
        let testDate = userCalendar.date(from: dateComponents)!
        
        let formatString = Converter.getHistoryFormatString(date1: testDate, date2: dateAsToday)
        XCTAssertEqual(formatString, SAME_MONTH_FORMAT)
    }
    
    func testDateFormatStringDifferentMonthSameYear() {
        var dateComponents = DateComponents()
        dateComponents.year = 2018
        dateComponents.month = 10
        dateComponents.day = 05
        dateComponents.timeZone = BANGKOK_TIMEZONE
        dateComponents.hour = 5
        dateComponents.minute = 30
        
        // Create date from components
        let userCalendar = Calendar.current // user calendar
        let testDate = userCalendar.date(from: dateComponents)!
        
        let formatString = Converter.getHistoryFormatString(date1: testDate, date2: dateAsToday)
        XCTAssertEqual(formatString, SAME_MONTH_FORMAT)
    }
    
    func testDateFormatStringSameMonthDifferentYear() {
        var dateComponents = DateComponents()
        dateComponents.year = 2015
        dateComponents.month = 10
        dateComponents.day = 05
        dateComponents.timeZone = BANGKOK_TIMEZONE
        dateComponents.hour = 5
        dateComponents.minute = 30
        
        // Create date from components
        let userCalendar = Calendar.current // user calendar
        let testDate = userCalendar.date(from: dateComponents)!
        
        let formatString = Converter.getHistoryFormatString(date1: testDate, date2: dateAsToday)
        XCTAssertEqual(formatString, DEFAULT_FORMAT)
    }
    
    func testDateFormatStringDifferentMonthDifferentYear() {
        var dateComponents = DateComponents()
        dateComponents.year = 2015
        dateComponents.month = 10
        dateComponents.day = 05
        dateComponents.timeZone = BANGKOK_TIMEZONE
        dateComponents.hour = 5
        dateComponents.minute = 30
        
        // Create date from components
        let userCalendar = Calendar.current // user calendar
        let testDate = userCalendar.date(from: dateComponents)!
        
        let formatString = Converter.getHistoryFormatString(date1: testDate, date2: dateAsToday)
        XCTAssertEqual(formatString, DEFAULT_FORMAT)
    }
    
    func testSameDayFormat() {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = BANGKOK_TIMEZONE
        dateFormatter.dateFormat = SAME_DATE_FORMAT
        let time = dateFormatter.string(from: dateAsToday)
        XCTAssertEqual(time, "07:30")
    }

    func testSameWeekFormat() {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = BANGKOK_TIMEZONE
        dateFormatter.dateFormat = SAME_WEEK_FORMAT
        let time = dateFormatter.string(from: dateAsToday)
        XCTAssertEqual(time, "Thursday")
    }
    
    func testSameMonthFormat() {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = BANGKOK_TIMEZONE
        dateFormatter.dateFormat = SAME_MONTH_FORMAT
        let time = dateFormatter.string(from: dateAsToday)
        XCTAssertEqual(time, "Thu 11")
    }
    
    func testSameYearFormat() {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = BANGKOK_TIMEZONE
        dateFormatter.dateFormat = SAME_YEAR_FORMAT
        let time = dateFormatter.string(from: dateAsToday)
        XCTAssertEqual(time, "11 October")
    }
    
    func testDifferentYearFormat() {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = BANGKOK_TIMEZONE
        dateFormatter.dateFormat = DEFAULT_FORMAT
        let time = dateFormatter.string(from: dateAsToday)
        XCTAssertEqual(time, "11/10/2018")
    }
}
