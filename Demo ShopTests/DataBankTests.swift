//
//  DataBankTests.swift
//  Demo ShopTests
//
//  Created by Nissi Vieira Miranda on 2/11/16.
//  Copyright © 2016 Nissi Vieira Miranda. All rights reserved.
//

import XCTest
@testable import Demo_Shop

class DataBankTests: XCTestCase
{
    let backend = Backend()
    
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
    
    //-------------------------------------------------------------------------//
    // MARK: User registration tests
    //-------------------------------------------------------------------------//
    
    func testUserRegistrationInvalidEmail()
    {
        let expectation = expectationWithDescription("invalid email")
        
        backend.name = "Maria Flor"
        backend.username = "mariaflor"
        backend.password = "1234"
        backend.email = "mariafloremail.com"
        
        backend.registerUser({
            
            (status, message) -> Void in
            
            XCTAssertTrue(status == "Invalid email")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10, handler: {
            (error) -> Void in
            XCTAssertTrue(error == nil)
        })
    }
    
    func testUserRegistration()
    {
        let expectation = expectationWithDescription("user successfull registration")
        
        backend.name = "Maria Flor"
        backend.username = "mariaflor"
        backend.password = "1234"
        backend.email = "mariaflor@email.com"
        
        backend.registerUser({
            
            (status, message) -> Void in
            
            XCTAssertTrue(status == "Success")
            
            if status == "Success"
            {
                let defaults = NSUserDefaults.standardUserDefaults()
                let currentUser = defaults.dictionaryForKey("currentUser")!
                let clientName = currentUser["name"] as! String
                
                XCTAssertTrue(clientName == "Maria Flor")
            }
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10, handler: {
            (error) -> Void in
            XCTAssertTrue(error == nil)
        })
    }
    
    func testUserRegistrationUsernameTaken()
    {
        let expectation = expectationWithDescription("username taken")
        
        backend.name = "Josh Alves"
        backend.username = "mariaflor"
        backend.password = "1234"
        backend.email = "joshalves@email.com"
        
        backend.registerUser({
            
            (status, message) -> Void in
            
            XCTAssertTrue(status == "Username taken")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10, handler: {
            (error) -> Void in
            XCTAssertTrue(error == nil)
        })
    }
    
    //-------------------------------------------------------------------------//
    // MARK: User sign in tests
    //-------------------------------------------------------------------------//
    
    func testUserSignInNonexistentUser()
    {
        let expectation = expectationWithDescription("nonexistent user")
        
        backend.username = "josealves"
        backend.password = "1234"
        
        backend.signInUser({
            
            (status, message) -> Void in
            
            XCTAssertTrue(status == "Unregistered user")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10, handler: {
            (error) -> Void in
            XCTAssertTrue(error == nil)
        })
    }
    
    func testUserSignInIncorrectPassword()
    {
        let expectation = expectationWithDescription("incorrect password")
        
        backend.username = "mariaflor"
        backend.password = "5678"
        
        backend.signInUser({
            
            (status, message) -> Void in
            
            XCTAssertTrue(status == "Incorrect password")
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10, handler: {
            (error) -> Void in
            XCTAssertTrue(error == nil)
        })
    }
    
    func testUserSignIn()
    {
        let expectation = expectationWithDescription("successfull sign in")
        
        backend.username = "mariaflor"
        backend.password = "1234"
        
        backend.signInUser({
            
            (status, message) -> Void in
            
            XCTAssertTrue(status == "Success")
            
            if status == "Success"
            {
                let defaults = NSUserDefaults.standardUserDefaults()
                let currentUser = defaults.dictionaryForKey("currentUser")!
                let clientName = currentUser["name"] as! String
                
                XCTAssertTrue(clientName == "Maria Flor")
            }
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10, handler: {
            (error) -> Void in
            XCTAssertTrue(error == nil)
        })
    }
    
    //-------------------------------------------------------------------------//
    // MARK: Items for sale fetching tests
    //-------------------------------------------------------------------------//
    
    func testFetchItems()
    {
        let expectation = expectationWithDescription("fetch items")
        
        backend.offset = 1
        
        backend.fetchItemsForSale({
            
            (status, returnData) -> Void in
            
            XCTAssertTrue(returnData != nil)
            
            if let returnData = returnData
            {
                XCTAssertTrue(returnData.count == 6)
                
                let item01 = returnData.first!
                let name01 = item01["item_name"] as! String
                XCTAssertTrue(name01 == "Denim jacket")
                
                let item02 = returnData.last!
                let name02 = item02["item_name"] as! String
                XCTAssertTrue(name02 == "Denim pants")
            }
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10, handler: {
            (error) -> Void in
            XCTAssertTrue(error == nil)
        })
    }
    
    func testFetchItemsMoreItems()
    {
        let expectation = expectationWithDescription("fetch more items")
        
        backend.offset = 7
        
        backend.fetchItemsForSale({
            
            (status, returnData) -> Void in
            
            XCTAssertTrue(returnData != nil)
            
            if let returnData = returnData
            {
                XCTAssertTrue(returnData.count == 6)
                
                let item01 = returnData.first!
                let name01 = item01["item_name"] as! String
                XCTAssertTrue(name01 == "Khaki pants")
                
                let item02 = returnData.last!
                let name02 = item02["item_name"] as! String
                XCTAssertTrue(name02 == "Khaki sweather")
            }
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10, handler: {
            (error) -> Void in
            XCTAssertTrue(error == nil)
        })
    }
    
    func testFetchItemsNoMoreItems()
    {
        let expectation = expectationWithDescription("no more items to fetch")
        
        backend.offset = 13
        
        backend.fetchItemsForSale({
            
            (status, returnData) -> Void in
            
            XCTAssertTrue(status == "No results")
            
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10, handler: {
            (error) -> Void in
            XCTAssertTrue(error == nil)
        })
    }
}
