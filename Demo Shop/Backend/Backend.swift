//
//  Backend.swift
//  Demo Shop
//
//  Created by Nissi Vieira Miranda on 1/14/16.
//  Copyright © 2016 Nissi Vieira Miranda. All rights reserved.
//

import Foundation

class Backend
{
    var name: String!
    var username: String!
    var password: String!
    var email: String!
    
    //-------------------------------------------------------------------------//
    // MARK: User registration
    //-------------------------------------------------------------------------//
    
    private var userRegistration: UserRegistration!
    
    func registerUser(completion:(status: String, message: String) -> Void)
    {
        userRegistration = UserRegistration()
        userRegistration.name = name
        userRegistration.username = username
        userRegistration.password = password
        userRegistration.email = email
        
        userRegistration.verifyUserRegistrationData({
            
            (status, message) -> Void in
            
            completion(status: status, message: message)
        })
    }
    
    //-------------------------------------------------------------------------//
    // MARK: User sign in
    //-------------------------------------------------------------------------//
    
    private var userSignIn: UserSignIn!
    
    func signInUser(completion:(status: String, message: String) -> Void)
    {
        userSignIn = UserSignIn()
        userSignIn.username = username
        userSignIn.password = password
        
        userSignIn.signInUser({
            
            (status, message) -> Void in
            
            completion(status: status, message: message)
        })
    }
    
    //-------------------------------------------------------------------------//
    // MARK: Process payment
    //-------------------------------------------------------------------------//
    
    var token: STPToken!
    var shoppingCartItems: [ShoppingCartItem]!
    var shippingMethod: ShippingMethod!
    var valueToPay: CGFloat!
    
    private var paymentProcessing: PaymentProcessing!
    
    func processPayment(completion:(status: String, message: String) -> Void)
    {
        paymentProcessing = PaymentProcessing()
        paymentProcessing.token = token
        paymentProcessing.shoppingCartItems = shoppingCartItems
        paymentProcessing.shippingMethod = shippingMethod
        paymentProcessing.valueToPay = valueToPay
        
        paymentProcessing.createBackendCharge({
            
            (status, message) -> Void in
            
            completion(status: status, message: message)
        })
    }
    
    //-------------------------------------------------------------------------//
    // MARK: Items for sale fetching
    //-------------------------------------------------------------------------//
    
    var offset = 0
    
    private var itemsForSaleFetching: ItemsForSaleFetching!
    
    func fetchItemsForSale(completion:(status: String, returnData: [[String : AnyObject]]?) -> Void)
    {
        itemsForSaleFetching = ItemsForSaleFetching()
        itemsForSaleFetching.offset = offset
        
        itemsForSaleFetching.fetchItemsForSale({
            
            (status, returnData) -> Void in
            
            completion(status: status, returnData: returnData)
        })
    }
}