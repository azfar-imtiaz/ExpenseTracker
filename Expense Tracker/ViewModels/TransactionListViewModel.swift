//
//  TransactionListViewModel.swift
//  Expense Tracker
//
//  Created by Azfar Imtiaz on 2023-08-15.
//

import Foundation
import Combine
import Collections

typealias TransactionGroup = OrderedDictionary<String, [Transaction]>
typealias TransactionPrefixSum = [(String, Double)]

final class TransactionListViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        getTransactions()
    }
    
    func getTransactions() {
        guard let url = URL(string: "https://designcode.io/data/transactions.json") else {
            print("Invalid URL!")
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data, response) -> Data in
                guard let httpResposnse = response as? HTTPURLResponse, httpResposnse.statusCode == 200 else {
                    dump(response)
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: [Transaction].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Error while fetching transactions: ", error.localizedDescription)
                case .finished:
                    print("Finished fetching transactions!")
                }
            } receiveValue: { [weak self] result in
                self?.transactions = result
            }
            .store(in: &cancellables)
    }
    
    func groupTransactionsByMonth() -> TransactionGroup {
        guard !transactions.isEmpty else {
            return [:]
        }
        return TransactionGroup(grouping: transactions, by: { $0.month })
    }
    
    func accumulateTransactions() -> TransactionPrefixSum {
        guard !transactions.isEmpty else {
            return []
        }
        let selectedDate = "02/17/2022".parseDate() // Ideally, we should have the current date here, for real-time data
        let dateInterval = Calendar.current.dateInterval(of: .month, for: selectedDate)!
        
        var sum: Double = .zero
        var cumulativeSum = TransactionPrefixSum()
        
        // Here we calculate the sum of expenses per day from the start of the month in selectedDate to the selectedDate day
        // The per day part is specified by the 60 * 60 * 24, which is 60 seconds * 60 minutes * 24 hours = one day
        for date in stride(from: dateInterval.start, to: selectedDate, by: 60 * 60 * 24) {
            let dailyExpenses = transactions.filter({ $0.parsedDate == date && $0.isExpense })
            let dailyTotal = dailyExpenses.reduce(0) { $0 - $1.signedAmount }
            
            sum += dailyTotal.rounded()
            cumulativeSum.append((date.formatted(.dateTime.year().month().day()), sum))
        }
        return cumulativeSum
    }
}
