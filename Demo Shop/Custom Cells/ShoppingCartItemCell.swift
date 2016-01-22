//
//  ShoppingCartItemCell.swift
//  Demo Shop
//
//  Created by Nissi Vieira Miranda on 1/17/16.
//  Copyright © 2016 Nissi Vieira Miranda. All rights reserved.
//

import UIKit

protocol ShoppingCartItemCellDelegate: class
{
    func amountForItemChanged(clickedItemId: String, newAmount: Int)
    func removeItem(clickedItemId: String)
}

class ShoppingCartItemCell: UITableViewCell
{
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var totalForItemLabel: UILabel!
    @IBOutlet weak var removeItemButton: UIButton!
    
    @IBOutlet weak var itemImageHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: ShoppingCartItemCellDelegate?
    private weak var itemForSale: ItemForSale!
    private var amount = 0
    
    func setupCellWithItem(shoppingCartItem: ShoppingCartItem)
    {
        itemForSale = shoppingCartItem.itemForSale
        
        itemImage.image = itemForSale.itemImage
        itemName.text = itemForSale.itemName
        itemPrice.text = "$\(itemForSale.itemPrice)0"
        
        amount = shoppingCartItem.amount
        
        if amount == 1
        {
            minusButton.enabled = false
        }
        else
        {
            minusButton.enabled = true
        }
        
        amountLabel.text = "\(amount)"
        
        setTotalForItem()
        
        if Device.IS_IPHONE_6_PLUS
        {
            adjustSizesForBiggerScreen(Constants.multiplier6plus)
        }
        else if Device.IS_IPHONE_6
        {
            adjustSizesForBiggerScreen(Constants.multiplier6)
        }
    }
    
    private func setTotalForItem()
    {
        let total = itemForSale.itemPrice * CGFloat(amount)
        let value: NSString = NSString(format: "%.02f", total)
        totalForItemLabel.text = "$\(value)"
    }
    
    private func adjustSizesForBiggerScreen(multiplier: CGFloat)
    {
        if itemImageHeightConstraint == 50
        {
            for constraint in itemImage.constraints
            {
                constraint.constant *= multiplier
            }
            
            for constraint in itemName.constraints
            {
                constraint.constant *= multiplier
            }
            
            for constraint in itemPrice.constraints
            {
                constraint.constant *= multiplier
            }
            
            for constraint in minusButton.constraints
            {
                constraint.constant *= multiplier
            }
            
            for constraint in amountLabel.constraints
            {
                constraint.constant *= multiplier
            }
            
            for constraint in plusButton.constraints
            {
                constraint.constant *= multiplier
            }
            
            for constraint in totalForItemLabel.constraints
            {
                constraint.constant *= multiplier
            }
            
            for constraint in removeItemButton.constraints
            {
                constraint.constant *= multiplier
            }
            
            var fontSize = 17.0 * multiplier
            itemName.font =  UIFont(name: "HelveticaNeue-Bold", size: fontSize)
            amountLabel.font =  UIFont(name: "HelveticaNeue-Bold", size: fontSize)
            
            fontSize = 15.0 * multiplier
            totalForItemLabel.font =  UIFont(name: "HelveticaNeue-Bold", size: fontSize)
            removeItemButton.titleLabel!.font =  UIFont(name: "HelveticaNeue-Bold", size: fontSize)
            
            fontSize = 12.0 * multiplier
            itemPrice.font =  UIFont(name: "HelveticaNeue", size: fontSize)
        }
    }
    
    @IBAction func minusButtonTapped(sender: UIButton)
    {
        if minusButton.enabled
        {
            amount--
            amountLabel.text = "\(amount)"
            setTotalForItem()
            delegate!.amountForItemChanged(itemForSale.id, newAmount: amount)
            
            if amount == 1
            {
                minusButton.enabled = false
            }
        }
    }
    
    @IBAction func plusButtonTapped(sender: UIButton)
    {
        amount++
        minusButton.enabled = true
        amountLabel.text = "\(amount)"
        setTotalForItem()
        delegate!.amountForItemChanged(itemForSale.id, newAmount: amount)
    }
    
    @IBAction func removeItemButtonTapped(sender: UIButton)
    {
        delegate!.removeItem(itemForSale.id)
    }
}
