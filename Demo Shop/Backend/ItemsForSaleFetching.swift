//
//  ItemsForSaleFetching.swift
//  Demo Shop
//
//  Created by Nissi Vieira Miranda on 2/16/16.
//  Copyright © 2016 Nissi Vieira Miranda. All rights reserved.
//

import Foundation

class ItemsForSaleFetching
{
    var offset = 0
    
    func fetchItemsForSale(completion:(status: String, returnData: [[String : AnyObject]]?) -> Void)
    {
        let url = NSURL(string: "http://localhost/DemoShop-ServerSide/fetchItemsForSale/\(offset)")!
        
        let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "GET"
        
        let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        let session = NSURLSession(configuration: configuration)
        
        let task = session.dataTaskWithRequest(request) {
            
            (data, response, error) -> Void in
            
            guard error == nil else
            {
                print("Error != nil (fetchItemsForSale): \(error)")
                completion(status: "Error", returnData: nil)
                return
            }
            
            if let response = response as? NSHTTPURLResponse
            {
                if response.statusCode != 200
                {
                    print("statusCode != 200 (fetchItemsForSale): \(response.description)")
                    completion(status: "Error", returnData: nil)
                    return
                }
            }
            
            guard data != nil else
            {
                print("Data == nil (fetchItemsForSale)")
                completion(status: "Error", returnData: nil)
                return
            }
            
//            let backendResponse = NSString(data: data!, encoding: NSUTF8StringEncoding)
//            print("\n")
//            print("backendResponse (fetchItemsForSale) => \(backendResponse)")
//            print("\n")
            
            do
            {
                // Response from server
                let jSon = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! [String : AnyObject]
                
                let status = jSon["status"] as! String
                
                if status != "Success"
                {
                    completion(status: status, returnData: nil)
                    return
                }
                
                let items = jSon["items"] as! [[String : AnyObject]]
                completion(status: status, returnData: items)
            }
            catch let error as NSError
            {
                print("Error try/catch (fetchItemsForSale): \(error)")
                completion(status: "Error", returnData: nil)
            }
        }
        
        task.resume()
    }
}