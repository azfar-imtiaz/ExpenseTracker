//
//  Extensions.swift
//  Expense Tracker
//
//  Created by Azfar Imtiaz on 2023-08-08.
//

import Foundation
import SwiftUI

extension Color {
    static let background = Color("Background")
    static let icon = Color("Icon")
    static let text = Color("Text")
    
    static let systemBackground = Color(uiColor: .systemBackground)
}

extension DateFormatter {
    static let allNumericUSA: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"        
        return formatter
    }()
}

extension String {
    func parseDate() -> Date {
        let parsedDate = DateFormatter.allNumericUSA.date(from: self)
        if parsedDate != nil {
            return parsedDate!
        } else {
            return Date()
        }
//        guard let parsedDate = DateFormatter.allNumericUSA.date(from: self) else { return Date() }
//        return parsedDate
    }
}
