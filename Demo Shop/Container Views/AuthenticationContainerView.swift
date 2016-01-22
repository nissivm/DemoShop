//
//  AuthenticationContainerView.swift
//  Demo Shop
//
//  Created by Nissi Vieira Miranda on 1/19/16.
//  Copyright © 2016 Nissi Vieira Miranda. All rights reserved.
//

import UIKit

class AuthenticationContainerView: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate
{
    @IBOutlet weak var tapView: UIView!
    @IBOutlet weak var nameTxtField: UITextField!
    @IBOutlet weak var usernameTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var emailTxtField: UITextField!
    
    @IBOutlet weak var shopLogo: UIImageView!
    @IBOutlet weak var shopName: UILabel!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dividerOneTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var dividerTwoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var dividerThreeTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var containerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    
    var user : PFUser?
    var tappedTextField : UITextField?
    let auxiliar = Auxiliar()
    var multiplier: CGFloat = 1
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action:Selector("handleTap:"))
            tapRecognizer.delegate = self
        tapView.addGestureRecognizer(tapRecognizer)

        if Device.IS_IPHONE_6
        {
            containerHeightConstraint.constant = self.view.frame.size.height
            multiplier = Constants.multiplier6
            adjustForBiggerScreen()
        }
        else if Device.IS_IPHONE_6_PLUS
        {
            containerHeightConstraint.constant = self.view.frame.size.height
            multiplier = Constants.multiplier6plus
            adjustForBiggerScreen()
        }
    }
    
    //-------------------------------------------------------------------------//
    // MARK: Parse Sign Up
    //-------------------------------------------------------------------------//
    
    @IBAction func signUpButtonTapped(sender: UIButton)
    {
        if Reachability.connectedToNetwork()
        {
            let name = nameTxtField.text!
            let username = usernameTxtField.text!
            let password = passwordTxtField.text!
            let email = emailTxtField.text!
            
            if name.characters.count > 0 &&
               username.characters.count > 0 &&
               password.characters.count > 0 &&
               email.characters.count > 0
            {
                auxiliar.showLoadingHUDWithText("Signing up...", forView: self.view)
                signUpWithParse(name, username: username, password: password, email: email)
            }
            else
            {
                auxiliar.presentAlertControllerWithTitle("Error",
                    andMessage: "Please fill in all fields", forViewController: self)
            }
        }
        else
        {
            auxiliar.presentAlertControllerWithTitle("No Internet Connection",
                andMessage: "Make sure your device is connected to the internet.",
                forViewController: self)
        }
    }
    
    func signUpWithParse(name: String, username: String, password: String, email: String)
    {
        let user = PFUser()
            user.setObject(name, forKey: "name")
            user.username = username
            user.password = password
            user.email = email
        
        user.signUpInBackgroundWithBlock
            {
                [unowned self](succeeded, error) -> Void in
                
                self.auxiliar.hideLoadingHUDInView(self.view)
                
                guard error == nil else
                {
                    print("Error signing up in Parse")
                    print("Error code: \(error!.code)")
                    
                    var msg = ""
                    if error!.code == 202 // Username taken
                    {
                        let errorString = error!.userInfo["error"] as! String
                        msg = "Sign up error: \(errorString)"
                    }
                    else if error!.code == 203 // Email taken
                    {
                        let errorString = error!.userInfo["error"] as! String
                        msg = "Sign up error: \(errorString)"
                    }
                    else
                    {
                        msg = "An error occurred while signing up, please try again later."
                    }
                    
                    self.auxiliar.presentAlertControllerWithTitle("Error", andMessage: msg,
                        forViewController: self)
                    return
                }
                
                self.nameTxtField.text = ""
                self.usernameTxtField.text = ""
                self.passwordTxtField.text = ""
                self.emailTxtField.text = ""
                
                NSNotificationCenter.defaultCenter().postNotificationName("SessionStarted", object: nil)
            }
    }
    
    //-------------------------------------------------------------------------//
    // MARK: Parse Sign In
    //-------------------------------------------------------------------------//
    
    @IBAction func signInButtonTapped(sender: UIButton)
    {
        if Reachability.connectedToNetwork()
        {
            let username = usernameTxtField.text!
            let password = passwordTxtField.text!
            
            if username.characters.count > 0 &&
               password.characters.count > 0
            {
                auxiliar.showLoadingHUDWithText("Signing in...", forView: self.view)
                signInWithParse(username, password: password)
            }
            else
            {
                auxiliar.presentAlertControllerWithTitle("Error",
                    andMessage: "Please insert username and password", forViewController: self)
            }
        }
        else
        {
            auxiliar.presentAlertControllerWithTitle("No Internet Connection",
                andMessage: "Make sure your device is connected to the internet.",
                forViewController: self)
        }
    }
    
    func signInWithParse(username: String, password: String)
    {
        PFUser.logInWithUsernameInBackground(username, password: password)
            {
                [unowned self](user, error) -> Void in
                
                self.auxiliar.hideLoadingHUDInView(self.view)
                
                guard error == nil else
                {
                    print("Error logging in in Parse")
                    print("Error code: \(error!.code)")
                    
                    var msg = ""
                    if error!.code == 101
                    {
                        msg = "Wrong username or password"
                    }
                    else
                    {
                        msg = "An error occurred while logging in, please try again later."
                    }
                    
                    self.auxiliar.presentAlertControllerWithTitle("Error", andMessage: msg,
                        forViewController: self)
                    return
                }
                
                self.nameTxtField.text = ""
                self.usernameTxtField.text = ""
                self.passwordTxtField.text = ""
                self.emailTxtField.text = ""
                
                NSNotificationCenter.defaultCenter().postNotificationName("SessionStarted", object: nil)
            }
    }
    
    //-------------------------------------------------------------------------//
    // MARK: UITextFieldDelegate
    //-------------------------------------------------------------------------//
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        tappedTextField = textField
        
        let textFieldY = tappedTextField!.frame.origin.y
        let textFieldHeight = tappedTextField!.frame.size.height
        let total = textFieldY + textFieldHeight
        
        if total > (self.view.frame.size.height/2)
        {
            let difference = total - (self.view.frame.size.height/2)
            var newConstraint = containerTopConstraint.constant - difference
            
            if textField.tag == 13 // Email
            {
                newConstraint -= 30
            }
            
            animateConstraint(containerTopConstraint, toValue: newConstraint)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        tappedTextField!.resignFirstResponder()
        tappedTextField = nil
        animateConstraint(containerTopConstraint, toValue: 0)
        
        return true
    }
    
    //-------------------------------------------------------------------------//
    // MARK: Tap gesture recognizer
    //-------------------------------------------------------------------------//
    
    func handleTap(recognizer : UITapGestureRecognizer)
    {
        if tappedTextField != nil
        {
            tappedTextField!.resignFirstResponder()
            tappedTextField = nil
            animateConstraint(containerTopConstraint, toValue: 0)
        }
    }
    
    //-------------------------------------------------------------------------//
    // MARK: Animations
    //-------------------------------------------------------------------------//
    
    func animateConstraint(constraint : NSLayoutConstraint, toValue value : CGFloat)
    {
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseOut,
            animations:
            {
                constraint.constant = value
                
                self.view.layoutIfNeeded()
            },
            completion:
            {
                (finished: Bool) in
            })
    }
    
    //-------------------------------------------------------------------------//
    // MARK: Ajust for bigger screen
    //-------------------------------------------------------------------------//
    
    func adjustForBiggerScreen()
    {
        for constraint in shopLogo.constraints
        {
            constraint.constant *= multiplier
        }
        
        for constraint in shopName.constraints
        {
            constraint.constant *= multiplier
        }
        
        for constraint in nameTxtField.constraints
        {
            constraint.constant *= multiplier
        }
        
        for constraint in usernameTxtField.constraints
        {
            constraint.constant *= multiplier
        }
        
        for constraint in passwordTxtField.constraints
        {
            constraint.constant *= multiplier
        }
        
        for constraint in emailTxtField.constraints
        {
            constraint.constant *= multiplier
        }
        
        for constraint in signUpButton.constraints
        {
            constraint.constant *= multiplier
        }
        
        for constraint in signInButton.constraints
        {
            constraint.constant *= multiplier
        }
        
        headerHeightConstraint.constant *= multiplier
        dividerOneTopConstraint.constant *= multiplier
        dividerTwoTopConstraint.constant *= multiplier
        dividerThreeTopConstraint.constant *= multiplier
        
        var fontSize = 25.0 * multiplier
        shopName.font =  UIFont(name: "HelveticaNeue", size: fontSize)
        
        fontSize = 17.0 * multiplier
        nameTxtField.font =  UIFont(name: "HelveticaNeue", size: fontSize)
        usernameTxtField.font =  UIFont(name: "HelveticaNeue", size: fontSize)
        passwordTxtField.font =  UIFont(name: "HelveticaNeue", size: fontSize)
        emailTxtField.font =  UIFont(name: "HelveticaNeue", size: fontSize)
        signUpButton.titleLabel!.font =  UIFont(name: "HelveticaNeue-Bold", size: fontSize)
        signInButton.titleLabel!.font =  UIFont(name: "HelveticaNeue-Bold", size: fontSize)
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
