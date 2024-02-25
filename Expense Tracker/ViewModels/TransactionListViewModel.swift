//
//  TransactionListViewModel.swift
//  Expense Tracker
//
//  Created by Azfar Imtiaz on 2023-08-15.
//

import Foundation
import Combine
import Collections
import CoreML
import NaturalLanguage

typealias TransactionGroup = OrderedDictionary<String, [Transaction]>
typealias TransactionPrefixSum = [(String, Double)]

final class TransactionListViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    
    private var cancellables = Set<AnyCancellable>()
    private var monthNameToNumMapping = [
        "January": "01",
        "February": "02",
        "March": "03",
        "April": "04",
        "May": "05",
        "June": "06",
        "July": "07",
        "August": "08",
        "September": "09",
        "October": "10",
        "November": "11",
        "December": "12",
    ]
    
    init() {
        getTransactions()
    }
    
    func getTransactions() {
        if let fileURL = Bundle.main.url(forResource: "Transaktioner_2023-09-12_19-20-18", withExtension: "csv") {
            do {
                let config = MLModelConfiguration()
                let transactionClassifier = try transactionCategorizer(configuration: config)
                
                let text = try String(contentsOf: fileURL, encoding: .ascii)
                let lines = text.split(whereSeparator: \.isNewline)
                for index in 2..<lines.count {
                    let line = lines[index]
                    let elements = line.split(separator: ",").map(String.init).filter { $0 != "\"" }
                    
                    let transactionText = elements[9]
                    let predictedCategory = try transactionClassifier.prediction(text: transactionText)
                    
                    print(predictedCategory.label)
                    let transactionObject = Transaction(
                        id: Int(elements[0])!,
                        date: elements[5],
                        description: elements[9].replacingOccurrences(of: "\"", with: ""),
                        account: elements[2],
                        merchant: elements[8].replacingOccurrences(of: "\"", with: ""),
                        amount: abs(Double(elements[10])!),
                        type: (Double(elements[10])! > 0 ? TransactionType.credit : TransactionType.debit).rawValue,
                        categoryId: Category.retrieveCategoryID(categoryTitle: predictedCategory.label),
                        category: predictedCategory.label,
                        isExpense: Double(elements[10])! > 0 ? false : true
                    )
                    transactions.append(transactionObject)
                    
                }
            } catch {
                print("Error processing: \(fileURL): \(error)")
            }
        }
    }
    
    func groupTransactionsByMonth() -> TransactionGroup {
        guard !transactions.isEmpty else {
            return [:]
        }
        return TransactionGroup(grouping: transactions, by: { $0.month })
    }
    
    func getTransactionsByMonth(month: String) -> [Transaction] {
        let transactionsByMonth = TransactionGroup(grouping: transactions, by: { $0.month })
        let selectedMonthTransactions = transactionsByMonth.filter { $0.key == month }.map { $0.value }
        return selectedMonthTransactions[0]
    }
    
    func accumulateTransactions(month: String) -> TransactionPrefixSum {
        guard !transactions.isEmpty else {
            return []
        }
        
        var selectedMonth: String = month
        let monthComponents = month.components(separatedBy: " ")
        if monthComponents.count > 1 {
            selectedMonth = monthComponents.first!
        }
        
        let monthNum = monthNameToNumMapping[selectedMonth] ?? "05"
        
        var endDate = 31
        if (["04", "06", "09", "11"].contains(monthNum)) {
            endDate = 30
        } else if (monthNum == "02") {
            endDate = 28
        }
        let selectedDate = "2023-\(monthNum)-\(endDate)".parseDate() // Ideally, we should have the current date here, for real-time data
        let dateInterval = Calendar.current.dateInterval(of: .month, for: selectedDate)!
        
        var sum: Double = .zero
        var cumulativeSum = TransactionPrefixSum()
        
        // Here we calculate the sum of expenses per day from the start of the month in selectedDate to the selectedDate day
        // The per day part is specified by the 60 * 60 * 24, which is 60 seconds * 60 minutes * 24 hours = one day
        print("Selected month: \(selectedMonth)")
        print("Month number: \(monthNum)")
        print("Calculating cumulative sum from \(dateInterval.start) to \(selectedDate)")
        for date in stride(from: dateInterval.start, to: selectedDate, by: 60 * 60 * 24) {
            let dailyExpenses = transactions.filter({ $0.parsedDate == date && $0.isExpense })
            let dailyTotal = dailyExpenses.reduce(0) { $0 - $1.signedAmount }
            
            sum += dailyTotal.rounded()
            cumulativeSum.append((date.formatted(.dateTime.year().month().day()), sum))
        }
        return cumulativeSum
    }
}
