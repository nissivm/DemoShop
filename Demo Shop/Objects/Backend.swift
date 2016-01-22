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
    var shoppingCartItems: [ShoppingCartItem]!
    var shippingMethod: ShippingMethod!
    var valueToPay: CGFloat = 0.00
    
    func createBackendChargeWithToken(token: STPToken, completion:((status : String, message : String) -> Void))
    {
        let url = NSURL(string: "http://localhost/DemoShop-ServerSide/payment.php")!
        
        let params: [String : AnyObject] = ["stripeToken": token.tokenId,
                                                 "amount": Int(valueToPay),
                                              "currency" : "usd",
                                           "description" : assembleDescription(),
                                         "receipt_email" : PFUser.currentUser()!.email!]
        
        let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        do
        {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        }
        catch
        {
            completion(status: "Failure", message: "Error while processing payment, please try again.")
            return
        }
        
        let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        let session = NSURLSession(configuration: configuration)
        
        let task = session.dataTaskWithRequest(request) {
            
            [unowned self](data, response, error) -> Void in
            
            let errorMessage = "Error while processing payment, please try again."
            
            guard error == nil else
            {
                print("Error: \(error)")
                completion(status: "Failure", message: errorMessage)
                return
            }
            
            guard data != nil else
            {
                completion(status: "Failure", message: errorMessage)
                return
            }
            
            guard let response = response as? NSHTTPURLResponse else
            {
                completion(status: "Failure", message: errorMessage)
                return
            }
            
            guard response.statusCode == 200 else
            {
                print("Not ok response = \(response.description)")
                completion(status: "Failure", message: errorMessage)
                return
            }
            
            do
            {
                let jSon = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! [String : String]
                
                print("jSon = \(jSon)")
                
                let status = jSon["status"]!
                let message = jSon["message"]!
                
                guard status == "Success" else
                {
                    completion(status: status, message: message)
                    return
                }
                
                let chargeId = jSon["chargeId"]!
                
                ParseAPI.saveOrderToParse(chargeId,
                    description: self.assembleDescription(),
                    chargeAmount: self.valueToPay,
                    onCompletion: {
                        
                        (status) -> Void in
                        
                        completion(status: status, message: message)
                    })
            }
            catch let error as NSError
            {
                print("Error (try/catch): \(error)")
                completion(status: "Failure", message: errorMessage)
                return
            }
        }
        
        task.resume()
    }
    
    func assembleDescription() -> String
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