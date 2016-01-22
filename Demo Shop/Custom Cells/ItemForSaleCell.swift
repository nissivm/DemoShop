//
//  ItemForSaleCell.swift
//  Demo Shop
//
//  Created by Nissi Vieira Miranda on 1/16/16.
//  Copyright © 2016 Nissi Vieira Miranda. All rights reserved.
//

import UIKit

protocol ItemForSaleCellDelegate: class
{
    func addThisItemToShoppingCart(clickedItemIndex: Int)
}

class ItemForSaleCell: UICollectionViewCell
{
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var shoppingCartButton: UIButton!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    
    @IBOutlet weak var shoppingCartButtonHeightConstraint: NSLayoutConstraint!
    
    var index : Int = 0
    weak var delegate: ItemForSaleCellDelegate?
    
    func setupCellWithItem(itemForSale: ItemForSale)
    {
        itemImage.image = itemForSale.itemImage
        itemName.text = itemForSale.itemName
        itemPrice.text = "$\(itemForSale.itemPrice)0"
        
        if Device.IS_IPHONE_6_PLUS
        {
            adjustSizesForBiggerScreen(Constants.multiplier6plus)
        }
        else if Device.IS_IPHONE_6
        {
            adjustSizesForBiggerScreen(Constants.multiplier6)
        }
    }
    
    private func adjustSizesForBiggerScreen(multiplier: CGFloat)
    {
        if shoppingCartButtonHeightConstraint.constant == 40
        {
            for constraint in itemImage.constraints
            {
                constraint.constant *= multiplier
            }
            
            for constraint in shoppingCartButton.constraints
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
            
            var fontSize = 17.0 * multiplier
            itemName.font =  UIFont(name: "HelveticaNeue-Bold", size: fontSize)
            
            fontSize = 14.0 * multiplier
            itemPrice.font =  UIFont(name: "HelveticaNeue", size: fontSize)
            
            shoppingCartButton.imageEdgeInsets = UIEdgeInsetsMake(9 * multiplier, 9 * multiplier,
                                                                  9 * multiplier, 9 * multiplier)
        }
    }
    
    @IBAction func addToShoppingCart(sender: UIButton)
    {
        delegate!.addThisItemToShoppingCart(index)
    }
}
