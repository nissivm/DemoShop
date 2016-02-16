//
//  StripeTests.swift
//  Demo ShopTests
//
//  Created by Nissi Vieira Miranda on 1/4/16.
//  Copyright © 2016 Nissi Vieira Miranda. All rights reserved.
//

import XCTest
@testable import Demo_Shop

class StripeTests: XCTestCase
{
    let card = Card()
    
    override func setUp()
    {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown()
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // Test data:
    // https://stripe.com/docs/testing
    // STPCardValidator.h
    //
    // 4242 4242 4242 4242	Visa
    // 5555 5555 5555 4444	MasterCard
    // 3782 822463 10005	American Express
    // 6011 1111 1111 1117	Discover
    // 3056 9309 0259 04	Diners Club
    // 3566 0020 2036 0505	JCB
    
    func testCardBrandName()
    {
        Card.cardNumber = "4242 4242 4242 4242"
        var brandName = card.cardBrandName()
        XCTAssertEqual(brandName, "visa", "Wrong card brand!")
        
        Card.cardNumber = "5555 5555 5555 4444"
        brandName = card.cardBrandName()
        XCTAssertEqual(brandName, "mastercard", "Wrong card brand!")
        
        Card.cardNumber = "3782 822463 10005"
        brandName = card.cardBrandName()
        XCTAssertEqual(brandName, "amex", "Wrong card brand!")
        
        Card.cardNumber = "6011 1111 1111 1117"
        brandName = card.cardBrandName()
        XCTAssertEqual(brandName, "discover", "Wrong card brand!")
        
        Card.cardNumber = "3056 9309 0259 04"
        brandName = card.cardBrandName()
        XCTAssertEqual(brandName, "diners", "Wrong card brand!")
        
        Card.cardNumber = "3566 0020 2036 0505"
        brandName = card.cardBrandName()
        XCTAssertEqual(brandName, "jcb", "Wrong card brand!")
        
        Card.cardNumber = "123" // STPCardBrandUnknown
        brandName = card.cardBrandName()
        XCTAssertEqual(brandName, "", "Wrong card name!")
    }
    
    func testFormatCardNumber()
    {
        // All:
        
        Card.cardNumber = "4" // Length 1
        var cardNumber = card.formatCardNumber()
        XCTAssertEqual(cardNumber, "4", "Wrong format!")
        
        Card.cardNumber = "42424" // Length 5
        cardNumber = card.formatCardNumber()
        XCTAssertEqual(cardNumber, "4242 4", "Wrong format!")
        
        // Visa, Master Card, Discover, JCB:
        
        Card.cardNumber = "4242 42424" // Length 10
        cardNumber = card.formatCardNumber()
        XCTAssertEqual(cardNumber, "4242 4242 4", "Wrong format!")
        
        Card.cardNumber = "4242 4242 42424" // Length 15
        cardNumber = card.formatCardNumber()
        XCTAssertEqual(cardNumber, "4242 4242 4242 4", "Wrong format!")
        
        Card.cardNumber = "4242 4242 4242 4242" // Correct size number
        cardNumber = card.formatCardNumber()
        XCTAssertEqual(cardNumber, "4242 4242 4242 4242", "Wrong format!")
        
        Card.cardNumber = "4242 4242 4242 42424" // Extra number
        cardNumber = card.formatCardNumber()
        XCTAssertEqual(cardNumber, "4242 4242 4242 4242", "Wrong format!")
        
        // Diners:
        
        Card.cardNumber = "3056 9309 0259 04" // Correct size number
        cardNumber = card.formatCardNumber()
        XCTAssertEqual(cardNumber, "3056 9309 0259 04", "Wrong format!")
        
        Card.cardNumber = "3056 9309 0259 044" // Extra number
        cardNumber = card.formatCardNumber()
        XCTAssertEqual(cardNumber, "3056 9309 0259 04", "Wrong format!")
        
        // Amex:
        
        Card.cardNumber = "3782 8224631" // Length 12
        cardNumber = card.formatCardNumber()
        XCTAssertEqual(cardNumber, "3782 822463 1", "Wrong format!")
        
        Card.cardNumber = "3782 822463 10005" // Correct size number
        cardNumber = card.formatCardNumber()
        XCTAssertEqual(cardNumber, "3782 822463 10005", "Wrong format!")
        
        Card.cardNumber = "3782 822463 100054" // Extra number
        cardNumber = card.formatCardNumber()
        XCTAssertEqual(cardNumber, "3782 822463 10005", "Wrong format!")
    }
    
    func testFormatExpirationDate()
    {
        Card.expirationDate = "0"
        var date = card.formatExpirationDate()
        XCTAssertEqual(date, "0", "Wrong format!")
        
        Card.expirationDate = "8"
        date = card.formatExpirationDate()
        XCTAssertEqual(date, "08", "Wrong format!")
        
        Card.expirationDate = "1"
        date = card.formatExpirationDate()
        XCTAssertEqual(date, "1", "Wrong format!")
        
        Card.expirationDate = "081"
        date = card.formatExpirationDate()
        XCTAssertEqual(date, "08 / 1", "Wrong format!")
        
        Card.expirationDate = "08 / 162"
        date = card.formatExpirationDate()
        XCTAssertEqual(date, "08 / 16", "Wrong format!")
    }
    
    func testFormatCVC()
    {
        // All:
        
        Card.cardNumber = "4242 4242 4242 4242" // Visa
        
        Card.cvc = "123"
        var cvc = card.formatCVC()
        XCTAssertEqual(cvc, "123", "Wrong format!")
        
        Card.cvc = "1234"
        cvc = card.formatCVC()
        XCTAssertEqual(cvc, "123", "Wrong format!")
        
        // Amex:
        
        Card.cardNumber = "3782 822463 10005"
        
        cvc = card.formatCVC()
        XCTAssertEqual(cvc, "1234", "Wrong format!")
        
        Card.cvc = "12345"
        cvc = card.formatCVC()
        XCTAssertEqual(cvc, "1234", "Wrong format!")
    }
    
    func testCardNumberValidationStatus()
    {
        Card.cardNumber = "4"
        var status = card.cardNumberValidationStatus()
        XCTAssertEqual(status, STPCardValidationState.Incomplete, "Wrong status!")
        
        Card.cardNumber = "9" // Unknown
        status = card.cardNumberValidationStatus()
        XCTAssertEqual(status, STPCardValidationState.Invalid, "Wrong status!")
        
        Card.cardNumber = "42" // Visa
        status = card.cardNumberValidationStatus()
        XCTAssertEqual(status, STPCardValidationState.Incomplete, "Wrong status!")
        
        Card.cardNumber = "37" // Amex
        status = card.cardNumberValidationStatus()
        XCTAssertEqual(status, STPCardValidationState.Incomplete, "Wrong status!")
        
        Card.cardNumber = "63" // Wrong Discover
        status = card.cardNumberValidationStatus()
        XCTAssertEqual(status, STPCardValidationState.Invalid, "Wrong status!")
        
        Card.cardNumber = "99" // Unknown
        status = card.cardNumberValidationStatus()
        XCTAssertEqual(status, STPCardValidationState.Invalid, "Wrong status!")
        
        Card.cardNumber = "4242 4242 4242 424" // Visa
        status = card.cardNumberValidationStatus()
        XCTAssertEqual(status, STPCardValidationState.Incomplete, "Wrong status!")
        
        Card.cardNumber = "4242 4242 4242 4241" // Incorrect number
        status = card.cardNumberValidationStatus()
        XCTAssertEqual(status, STPCardValidationState.Invalid, "Wrong status!")
        
        Card.cardNumber = "4242 4242 4242 4242" // Visa
        status = card.cardNumberValidationStatus()
        XCTAssertEqual(status, STPCardValidationState.Valid, "Wrong status!")
    }
    
    func testMonthValidationStatus()
    {
        var status = card.monthValidationStatus("08 / 16")
        XCTAssertEqual(status, STPCardValidationState.Valid, "Wrong status!")
        
        status = card.monthValidationStatus("11 / 16")
        XCTAssertEqual(status, STPCardValidationState.Valid, "Wrong status!")
        
        status = card.monthValidationStatus("15 / 16")
        XCTAssertEqual(status, STPCardValidationState.Invalid, "Wrong status!")
    }
    
    func testYearValidationStatus()
    {
        var status = card.yearValidationStatus("08 / 16")
        XCTAssertEqual(status, STPCardValidationState.Valid, "Wrong status!")
        
        status = card.yearValidationStatus("08 / 22")
        XCTAssertEqual(status, STPCardValidationState.Valid, "Wrong status!")
        
        status = card.yearValidationStatus("11 / 15")
        XCTAssertEqual(status, STPCardValidationState.Invalid, "Wrong status!")
    }
    
    func testCvcValidationStatus()
    {
        Card.cardNumber = "4242 4242 4242 4242" // Visa
        
        Card.cvc = "9"
        var status = card.cvcValidationStatus()
        XCTAssertEqual(status, STPCardValidationState.Incomplete, "Wrong status!")
        
        Card.cvc = "1"
        status = card.cvcValidationStatus()
        XCTAssertEqual(status, STPCardValidationState.Incomplete, "Wrong status!")
        
        Card.cvc = "123"
        status = card.cvcValidationStatus()
        XCTAssertEqual(status, STPCardValidationState.Valid, "Wrong status!")
    }
}
