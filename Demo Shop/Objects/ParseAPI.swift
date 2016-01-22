//
//  ParseAPI.swift
//  Demo Shop
//
//  Created by Nissi Vieira Miranda on 1/20/16.
//  Copyright © 2016 Nissi Vieira Miranda. All rights reserved.
//

import Foundation

class ParseAPI
{
    static var lowerPositionLimit = 0
    static var higherPositionLimit = 7
    
    static func retrieveItemsForSale(onCompletion: (items: [ItemForSale]?, noConnection: Bool) -> Void)
    {
        guard Reachability.connectedToNetwork() else
        {
            onCompletion(items: nil, noConnection: true)
            return
        }
        
        let query = PFQuery(className:"ItemForSale")
            query.orderByAscending("position")
            query.whereKey("position", greaterThan: ParseAPI.lowerPositionLimit)
            query.whereKey("position", lessThan: ParseAPI.higherPositionLimit)
            query.limit = 6
        
        query.findObjectsInBackgroundWithBlock
            {
                (objects, error) -> Void in
                
                guard error == nil else
                {
                    print("Error: \(error!) \(error!.userInfo)")
                    onCompletion(items: nil, noConnection: false)
                    return
                }
                
                guard objects != nil else
                {
                    onCompletion(items: nil, noConnection: false)
                    return
                }
                
                var itemsList = [ItemForSale]()
                
                guard objects!.count > 0 else
                {
                    onCompletion(items: itemsList, noConnection: false)
                    return
                }
                
                ParseAPI.lowerPositionLimit += 6
                ParseAPI.higherPositionLimit += 6
                
                for object in objects!
                {
                    let itemImage = object["itemImage"] as! PFFile
                    let url = NSURL(string: itemImage.url!)!
                    
                    let item = ItemForSale()
                        item.id = object.objectId!
                        item.itemName = object["itemName"] as! String
                        item.itemPrice = object["itemPrice"] as! CGFloat
                        item.itemImage = UIImage(data: NSData(contentsOfURL: url)!)
                    
                    itemsList.append(item)
                }
                
                onCompletion(items: itemsList, noConnection: false)
            }
        
    }
    
    static func saveOrderToParse(chargeId: String, description: String, chargeAmount: CGFloat, onCompletion: (status: String) -> Void)
    {
        let order = PFObject(className: "Order")
            order["chargeId"] = chargeId
            order["clientId"] = PFUser.currentUser()!.objectId!
            order["description"] = description
            order["chargeAmount"] = chargeAmount
        
        order.saveInBackgroundWithBlock {
            
            (success, error) -> Void in
            
            if success
            {
                onCompletion(status: "Success")
            }
            else
            {
                onCompletion(status: "Failure")
            }
        }

    }
}