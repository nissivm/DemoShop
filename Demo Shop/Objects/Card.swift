//
//  Card.swift
//  Demo Shop
//
//  Created by Nissi Vieira Miranda on 1/11/16.
//  Copyright © 2016 Nissi Vieira Miranda. All rights reserved.
//

import Foundation

class Card
{
    static var cardNumber = ""
    static var expirationDate = ""
    static var cvc = ""
    
    private var cardBrand: STPCardBrand?
    
    //-------------------------------------------------------------------------//
    // MARK: Card brand
    //-------------------------------------------------------------------------//
    
    func retrieveCardBrand()
    {
        let sanitizedNumber = STPCardValidator.sanitizedNumericStringForString(Card.cardNumber)
        cardBrand = STPCardValidator.brandForNumber(sanitizedNumber)
    }
    
    func cardBrandName() -> String
    {
        retrieveCardBrand()
        var imageName = ""
        
        switch cardBrand!
        {
            case .Visa:
                imageName = "visa"
                break
            case .MasterCard:
                imageName = "mastercard"
                break
            case .DinersClub:
                imageName = "diners"
                break
            case .Amex:
                imageName = "amex"
                break
            case .Discover:
                imageName = "discover"
                break
            case .JCB:
                imageName = "jcb"
                break
            case .Unknown:
                imageName = ""
                break
        }
        
        return imageName
    }
    
    func cardImageForBrandName(brandName: String) -> UIImage?
    {
        if brandName.characters.count > 0
        {
            let path = NSBundle.mainBundle().pathForResource(brandName, ofType: "png")
            return UIImage(contentsOfFile: path!)
        }
        else
        {
            return nil
        }
    }
    
    //-------------------------------------------------------------------------//
    // MARK: Format
    //-------------------------------------------------------------------------//
    
    func formatCardNumber() -> String
    {
        var cardNumber = Card.cardNumber
        let cardNumberNSString = NSString(string: cardNumber)
        let cardNumberLength = cardNumberNSString.length
        
        retrieveCardBrand()
        
        if (cardNumberLength == 5) || ((cardBrand! == .Amex) && (cardNumberLength == 12)) ||
           ((cardBrand! != .Amex) && (cardNumberLength == 10)) ||
           ((cardBrand! != .Amex) && (cardNumberLength == 15))
        {
            let part1 = cardNumberNSString.substringToIndex(cardNumberLength - 1)
            let part2 = cardNumberNSString.substringFromIndex(cardNumberLength - 1)
            cardNumber = part1 + " " + part2
        }
        else if ((cardBrand! == .Amex) && (cardNumberLength > 12))
        {
            let maxCardLengthForCardBrand = STPCardValidator.lengthForCardBrand(cardBrand!)
            
            if (cardNumberLength - 2) > maxCardLengthForCardBrand // 2 -> spaces
            {
                cardNumber = cardNumberNSString.substringToIndex(cardNumberLength - 1)
            }
        }
        else if ((cardBrand! != .Amex) && (cardNumberLength > 15))
        {
            if cardBrand! != .Unknown
            {
                let maxCardLengthForCardBrand = STPCardValidator.lengthForCardBrand(cardBrand!)
                
                if (cardNumberLength - 3) > maxCardLengthForCardBrand // 3 -> spaces
                {
                    cardNumber = cardNumberNSString.substringToIndex(cardNumberLength - 1)
                }
            }
        }
        
        return cardNumber
    }
    
    func formatExpirationDate() -> String
    {
        var expirationDate = Card.expirationDate
        let expirationDateNSString = NSString(string: expirationDate)
        let expirationDateLength = expirationDateNSString.length
        
        if (expirationDateLength == 1) && (expirationDate != "0") && (expirationDate != "1")
        {
            expirationDate = "0" + expirationDate
        }
        else if expirationDateLength == 3
        {
            let part1 = expirationDateNSString.substringToIndex(expirationDateLength - 1)
            let part2 = expirationDateNSString.substringFromIndex(expirationDateLength - 1)
            expirationDate = part1 + " / " + part2
        }
        else if expirationDateLength > 7
        {
            expirationDate = expirationDateNSString.substringToIndex(expirationDateLength - 1)
        }
        
        return expirationDate
    }
    
    func formatCVC() -> String
    {
        var cvc = Card.cvc
        let cvcNSString = NSString(string: cvc)
        let cvcLength = cvcNSString.length
        
        retrieveCardBrand()
        
        if cardBrand! != .Unknown
        {
            let maxCardBrandCVCLength = Int(STPCardValidator.maxCVCLengthForCardBrand(cardBrand!))
            if cvcLength > maxCardBrandCVCLength
            {
                cvc = cvcNSString.substringToIndex(cvcLength - 1)
            }
        }
        
        return cvc
    }
    
    //-------------------------------------------------------------------------//
    // MARK: Validation
    //-------------------------------------------------------------------------//
    
    func cardNumberIsValid() -> Bool
    {
        var isValid = false
        
        if Card.cardNumber.characters.count > 0
        {
            let status = cardNumberValidationStatus()
            
            if status == .Valid
            {
                isValid = true
            }
        }
        
        return isValid
    }
    
    func cardNumberValidationStatus() -> STPCardValidationState
    {
        let sanitizedNumber = STPCardValidator.sanitizedNumericStringForString(Card.cardNumber)
        return STPCardValidator.validationStateForNumber(sanitizedNumber, validatingCardBrand:true)
    }
    
    func expirationDateIsValid() -> Bool
    {
        var isValid = false
        
        if Card.expirationDate.characters.count == 7
        {
            let monthStatus = monthValidationStatus(Card.expirationDate)
            let yearStatus = yearValidationStatus(Card.expirationDate)
            
            if (monthStatus == .Valid) && (yearStatus == .Valid)
            {
                isValid = true
            }
        }
        
        return isValid
    }
    
    func monthValidationStatus(expirationDate: String) -> STPCardValidationState
    {
        let sanitizedMonth = getSanitizedMonth(expirationDate)
        return STPCardValidator.validationStateForExpirationMonth(sanitizedMonth)
    }
    
    func yearValidationStatus(expirationDate: String) -> STPCardValidationState
    {
        let sanitizedMonth = getSanitizedMonth(expirationDate)
        let sanitizedYear = getSanitizedYear(expirationDate)
        return STPCardValidator.validationStateForExpirationYear(sanitizedYear, inMonth: sanitizedMonth)
    }
    
    func cvcIsValid() -> Bool
    {
        var isValid = false
        
        if Card.cvc.characters.count > 0
        {
            let status = cvcValidationStatus()
            
            if status == .Valid
            {
                isValid = true
            }
        }
        
        return isValid
    }
    
    func cvcValidationStatus() -> STPCardValidationState
    {
        retrieveCardBrand()
        return STPCardValidator.validationStateForCVC(Card.cvc, cardBrand: cardBrand!)
    }
    
    //-------------------------------------------------------------------------//
    // MARK: Sanitized Month & Year
    //-------------------------------------------------------------------------//
    
    func getSanitizedMonth(expirationDate: String) -> String
    {
        let sanitizedDate = STPCardValidator.sanitizedNumericStringForString(expirationDate)
        return NSString(string: sanitizedDate).substringToIndex(2)
    }
    
    func getSanitizedYear(expirationDate: String) -> String
    {
        let sanitizedDate = STPCardValidator.sanitizedNumericStringForString(expirationDate)
        return NSString(string: sanitizedDate).substringWithRange(NSMakeRange(2, 2))
    }
    
    //-------------------------------------------------------------------------//
    // MARK: STPCardParams
    //-------------------------------------------------------------------------//
    
    func getCardParams() -> STPCardParams
    {
        let params = STPCardParams()
            params.number = STPCardValidator.sanitizedNumericStringForString(Card.cardNumber)
            params.expMonth = UInt(Int(getSanitizedMonth(Card.expirationDate))!)
            params.expYear = UInt(Int(getSanitizedYear(Card.expirationDate))!)
            params.cvc = Card.cvc
        
        return params
    }
}