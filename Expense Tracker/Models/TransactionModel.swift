//
//  TransactionModel.swift
//  Expense Tracker
//
//  Created by Azfar Imtiaz on 2023-08-08.
//

import Foundation

struct Transaction: Identifiable {
    let id: Int
    let date: String
    let institution: String
    let account: String
    var merchant: String
    let amount: Double
    let type: TransactionType.RawValue
    var categoryID: Int
    var category: String
    let isPending: Bool
    var isTransfer: Bool
    var isExpense: Bool
    var isEdited: Bool
    
    var parsedDate: Date {
        return date.parseDate()
    }
    
    var signedAmount: Double {
        return type == TransactionType.credit.rawValue ? amount: -amount
    }
}

enum TransactionType: String {
    case debit = "debit"
    case credit = "credit"
}
