//
//  PaymentProcessing.swift
//  Demo Shop
//
//  Created by Nissi Vieira Miranda on 2/9/16.
//  Copyright © 2016 Nissi Vieira Miranda. All rights reserved.
//

import Foundation

class PaymentProcessing
{
    var token: STPToken!
    var shoppingCartItems: [ShoppingCartItem]!
    var shippingMethod: ShippingMethod!
    var valueToPay: CGFloat!
    
    private let errorStatus = "Payment error"
    private let errorMessage = "Error while processing payment."
    
    func createBackendCharge(completion:(status: String, message: String) -> Void)
    {
        // Request preparation:
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let currentUser = defaults.dictionaryForKey("currentUser")!
        
        let clientId = currentUser["id"] as! Int
        let clientEmail = currentUser["email"] as! String
        let description = assembleDescription()
        
        let params: [String : AnyObject] = ["stripeToken" : token.tokenId,
                                               "clientId" : clientId,
                                            "clientEmail" : clientEmail,
                                                  "amount": Int(valueToPay),
                                               "currency" : "usd",
                                            "description" : description]
        
        let url = NSURL(string: "http://localhost/DemoShop-ServerSide/ProcessPayment.php")!
        
        let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
        
        do
        {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        }
        catch
        {
            print("Error while creating jSon object (createBackendCharge)")
            completion(status: errorStatus, message: errorMessage)
            return
        }
        
        let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        let session = NSURLSession(configuration: configuration)
        
        // Send request:
        
        let task = session.dataTaskWithRequest(request) {
            
            [unowned self](data, response, error) -> Void in
            
            guard error == nil else
            {
                print("Error != nil (createBackendCharge): \(error)")
                completion(status: self.errorStatus, message: self.errorMessage)
                return
            }
            
            guard data != nil else
            {
                print("Data == nil (createBackendCharge)")
                completion(status: self.errorStatus, message: self.errorMessage)
                return
            }
            
            if let response = response as? NSHTTPURLResponse
            {
                if response.statusCode != 200
                {
                    print("statusCode != 200 (createBackendCharge): \(response.description)")
                    completion(status: self.errorStatus, message: self.errorMessage)
                    return
                }
            }
            
            do
            {
                // Response from ProcessPayment.php
                let jSon = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! [String : String]
                
                completion(status: jSon["status"]!, message: jSon["message"]!)
            }
            catch let error as NSError
            {
                print("Error try/catch (createBackendCharge): \(error)")
                completion(status: self.errorStatus, message: self.errorMessage)
            }
        }
        
        task.resume()
    }
    
    private func assembleDescription() -> String
    {
        var description = ""
        
        for item in shoppingCartItems
        {
            let itemForSale = item.itemForSale
            let amount = item.amount
            
            description += "\(itemForSale.itemName) \(amount) x $\(itemForSale.itemPrice)0, "
        }
        
        description += "\(shippingMethod.description) $\(shippingMethod.amount)"
        
        return description
    }
}