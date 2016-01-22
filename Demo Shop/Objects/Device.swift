//
//  Device.swift
//  Demo Shop
//
//  Created by Nissi Vieira Miranda on 1/13/16.
//  Copyright © 2016 Nissi Vieira Miranda. All rights reserved.
//

import Foundation

class Device
{
    var IS_IPHONE: Bool {
        get {
            if UIDevice.currentDevice().userInterfaceIdiom == .Phone
            {
                return true
            }
            else
            {
                return false
            }
        }
    }
    
    var IS_IPHONE_5: Bool {
        get {
            if IS_IPHONE && UIScreen.mainScreen().bounds.size.height == 568.0
            {
                return true
            }
            else
            {
                return false
            }
        }
    }
    
    var IS_IPHONE_6: Bool {
        get {
            if IS_IPHONE && UIScreen.mainScreen().bounds.size.height == 667.0
            {
                return true
            }
            else
            {
                return false
            }
        }
    }
    
    var IS_IPHONE_6_PLUS: Bool {
        get {
            if IS_IPHONE && UIScreen.mainScreen().bounds.size.height == 736.0
            {
                return true
            }
            else
            {
                return false
            }
        }
    }
}