//
//  CardPayment_VC.swift
//  Demo Shop
//
//  Created by Nissi Vieira Miranda on 1/6/16.
//  Copyright © 2016 Nissi Vieira Miranda. All rights reserved.
//

import UIKit

protocol CardPayment_VC_Delegate: class
{
    func clearShoppingCart()
}

class CardPayment_VC: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate
{
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var cardNumberTxtField: UITextField!
    @IBOutlet weak var cardBrandImgView: UIImageView!
    @IBOutlet weak var expiryTxtField: UITextField!
    @IBOutlet weak var cvcTxtField: UITextField!
    @IBOutlet weak var payButton: UIButton!
    
    @IBOutlet weak var shopLogo: UIImageView!
    @IBOutlet weak var shopName: UILabel!
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardLabel: UILabel!
    @IBOutlet weak var dividerOneWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var expiryLabel: UILabel!
    @IBOutlet weak var dividerTwoWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var cvcLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var payButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelButtonHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: CardPayment_VC_Delegate?
    
    let card = Card()
    let auxiliar = Auxiliar()
    let backend = Backend()
    var textFieldInUse: UITextField?
    
    // Received from ShoppingCart_VC
    var shoppingCartItems: [ShoppingCartItem]!
    var shippingMethod: ShippingMethod!
    var valueToPay: CGFloat = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willEnterForeground",
            name: UIApplicationWillEnterForegroundNotification, object: nil)

        cardNumberTxtField.addTarget(self, action: "didChangeText:", forControlEvents: .EditingChanged)
        expiryTxtField.addTarget(self, action: "didChangeText:", forControlEvents: .EditingChanged)
        cvcTxtField.addTarget(self, action: "didChangeText:", forControlEvents: .EditingChanged)
        
        expiryTxtField.enabled = false
        cvcTxtField.enabled = false
        
        let recognizer = UITapGestureRecognizer(target: self, action:Selector("handleTap:"))
            recognizer.delegate = self
        background.addGestureRecognizer(recognizer)
        
        if Device.IS_IPHONE_6
        {
            adjustForBiggerScreen(Constants.multiplier6)
        }
        else if Device.IS_IPHONE_6_PLUS
        {
            adjustForBiggerScreen(Constants.multiplier6plus)
        }
        
        let value : NSString = NSString(format: "%.02f", valueToPay)
        payButton.setTitle("Pay $\(value)", forState: .Normal)
        payButton.enabled = false
        payButton.alpha = 0.5
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle
    {
        return UIStatusBarStyle.LightContent
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //-------------------------------------------------------------------------//
    // MARK: Notifications
    //-------------------------------------------------------------------------//
    
    func willEnterForeground()
    {
        if Auxiliar.sessionIsValid() == false
        {
            navigationController!.popToRootViewControllerAnimated(true)
        }
    }
    
    //-------------------------------------------------------------------------//
    // MARK: IBActions
    //-------------------------------------------------------------------------//
    
    @IBAction func payButtonTapped(sender: UIButton)
    {
        if payButton.enabled
        {
            Card.cardNumber = cardNumberTxtField.text!
            Card.expirationDate = expiryTxtField.text!
            Card.cvc = cvcTxtField.text!
            
            let cardParam = card.getCardParams()
            
            auxiliar.showLoadingHUDWithText("Processing payment, please wait...", forView: self.view)
            
            guard Reachability.connectedToNetwork() else
            {
                auxiliar.hideLoadingHUDInView(self.view)
                auxiliar.presentAlertControllerWithTitle("No Internet Connection",
                    andMessage: "Make sure your device is connected to the internet.",
                    forViewController: self)
                
                return
            }
            
            STPAPIClient.sharedClient().createTokenWithCard(cardParam, completion: {
                
                [unowned self](token, error) -> Void in
                
                guard error == nil else
                {
                    self.auxiliar.hideLoadingHUDInView(self.view)
                    self.auxiliar.presentAlertControllerWithTitle("Failure",
                        andMessage: "Error while processing payment, please try again.", forViewController: self)
                    
                    print("Error = \(error)")
                    
                    return
                }
                
                guard token != nil else
                {
                    self.auxiliar.hideLoadingHUDInView(self.view)
                    self.auxiliar.presentAlertControllerWithTitle("Failure",
                        andMessage: "Error while processing payment, please try again.", forViewController: self)
                    
                    return
                }
                
                self.backend.shoppingCartItems = self.shoppingCartItems
                self.backend.shippingMethod = self.shippingMethod
                self.backend.valueToPay = self.valueToPay
                
                self.backend.createBackendChargeWithToken(token!) {
                    
                    [unowned self](status, message) in
                    
                    self.auxiliar.hideLoadingHUDInView(self.view)
                    
                    if status == "Success"
                    {
                        self.promptUserForSuccessfulPayment(status, message: message)
                        return
                    }
                    
                    self.auxiliar.presentAlertControllerWithTitle(status,
                        andMessage: message, forViewController: self)
                }
            })
        }
    }
    
    @IBAction func cancelButtonTapped(sender: UIButton)
    {
        navigationController!.popViewControllerAnimated(true)
    }
    
    //-------------------------------------------------------------------------//
    // MARK: UITextField text formating
    //-------------------------------------------------------------------------//
    
    func didChangeText(textField : UITextField)
    {
        let txtFieldTxtLength = textField.text!.characters.count
        let txtFieldTag = textField.tag
        
        if txtFieldTxtLength > 0
        {
            if txtFieldTag == 10 // Card number
            {
                Card.cardNumber = textField.text!
                textField.text = card.formatCardNumber()
                Card.cardNumber = textField.text!
                
                if card.cardNumberIsValid()
                {
                    cardBrandImgView.image = card.cardImageForBrandName(card.cardBrandName())
                    expiryTxtField.enabled = true
                    cvcTxtField.enabled = true
                }
                else
                {
                    cardBrandImgView.image = nil
                    expiryTxtField.text = ""
                    cvcTxtField.text = ""
                    expiryTxtField.enabled = false
                    cvcTxtField.enabled = false
                }
            }
            else if txtFieldTag == 11 // Expiry date
            {
                Card.expirationDate = textField.text!
                textField.text = card.formatExpirationDate()
                Card.expirationDate = textField.text!
            }
            else // CVC
            {
                Card.cvc = textField.text!
                textField.text = card.formatCVC()
                Card.cvc = textField.text!
            }
            
            payButton.enabled = false
            payButton.alpha = 0.5
            
            if card.cardNumberIsValid() && card.expirationDateIsValid() && card.cvcIsValid()
            {
                payButton.enabled = true
                payButton.alpha = 1.0
            }
        }
    }
    
    //-------------------------------------------------------------------------//
    // MARK: UITextFieldDelegate
    //-------------------------------------------------------------------------//
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        textFieldInUse = textField
    }
    
    //-------------------------------------------------------------------------//
    // MARK: Tap gesture recognizer
    //-------------------------------------------------------------------------//
    
    func handleTap(recognizer: UITapGestureRecognizer)
    {
        if textFieldInUse != nil
        {
            textFieldInUse!.resignFirstResponder()
            textFieldInUse = nil
        }
    }
    
    //-------------------------------------------------------------------------//
    // MARK: Prompt user for successful payment
    //-------------------------------------------------------------------------//
    
    func promptUserForSuccessfulPayment(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Ok", style: .Default)
        {
            [unowned self](action: UIAlertAction!) -> Void in
            
            self.delegate!.clearShoppingCart()
            self.navigationController!.popToRootViewControllerAnimated(true)
        }
        
        alert.addAction(saveAction)
        
        dispatch_async(dispatch_get_main_queue())
        {
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //-------------------------------------------------------------------------//
    // MARK: Ajust for bigger screen
    //-------------------------------------------------------------------------//
    
    func adjustForBiggerScreen(multiplier: CGFloat)
    {
        for constraint in shopLogo.constraints
        {
            constraint.constant *= multiplier
        }
        
        for constraint in shopName.constraints
        {
            constraint.constant *= multiplier
        }
        
        for constraint in cardImage.constraints
        {
            constraint.constant *= multiplier
        }
        
        for constraint in cardLabel.constraints
        {
            constraint.constant *= multiplier
        }
        
        for constraint in expiryLabel.constraints
        {
            constraint.constant *= multiplier
        }
        
        for constraint in cvcLabel.constraints
        {
            constraint.constant *= multiplier
        }
        
        for constraint in cardNumberTxtField.constraints
        {
            constraint.constant *= multiplier
        }
        
        for constraint in expiryTxtField.constraints
        {
            constraint.constant *= multiplier
        }
        
        for constraint in cvcTxtField.constraints
        {
            constraint.constant *= multiplier
        }
        
        for constraint in cardBrandImgView.constraints
        {
            constraint.constant *= multiplier
        }
        
        headerHeightConstraint.constant *= multiplier
        dividerOneWidthConstraint.constant *= multiplier
        dividerTwoWidthConstraint.constant *= multiplier
        payButtonHeightConstraint.constant *= multiplier
        cancelButtonHeightConstraint.constant *= multiplier
        
        var fontSize = 25.0 * multiplier
        shopName.font =  UIFont(name: "HelveticaNeue", size: fontSize)
        
        fontSize = 17.0 * multiplier
        cardLabel.font =  UIFont(name: "HelveticaNeue-Bold", size: fontSize)
        expiryLabel.font =  UIFont(name: "HelveticaNeue-Bold", size: fontSize)
        cvcLabel.font =  UIFont(name: "HelveticaNeue-Bold", size: fontSize)
        cardNumberTxtField.font =  UIFont(name: "HelveticaNeue", size: fontSize)
        expiryTxtField.font =  UIFont(name: "HelveticaNeue", size: fontSize)
        cvcTxtField.font =  UIFont(name: "HelveticaNeue", size: fontSize)
        payButton.titleLabel!.font =  UIFont(name: "HelveticaNeue-Bold", size: fontSize)
        cancelButton.titleLabel!.font =  UIFont(name: "HelveticaNeue-Bold", size: fontSize)
    }
    
    //-------------------------------------------------------------------------//
    // MARK: Memory Warning
    //-------------------------------------------------------------------------//

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
