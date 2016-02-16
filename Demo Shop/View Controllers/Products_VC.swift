//
//  Products_VC.swift
//  Demo Shop
//
//  Created by Nissi Vieira Miranda on 1/14/16.
//  Copyright © 2016 Nissi Vieira Miranda. All rights reserved.
//

import UIKit

class Products_VC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, ItemForSaleCellDelegate, ShoppingCart_VC_Delegate
{
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var shoppingCartButton: UIButton!
    @IBOutlet weak var authenticationContainerView: UIView!
    
    @IBOutlet weak var shopLogo: UIImageView!
    @IBOutlet weak var shopName: UILabel!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var buttonsStackViewHeightConstraint: NSLayoutConstraint!
    
    var itemsForSale = [ItemForSale]()
    var shoppingCartItems = [ShoppingCartItem]()
    let backend = Backend()
    var multiplier: CGFloat = 1
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "willEnterForeground",
            name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sessionStarted",
            name: "SessionStarted", object: nil)

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
        
        if Auxiliar.sessionIsValid()
        {
            dispatch_async(dispatch_get_main_queue())
            {
                self.authenticationContainerView.hidden = true
                self.backend.offset = 1
                self.retrieveProducts()
            }
        }
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
            authenticationContainerView.hidden = false
        }
    }
    
    func sessionStarted()
    {
        dispatch_async(dispatch_get_main_queue())
        {
            self.authenticationContainerView.hidden = true
            
            if self.itemsForSale.count == 0
            {
                self.backend.offset = 1
                self.retrieveProducts()
            }
        }
    }
    
    //-------------------------------------------------------------------------//
    // MARK: IBActions
    //-------------------------------------------------------------------------//
    
    @IBAction func shoppingCartButtonTapped(sender: UIButton)
    {
        if shoppingCartButton.enabled
        {
            performSegueWithIdentifier("ToShoppingCart", sender: self)
        }
    }
    
    @IBAction func signOutButtonTapped(sender: UIButton)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        var currentUser = defaults.dictionaryForKey("currentUser")!
            currentUser["sessionStatus"] = "invalid"
        
        defaults.setObject(currentUser, forKey: "currentUser")
        defaults.synchronize()
        
        authenticationContainerView.hidden = false
    }
    
    //-------------------------------------------------------------------------//
    // MARK: Retrieve products
    //-------------------------------------------------------------------------//
    
    func retrieveProducts()
    {
        Auxiliar.showLoadingHUDWithText("Retrieving products...", forView: self.view)
        
        backend.fetchItemsForSale({
            
            [unowned self](status, returnData) -> Void in
            
            if let returnData = returnData
            {
                var items = [ItemForSale]()
                
                for dic in returnData
                {
                    let id = dic["id"] as! Int
                    let itemName = dic["item_name"] as! String
                    let itemPriceStr = dic["item_price"] as! String
                    let itemPriceNumber = NSNumberFormatter().numberFromString(itemPriceStr)!
                    let itemPrice = CGFloat(itemPriceNumber)
                    let imageAddr = dic["image_addr"] as! String
                    let imageURL : NSURL = NSURL(string: imageAddr)!
                    
                    let item = ItemForSale()
                        item.id = "\(id)"
                        item.itemName = itemName
                        item.itemPrice = itemPrice
                        item.itemImage = UIImage(data: NSData(contentsOfURL: imageURL)!)
                    
                    items.append(item)
                }
                
                dispatch_async(dispatch_get_main_queue())
                {
                    self.incorporateNewSearchItems(items)
                }
            }
            else if status == "No results"
            {
                self.hasMoreToShow = false
            }
        })
    }
    
    //-------------------------------------------------------------------------//
    // MARK: UIScrollViewDelegate
    //-------------------------------------------------------------------------//
    
    var searchingMore = false
    var hasMoreToShow = true
    
    func scrollViewDidScroll(scrollView: UIScrollView)
    {
        if collectionView.contentOffset.y >= (collectionView.contentSize.height - collectionView.bounds.size.height)
        {
            if (searchingMore == false) && hasMoreToShow
            {
                searchingMore = true
                backend.offset += 6
                retrieveProducts()
            }
        }
    }
    
    //-------------------------------------------------------------------------//
    // MARK: Incorporate new search items
    //-------------------------------------------------------------------------//
    
    func incorporateNewSearchItems(items : [ItemForSale])
    {
        var indexPath : NSIndexPath = NSIndexPath(forItem: 0, inSection: 0)
        var counter = collectionView.numberOfItemsInSection(0)
        var newItems = [NSIndexPath]()
        
        for item in items
        {
            indexPath = NSIndexPath(forItem: counter, inSection: 0)
            newItems.append(indexPath)
            
            itemsForSale.append(item)
            
            counter++
        }
        
        collectionView.performBatchUpdates({
            
                [unowned self]() -> Void in
            
                self.collectionView.insertItemsAtIndexPaths(newItems)
            }){
                completed in
                
                Auxiliar.hideLoadingHUDInView(self.view)
            }
    }
    
    //-------------------------------------------------------------------------//
    // MARK: UICollectionViewDataSource
    //-------------------------------------------------------------------------//
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return itemsForSale.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ItemForSaleCell",
                                                            forIndexPath: indexPath) as! ItemForSaleCell
        
        cell.index = indexPath.item
        cell.delegate = self
        cell.setupCellWithItem(itemsForSale[indexPath.item])
        
        return cell
    }
    
    //-------------------------------------------------------------------------//
    // MARK: UICollectionViewDelegateFlowLayout
    //-------------------------------------------------------------------------//
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        let cellWidth = self.view.frame.size.width/2
        return CGSizeMake(cellWidth, 190 * multiplier)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat
    {
        return 0
    }
    
    //-------------------------------------------------------------------------//
    // MARK: ItemForSaleCellDelegate
    //-------------------------------------------------------------------------//
    
    func addThisItemToShoppingCart(clickedItemIndex: Int)
    {
        let item = itemsForSale[clickedItemIndex]
        var found = false
        var message = "\(item.itemName) was added to shopping cart."
        
        if shoppingCartItems.count > 0
        {
            for (index, cartItem) in shoppingCartItems.enumerate()
            {
                if cartItem.itemForSale.id == item.id
                {
                    found = true
                    cartItem.amount++
                    shoppingCartItems[index] = cartItem
                    
                    let lastLetterIdx = item.itemName.characters.count - 1
                    let lastLetter = NSString(string: item.itemName).substringFromIndex(lastLetterIdx)
                    
                    if lastLetter != "s"
                    {
                        message = "You have \(cartItem.amount) \(item.itemName)s in your shopping cart."
                    }
                    else
                    {
                        message = "You have \(cartItem.amount) \(item.itemName) in your shopping cart."
                    }
                    
                    break
                }
            }
        }
        else
        {
            shoppingCartButton.enabled = true
        }
        
        if found == false
        {
            let cartItem = ShoppingCartItem()
                cartItem.itemForSale = item
            shoppingCartItems.append(cartItem)
        }
        
        Auxiliar.presentAlertControllerWithTitle("Item added!",
            andMessage: message, forViewController: self)
    }
    
    //-------------------------------------------------------------------------//
    // MARK: ShoppingCart_VC_Delegate
    //-------------------------------------------------------------------------//
    
    func shoppingCartItemsListChanged(cartItems: [ShoppingCartItem])
    {
        shoppingCartItems = cartItems
        
        if shoppingCartItems.count == 0
        {
            shoppingCartButton.enabled = false
        }
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
        
        headerHeightConstraint.constant *= multiplier
        buttonsStackViewHeightConstraint.constant *= multiplier
        
        var fontSize = 25.0 * multiplier
        shopName.font =  UIFont(name: "HelveticaNeue", size: fontSize)
        
        fontSize = 17.0 * multiplier
        signOutButton.titleLabel!.font =  UIFont(name: "HelveticaNeue-Bold", size: fontSize)
        
        shoppingCartButton.imageEdgeInsets = UIEdgeInsetsMake(10 * multiplier, 64 * multiplier,
                                                              10 * multiplier, 64 * multiplier)
    }
    
    //-------------------------------------------------------------------------//
    // MARK: Navigation
    //-------------------------------------------------------------------------//
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if (segue.identifier != nil) && (segue.identifier == "ToShoppingCart")
        {
            let vc = segue.destinationViewController as! ShoppingCart_VC
                vc.shoppingCartItems = shoppingCartItems
                vc.delegate = self
        }
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
