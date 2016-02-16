//
//  ShoppingCart_VC.swift
//  Demo Shop
//
//  Created by Nissi Vieira Miranda on 1/14/16.
//  Copyright © 2016 Nissi Vieira Miranda. All rights reserved.
//

import UIKit

protocol ShoppingCart_VC_Delegate: class
{
    func shoppingCartItemsListChanged(cartItems: [ShoppingCartItem])
}

class ShoppingCart_VC: UIViewController, UITableViewDataSource, UITableViewDelegate, PKPaymentAuthorizationViewControllerDelegate, ShoppingCartItemCellDelegate, CardPayment_VC_Delegate
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var valueToPayLabel: UILabel!
    @IBOutlet weak var freeShippingBlueRect: UIView!
    @IBOutlet weak var pacBlueRect: UIView!
    @IBOutlet weak var sedexBlueRect: UIView!
    
    @IBOutlet weak var shopLogo: UIImageView!
    @IBOutlet weak var shopName: UILabel!
    @IBOutlet weak var shoppingCartImage: UIImageView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var optionsSatckViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var valueToPayViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonsSatckViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var shippingOptionsStackView: UIStackView!
    @IBOutlet weak var checkoutButton: UIButton!
    @IBOutlet weak var keepShoppingButton: UIButton!
    
    weak var delegate: ShoppingCart_VC_Delegate?
    
    let backend = Backend()
    let shippingMethods = ShippingMethods()
    var multiplier: CGFloat = 1
    
    // Received from Products_VC:
    var shoppingCartItems: [ShoppingCartItem]!
    
    var valueToPay: CGFloat = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willEnterForeground",
            name: UIApplicationWillEnterForegroundNotification, object: nil)

        if Device.IS_IPHONE_6
        {
            multiplier = Constants.multiplier6
            adjustForBiggerScreen()
        }
        else if Device.IS_IPHONE_6_PLUS
        {
            multiplier = Constants.multiplier6plus
            adjustForBiggerScreen()
        }
        else
        {
            calculateTableViewHeightConstraint()
        }
        
        let totalPurchase = totalPurchaseItemsValue()
        let methods = shippingMethods.availableShippingMethods()
        let shippingValue = methods[0].amount
        valueToPay = totalPurchase + shippingValue
        let value: NSString = NSString(format: "%.02f", valueToPay)
        valueToPayLabel.text = "Total:  $\(value)"
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
        let isTopVC = navigationController!.topViewController!.isKindOfClass(ShoppingCart_VC)
        
        if isTopVC
        {
            if Auxiliar.sessionIsValid() == false
            {
                navigationController!.popToRootViewControllerAnimated(true)
            }
        }
    }
    
    //-------------------------------------------------------------------------//
    // MARK: IBActions
    //-------------------------------------------------------------------------//
    
    @IBAction func shippingMethodButtonTapped(sender: UIButton)
    {
        let idx = sender.tag - 10
        resetShippingMethod(idx)
    }
    
    var request: PKPaymentRequest!
    var paymentController: PKPaymentAuthorizationViewController!
    
    @IBAction func checkoutButtonTapped(sender: UIButton)
    {
        let shippingValue = valueToPay - totalPurchaseItemsValue()
        let idx = currentShippingMethodIndex(shippingValue)
        
        request = Stripe.paymentRequestWithMerchantIdentifier(Constants.appleMerchantId)!
        request.shippingMethods = shippingMethods.availablePKShippingMethods()
        request.paymentSummaryItems = summaryItemsForShippingMethod(request.shippingMethods![idx])
        
        let supportedPaymentNetworks = [PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]
        let supportsApplePay = PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(supportedPaymentNetworks)
        
        if supportsApplePay
        {
            showPaymentOptions()
        }
        else
        {
            performSegueWithIdentifier("ToCardPayment", sender: self)
        }
    }
    
    @IBAction func keepShoppingButtonTapped(sender: UIButton)
    {
        navigationController!.popViewControllerAnimated(true)
    }
    
    //-------------------------------------------------------------------------//
    // MARK: UITableViewDataSource
    //-------------------------------------------------------------------------//
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return shoppingCartItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("ShoppingCartItemCell",
                                forIndexPath: indexPath) as! ShoppingCartItemCell
        
        cell.delegate = self
        cell.setupCellWithItem(shoppingCartItems[indexPath.row])
        
        return cell
    }
    
    //-------------------------------------------------------------------------//
    // MARK: UITableViewDelegate
    //-------------------------------------------------------------------------//
    
    func tableView(tableView: UITableView,
        heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        var starterCellHeight: CGFloat = 110
        
        if Device.IS_IPHONE_6
        {
            starterCellHeight = 100
        }
        
        if Device.IS_IPHONE_6_PLUS
        {
            starterCellHeight = 90
        }
        
        return starterCellHeight * multiplier
    }
    
    //-------------------------------------------------------------------------//
    // MARK: ShoppingCartItemCellDelegate
    //-------------------------------------------------------------------------//
    
    func amountForItemChanged(clickedItemId: String, newAmount: Int)
    {
        var totalPurchase = totalPurchaseItemsValue()
        let shippingValue = valueToPay - totalPurchase
        
        let idx = findOutCartItemIndex(clickedItemId)
        
        let item = shoppingCartItems[idx]
            item.amount = newAmount
        
        shoppingCartItems[idx] = item
        
        totalPurchase = totalPurchaseItemsValue()
        valueToPay = totalPurchase + shippingValue
        let value: NSString = NSString(format: "%.02f", valueToPay)
        valueToPayLabel.text = "Total:  $\(value)"
        
        delegate!.shoppingCartItemsListChanged(shoppingCartItems)
    }
    
    func removeItem(clickedItemId: String)
    {
        var totalPurchase = totalPurchaseItemsValue()
        let shippingValue = valueToPay - totalPurchase
        
        let idx = findOutCartItemIndex(clickedItemId)
        
        shoppingCartItems.removeAtIndex(idx)
        
        delegate!.shoppingCartItemsListChanged(shoppingCartItems)
        
        if shoppingCartItems.count == 0
        {
            navigationController!.popViewControllerAnimated(true)
        }
        else
        {
            tableView.beginUpdates()
            let indexPaths = [NSIndexPath(forRow: idx, inSection: 0)]
            tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Left)
            tableView.endUpdates()
            
            totalPurchase = totalPurchaseItemsValue()
            valueToPay = totalPurchase + shippingValue
            let value: NSString = NSString(format: "%.02f", valueToPay)
            valueToPayLabel.text = "Total:  $\(value)"
            
            calculateTableViewHeightConstraint()
        }
    }
    
    //-------------------------------------------------------------------------//
    // MARK: CardPayment_VC_Delegate
    //-------------------------------------------------------------------------//
    
    func clearShoppingCart()
    {
        shoppingCartItems.removeAll()
        delegate!.shoppingCartItemsListChanged(shoppingCartItems)
    }
    
    //-------------------------------------------------------------------------//
    // MARK: PKPaymentAuthorizationViewControllerDelegate
    //-------------------------------------------------------------------------//
    
    // Executed when you click "Pay with Passcode":
    
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController,
        didAuthorizePayment payment: PKPayment, completion: (PKPaymentAuthorizationStatus) -> Void)
    {
        dismissViewControllerAnimated(true, completion: nil)
        
        Auxiliar.showLoadingHUDWithText("Processing payment, please wait...", forView: self.view)
        
        guard Reachability.connectedToNetwork() else
        {
            Auxiliar.hideLoadingHUDInView(self.view)
            Auxiliar.presentAlertControllerWithTitle("No Internet Connection",
                andMessage: "Make sure your device is connected to the internet.",
                forViewController: self)
            
            completion(PKPaymentAuthorizationStatus.Failure)
            return
        }
        
        STPAPIClient.sharedClient().createTokenWithPayment(payment) {
            
            [unowned self](token, error) -> Void in
            
            guard error == nil else
            {
                Auxiliar.hideLoadingHUDInView(self.view)
                Auxiliar.presentAlertControllerWithTitle("Failure",
                    andMessage: "Error while processing payment, please try again.", forViewController: self)
                
                print("Error = \(error)")
                
                completion(PKPaymentAuthorizationStatus.Failure)
                return
            }
            
            guard token != nil else
            {
                Auxiliar.hideLoadingHUDInView(self.view)
                Auxiliar.presentAlertControllerWithTitle("Failure",
                    andMessage: "Error while processing payment, please try again.", forViewController: self)
                
                completion(PKPaymentAuthorizationStatus.Failure)
                return
            }
            
            self.backend.token = token!
            self.backend.shoppingCartItems = self.shoppingCartItems
            self.backend.shippingMethod = self.getChoosenShippingMethod()
            self.backend.valueToPay = self.valueToPay
            
            self.backend.processPayment({
                
                [unowned self](status, message) in
                
                Auxiliar.hideLoadingHUDInView(self.view)
                
                if status == "Success"
                {
                    self.promptUserForSuccessfulPayment(status, message: message)
                    completion(PKPaymentAuthorizationStatus.Success)
                    return
                }
                
                Auxiliar.presentAlertControllerWithTitle(status,
                    andMessage: message, forViewController: self)
                
                completion(PKPaymentAuthorizationStatus.Failure)
            })
        }
    }
    
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController,
        didSelectShippingMethod shippingMethod: PKShippingMethod,
        completion: (PKPaymentAuthorizationStatus, [PKPaymentSummaryItem]) -> Void)
    {
        let idx = currentShippingMethodIndex(CGFloat(shippingMethod.amount))
        resetShippingMethod(idx)
        
        completion(PKPaymentAuthorizationStatus.Success, summaryItemsForShippingMethod(shippingMethod))
    }
    
    // Executed when you click "Cancel":
    
    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //-------------------------------------------------------------------------//
    // MARK: PKPaymentSummaryItem
    //-------------------------------------------------------------------------//
    
    func summaryItemsForShippingMethod(shippingMethod: PKShippingMethod) -> [PKPaymentSummaryItem]
    {
        var cartItems = gatherSummaryItems()
        let decimal = NSDecimalNumber(float: Float(valueToPay))
        let total = PKPaymentSummaryItem(label: "Total: ", amount: decimal)
        
        cartItems.append(shippingMethod)
        cartItems.append(total)
        
        return cartItems
    }
    
    func gatherSummaryItems() -> [PKPaymentSummaryItem]
    {
        var items = [PKPaymentSummaryItem]()
        
        for item in shoppingCartItems
        {
            let name = item.itemForSale.itemName
            let unityPrice = item.itemForSale.itemPrice
            let totalPrice = Float(unityPrice * CGFloat(item.amount))
            let decimal = NSDecimalNumber(float: totalPrice)
            items.append(PKPaymentSummaryItem(label: "\(item.amount) x \(name)", amount: decimal))
        }
        
        return items
    }
    
    //-------------------------------------------------------------------------//
    // MARK: Show payment options
    //-------------------------------------------------------------------------//
    
    func showPaymentOptions()
    {
        let paymentOptions = UIAlertController(title: "Payment Options",
                                             message: "I'll pay using:", preferredStyle: .ActionSheet)
        
        let applePay = UIAlertAction(title: "Apple Pay", style: .Default, handler:
            {
                [unowned self](alert: UIAlertAction!) -> Void in
                
                self.paymentController = PKPaymentAuthorizationViewController(paymentRequest: self.request)
                self.paymentController.delegate = self
                self.presentViewController(self.paymentController, animated: true, completion: nil)
            })
        
        let creditCard = UIAlertAction(title: "Credit Card", style: .Default, handler:
            {
                [unowned self](alert: UIAlertAction!) -> Void in
                
                self.performSegueWithIdentifier("ToCardPayment", sender: self)
            })
        
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        paymentOptions.addAction(applePay)
        paymentOptions.addAction(creditCard)
        paymentOptions.addAction(cancel)
        
        presentViewController(paymentOptions, animated: true, completion: nil)
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
            
            self.shoppingCartItems.removeAll()
            self.delegate!.shoppingCartItemsListChanged(self.shoppingCartItems)
            self.navigationController!.popToRootViewControllerAnimated(true)
        }
        
        alert.addAction(saveAction)
        
        dispatch_async(dispatch_get_main_queue())
        {
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //-------------------------------------------------------------------------//
    // MARK: Auxiliar functions
    //-------------------------------------------------------------------------//
    
    func findOutCartItemIndex(clickedItemId: String) -> Int
    {
        var idx = 0
        
        for (index, item) in shoppingCartItems.enumerate()
        {
            if item.itemForSale.id == clickedItemId
            {
                idx = index
                break
            }
        }
        
        return idx
    }
    
    func currentShippingMethodIndex(shippingValue: CGFloat) -> Int
    {
        let methods = shippingMethods.availableShippingMethods()
        var idx = 0
        
        for (index, method) in methods.enumerate()
        {
            if method.amount == shippingValue
            {
                idx = index
                break
            }
        }
        
        return idx
    }
    
    func resetShippingMethod(idx: Int)
    {
        let totalPurchase = totalPurchaseItemsValue()
        let methods = shippingMethods.availableShippingMethods()
        let method = methods[idx]
        
        let shippingValue = method.amount
        valueToPay = totalPurchase + shippingValue
        let value: NSString = NSString(format: "%.02f", valueToPay)
        valueToPayLabel.text = "Total:  $\(value)"
        
        freeShippingBlueRect.alpha = 0.4
        pacBlueRect.alpha = 0.4
        sedexBlueRect.alpha = 0.4
        
        switch idx
        {
            case 0:
                freeShippingBlueRect.alpha = 1
            case 1:
                pacBlueRect.alpha = 1
            case 2:
                sedexBlueRect.alpha = 1
            default:
                print("Unknown")
        }
    }
    
    func totalPurchaseItemsValue() -> CGFloat
    {
        var totalValue: CGFloat = 0
        
        for item in shoppingCartItems
        {
            let unityPrice = item.itemForSale.itemPrice
            let total = unityPrice * CGFloat(item.amount)
            totalValue += total
        }
        
        return totalValue
    }
    
    func getChoosenShippingMethod() -> ShippingMethod
    {
        let methods = shippingMethods.availableShippingMethods()
        var idx = 0
        
        if pacBlueRect.alpha == 1
        {
            idx = 1
        }
        else if sedexBlueRect.alpha == 1
        {
            idx = 2
        }
        
        return methods[idx]
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
        
        for constraint in shoppingCartImage.constraints
        {
            constraint.constant *= multiplier
        }
        
        for subview in shippingOptionsStackView.subviews
        {
            for (index, subV) in subview.subviews.enumerate()
            {
                if index > 0
                {
                    for constraint in subV.constraints
                    {
                        constraint.constant *= multiplier
                    }
                    
                    if index == 1
                    {
                        let fontSize = 14 * multiplier
                        let label = subV as! UILabel
                            label.font =  UIFont(name: "HelveticaNeue", size: fontSize)
                    }
                    
                    if index == 2
                    {
                        let fontSize = 12 * multiplier
                        let label = subV as! UILabel
                            label.font =  UIFont(name: "HelveticaNeue", size: fontSize)
                    }
                    
                    if index == 3
                    {
                        let fontSize = 15 * multiplier
                        let label = subV as! UILabel
                            label.font =  UIFont(name: "HelveticaNeue-Bold", size: fontSize)
                    }
                }
            }
        }
        
        for constraint in valueToPayLabel.constraints
        {
            constraint.constant *= multiplier
        }
        
        headerHeightConstraint.constant *= multiplier
        optionsSatckViewHeightConstraint.constant *= multiplier
        valueToPayViewHeightConstraint.constant *= multiplier
        buttonsSatckViewHeightConstraint.constant *= multiplier
        
        calculateTableViewHeightConstraint()
        
        var fontSize = 25.0 * multiplier
        shopName.font =  UIFont(name: "HelveticaNeue", size: fontSize)
        
        fontSize = 17.0 * multiplier
        checkoutButton.titleLabel!.font =  UIFont(name: "HelveticaNeue-Bold", size: fontSize)
        keepShoppingButton.titleLabel!.font =  UIFont(name: "HelveticaNeue-Bold", size: fontSize)
        
        fontSize = 15.0 * multiplier
        valueToPayLabel.font =  UIFont(name: "HelveticaNeue-Bold", size: fontSize)
    }
    
    //-------------------------------------------------------------------------//
    // MARK: Calculate TableView Height Constraint
    //-------------------------------------------------------------------------//
    
    func calculateTableViewHeightConstraint()
    {
        let space = self.view.frame.size.height - (headerHeightConstraint.constant +
                                         optionsSatckViewHeightConstraint.constant +
                                           valueToPayViewHeightConstraint.constant +
                                         buttonsSatckViewHeightConstraint.constant)
        
        var starterCellHeight: CGFloat = 110
        
        if Device.IS_IPHONE_6
        {
            starterCellHeight = 100
        }
        
        if Device.IS_IPHONE_6_PLUS
        {
            starterCellHeight = 90
        }
        
        let cellsTotalHeight = (starterCellHeight * multiplier) * CGFloat(shoppingCartItems.count)
        
        let tvHeight = cellsTotalHeight < space ? cellsTotalHeight : space
        
        tableViewHeightConstraint.constant = tvHeight
    }
    
    //-------------------------------------------------------------------------//
    // MARK: Navigation
    //-------------------------------------------------------------------------//
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        let vc = segue.destinationViewController as! CardPayment_VC
            vc.shoppingCartItems = shoppingCartItems
            vc.shippingMethod = getChoosenShippingMethod()
            vc.valueToPay = valueToPay
            vc.delegate = self
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
