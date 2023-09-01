//
//  TransactionListViewModel.swift
//  Expense Tracker
//
//  Created by Azfar Imtiaz on 2023-08-15.
//

import Foundation
import Combine

typealias TransactionGroup = [String: [Transaction]]

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
}
