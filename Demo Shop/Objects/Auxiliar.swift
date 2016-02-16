//
//  Auxiliar.swift
//  Demo Shop
//
//  Created by Nissi Vieira Miranda on 1/12/16.
//  Copyright © 2016 Nissi Vieira Miranda. All rights reserved.
//

import Foundation

class Auxiliar
{
    //-------------------------------------------------------------------------//
    // MARK: MBProgressHUD
    //-------------------------------------------------------------------------//
    
    static func showLoadingHUDWithText(labelText : String, forView view : UIView)
    {
        dispatch_async(dispatch_get_main_queue())
        {
            let progressHud = MBProgressHUD.showHUDAddedTo(view, animated: true)
                progressHud.labelText = labelText
        }
    }
    
    static func hideLoadingHUDInView(view : UIView)
    {
        dispatch_async(dispatch_get_main_queue())
        {
            MBProgressHUD.hideAllHUDsForView(view, animated: true)
        }
    }
    
    //--------------------------------------------------------------------------------------//
    // MARK: "Ok" Alert Controller
    //--------------------------------------------------------------------------------------//
    
    static func presentAlertControllerWithTitle(title : String,
                            andMessage message : String,
                          forViewController vc : UIViewController)
    {
        let alert = UIAlertController(title: title,
                                    message: message,
                             preferredStyle: UIAlertControllerStyle.Alert)
        
        let alertAction = UIAlertAction(title: "Ok",
                                        style: UIAlertActionStyle.Default,
                                      handler: nil)
        
        alert.addAction(alertAction)
        
        dispatch_async(dispatch_get_main_queue())
        {
            vc.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //--------------------------------------------------------------------------------------//
    // MARK: Check Session
    //--------------------------------------------------------------------------------------//
    
    static func sessionIsValid() -> Bool
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        let currentUser = defaults.dictionaryForKey("currentUser")
        
        if currentUser == nil
        {
            return false
        }
        
        let sessionStatus = currentUser!["sessionStatus"] as! String
        
        if sessionStatus == "invalid"
        {
            return false
        }
        
        let sessionStart = currentUser!["sessionStart"] as! Int
        let currentDate = NSDate()
        let interval = Int(currentDate.timeIntervalSince1970) - sessionStart
        let maxSessionLenght = (60 * 60) * 24 // 24 hours
        
        if interval >= maxSessionLenght
        {
            return false
        }
        
        let fiveMins = 60 * 5
        
        if (maxSessionLenght - interval) <= fiveMins
        {
            return false
        }
        
        return true
    }
}