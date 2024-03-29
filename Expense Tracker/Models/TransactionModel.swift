//
//  TransactionModel.swift
//  Expense Tracker
//
//  Created by Azfar Imtiaz on 2023-08-08.
//

import Foundation
import SwiftUIFontIcon

struct Transaction: Identifiable, Decodable, Hashable {
    let id: Int
    let date: String
    let description: String
    let account: String
    var merchant: String
    let amount: Double
    let type: TransactionType.RawValue
    var categoryId: Int
    var category: String
//    let isPending: Bool
//    var isTransfer: Bool
    var isExpense: Bool
//    var isEdited: Bool
    
    var icon: FontAwesomeCode {
        if let category = Category.all.first(where: { $0.id == categoryId }) {
            return category.icon
        }
        return .question
    }
    
    var parsedDate: Date {
        return date.parseDate()
    }
    
    var signedAmount: Double {
        return type == TransactionType.credit.rawValue ? amount: -amount
    }
    
    var month: String {
        parsedDate.formatted(.dateTime.year().month(.wide))
    }
}

enum TransactionType: String {
    case debit = "debit"
    case credit = "credit"
}

struct Category {
    let id: Int
    let name: String
    let icon: FontAwesomeCode
    var mainCategoryId: Int?
}

extension Category {
    static let autoAndTransport = Category(id: 1, name: "Auto & Transport", icon: .car_alt)
    static let billsAndUtilities = Category(id: 2, name: "Bills & Utilities", icon: .file_invoice_dollar)
    static let entertainment = Category(id: 3, name: "Entertainment", icon: .film)
    static let feesAndCharges = Category(id: 4, name: "Fees & Charges", icon: .hand_holding_usd)
    static let foodAndDining = Category(id: 5, name: "Food & Dining", icon: .hamburger)
    static let home = Category(id: 6, name: "Home", icon: .home)
    static let income = Category(id: 7, name: "Income", icon: .dollar_sign)
    static let shopping = Category(id: 8, name: "Shopping", icon: .shopping_cart)
    static let transfer = Category(id: 9, name: "Transfer", icon: .exchange_alt)
    
    static let publicTransportation = Category(id: 101, name: "Public Transportation", icon: .bus, mainCategoryId: 1)
    static let taxi = Category(id: 102, name: "Taxi", icon: .taxi, mainCategoryId: 1)
    
    static let mobilePhone = Category(id: 201, name: "Mobile Phone", icon: .mobile_alt, mainCategoryId: 2)
    
    static let moviesAndDVDs = Category(id: 301, name: "Movies & DVDs", icon: .film, mainCategoryId: 3)
    
    static let bankFee = Category(id: 401, name: "Bank Fee", icon: .hand_holding_usd, mainCategoryId: 4)
    static let financeCharge = Category(id: 402, name: "Finance Charge", icon: .hand_holding_usd, mainCategoryId: 4)
    
    static let groceries = Category(id: 501, name: "Groceries", icon: .shopping_basket, mainCategoryId: 5)
    static let restaurants = Category(id: 502, name: "Restaurants", icon: .utensils, mainCategoryId: 5)
    
    static let rent = Category(id: 601, name: "Rent", icon: .house_user, mainCategoryId: 6)
    static let homeSupplies = Category(id: 602, name: "Home Supplies", icon: .lightbulb, mainCategoryId: 6)
    
    static let payCheque = Category(id: 701, name: "Pay Cheque", icon: .dollar_sign, mainCategoryId: 7)
    
    static let software = Category(id: 801, name: "Software", icon: .icons, mainCategoryId: 8)
    
    static let creditCardPayment = Category(id: 901, name: "Credit Card Payment", icon: .exchange_alt, mainCategoryId: 9)
}

extension Category {
    
    static func retrieveCategoryID(categoryTitle: String) -> Int {
        switch categoryTitle {
        case "Auto & Transport":
            return 1
        case "Bills & Utilities":
            return 2
        case "Entertainment":
            return 3
        case "Fees & Charges":
            return 4
        case "Food & Dining":
            return 5
        case "Home":
            return 6
        case "Income":
            return 7
        case "Shopping":
            return 8
        case "Transfer":
            return 9
        default:
            return 4
        }
    }
    
    static func retrieveCategoryTitle(categoryID: Int) -> String {
        switch categoryID {
        case 0:
            return "Auto & Transport"
        case 1:
            return "Bills & Utilities"
        case 2:
            return "Entertainment"
        case 3:
            return "Fees & Charges"
        case 4:
            return "Food & Dining"
        case 5:
            return "Home"
        case 6:
            return "Income"
        case 7:
            return "Shopping"
        case 8:
            return "Transfer"
        default:
            return "Fees & Charges"
            
        }
    }
    
    static let categories: [Category] = [
        .autoAndTransport,
        .billsAndUtilities,
        .entertainment,
        .feesAndCharges,
        .foodAndDining,
        .home,
        .income,
        .shopping,
        .transfer
    ]
    
    static let subCategories: [Category] = [
        .publicTransportation,
        .taxi,
        .mobilePhone,
        .moviesAndDVDs,
        .bankFee,
        .financeCharge,
        .groceries,
        .restaurants,
        .rent,
        .homeSupplies,
        .payCheque,
        .software,
        .creditCardPayment
    ]
    
    static let all: [Category]  = categories + subCategories
}
