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
    
    func showLoadingHUDWithText(labelText : String, forView view : UIView)
    {
        dispatch_async(dispatch_get_main_queue())
        {
            let progressHud = MBProgressHUD.showHUDAddedTo(view, animated: true)
                progressHud.labelText = labelText
        }
    }
    
    func hideLoadingHUDInView(view : UIView)
    {
        dispatch_async(dispatch_get_main_queue())
        {
            MBProgressHUD.hideAllHUDsForView(view, animated: true)
        }
    }
    
    //--------------------------------------------------------------------------------------//
    // MARK: "Ok" Alert Controller
    //--------------------------------------------------------------------------------------//
    
    func presentAlertControllerWithTitle(title : String,
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
}