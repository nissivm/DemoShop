//
//  CardPayment_VC.swift
//  Demo Shop
//
//  Created by Nissi Vieira Miranda on 1/6/16.
//  Copyright © 2016 Nissi Vieira Miranda. All rights reserved.
//

// Classes to use: STPCardValidator / STPAPIClient

import UIKit

class CardPayment_VC: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var cardNumberTxtField: UITextField!
    @IBOutlet weak var cardBrandImgView: UIImageView!
    @IBOutlet weak var expiryTxtField: UITextField!
    @IBOutlet weak var cvcTxtField: UITextField!
    @IBOutlet weak var payButton: UIButton!
    
    let card = Card()
    let auxiliar = Auxiliar()
    
    var valueToPay: CGFloat = 107.00
    var parseUserID = "1234XOXO"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        cardNumberTxtField.addTarget(self, action: "didChangeText:", forControlEvents: .EditingChanged)
        expiryTxtField.addTarget(self, action: "didChangeText:", forControlEvents: .EditingChanged)
        cvcTxtField.addTarget(self, action: "didChangeText:", forControlEvents: .EditingChanged)
        
        expiryTxtField.enabled = false
        cvcTxtField.enabled = false
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
            
            STPAPIClient.sharedClient().createTokenWithCard(cardParam, completion: {
                
                [unowned self](token, error) -> Void in
                
                guard (error == nil) && (token != nil) else
                {
                    self.auxiliar.hideLoadingHUDInView(self.view)
                    self.auxiliar.presentAlertControllerWithTitle("Failure",
                        andMessage: "Error while processing payment, please try again.", forViewController: self)
                    return
                }
                
                self.createBackendChargeWithToken(token!) {
                    
                    [unowned self](status, message) in
                    
                    self.auxiliar.hideLoadingHUDInView(self.view)
                    
                    if status == "Success"
                    {
                        self.promptUserForSuccessfulPayment(status, message: message)
                    }
                    else // Failure
                    {
                        self.auxiliar.presentAlertControllerWithTitle(status,
                            andMessage: message, forViewController: self)
                    }
                }
            })
        }
    }
    
    //-------------------------------------------------------------------------//
    // MARK: Create backend charge with token
    //-------------------------------------------------------------------------//
    
    func createBackendChargeWithToken(token: STPToken, completion:((status : String, message : String) -> Void))
    {
        let url = NSURL(string: "http://localhost/donate/payment.php")!
        
        let params = ["stripeToken": token.tokenId, "amount": valueToPay,
                        "currency" : "usd", "description" : parseUserID]
        
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
            
            (data, response, error) -> Void in
            
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
            
            var jSon: [String : String]!
            
            do
            {
                jSon = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as! [String : String]
            }
            catch
            {
                completion(status: "Failure", message: errorMessage)
                return
            }
            
            let status = jSon["status"]!
            let message = jSon["message"]!
            
            completion(status: status, message: message)
        }
        
        task.resume()
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
            }
            else if txtFieldTag == 12 // CVC
            {
                Card.cvc = textField.text!
                textField.text = card.formatCVC()
            }
            
            payButton.enabled = false
            
            if card.cardNumberIsValid() && card.expirationDateIsValid() && card.cvcIsValid()
            {
                payButton.enabled = true
            }
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
            //self.navigationController!.popViewControllerAnimated(true)
            print("Ok button tapped!")
        }
        
        alert.addAction(saveAction)
        
        presentViewController(alert, animated: true, completion: nil)
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
