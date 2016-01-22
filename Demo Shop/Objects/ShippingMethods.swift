//
//  ShippingMethods.swift
//  Demo Shop
//
//  Created by Nissi Vieira Miranda on 1/15/16.
//  Copyright © 2016 Nissi Vieira Miranda. All rights reserved.
//

import Foundation

class ShippingMethods
{
    var freeShipping: CGFloat = 0
    var pac: CGFloat = 0
    var sedex: CGFloat = 0
    
    var shippingOptions = [[String : AnyObject]]()
    
    init()
    {
        freeShipping = 0
        pac = 20
        sedex = 45
        
        shippingOptions = [
            ["description": "Free Shipping", "detail": "10 to 15 business days",
                                             "amount": freeShipping, "identifier": "free"],
            ["description": "PAC", "detail": "5 to 10 business days",
                                   "amount": pac, "identifier": "pac"],
            ["description": "SEDEX", "detail": "2 to 5 business days",
                                     "amount": sedex, "identifier": "sedex"]
        ]
    }
    
    func availablePKShippingMethods() -> [PKShippingMethod]
    {
        var methods = [PKShippingMethod]()
        
        for option in shippingOptions
        {
            let description = option["description"] as! String
            let amount: CGFloat = option["amount"] as! CGFloat
            let decimal = NSDecimalNumber(string: "\(amount)")
            
            let shippingOption = PKShippingMethod(label: description, amount: decimal)
                shippingOption.detail = option["detail"] as? String
                shippingOption.identifier = option["identifier"] as? String
            
            methods.append(shippingOption)
        }
        
        return methods
    }
    
    func availableShippingMethods() -> [ShippingMethod]
    {
        var methods = [ShippingMethod]()
        
        for option in shippingOptions
        {
            let shippingMethod = ShippingMethod()
                shippingMethod.description = option["description"] as! String
                shippingMethod.detail = option["detail"] as! String
                shippingMethod.amount = option["amount"] as! CGFloat
                shippingMethod.identifier = option["identifier"] as! String
            
            methods.append(shippingMethod)
        }
        
        return methods
    }
    
    // In a real app, there'd be functions for calculate shipping method's values
    // according to costumer's zip code, shopping cart items weight, possible packing 
    // measurements etc
}

class ShippingMethod
{
    var description = ""
    var detail = ""
    var amount: CGFloat = 0
    var identifier = ""
}