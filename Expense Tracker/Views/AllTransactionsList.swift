//
//  AllTransactionsList.swift
//  Expense Tracker
//
//  Created by Azfar Imtiaz on 2023-09-01.
//

import SwiftUI

struct AllTransactionsList: View {
    @EnvironmentObject var transactionListViewModel: TransactionListViewModel
    
    var body: some View {
        let transactionArray = transactionListViewModel.groupTransactionsByMonth().map { (key, value) in
            return (key, value)
        }
        VStack {
            List {
                ForEach(transactionArray, id: \.0) { (month, transactions) in
                    Section {
                        ForEach(transactions) { transaction in
                            TransactionRow(transaction: transaction)
                        }
                        
                    } header: {
                        Text(month)
                    }
                    .listSectionSeparator(.hidden)
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Transactions")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AllTransactionsList_Previews: PreviewProvider {
    static let transactionListViewModel: TransactionListViewModel = {
        let transactionListViewModel = TransactionListViewModel()
        transactionListViewModel.transactions = transactionListPreviewData
        return transactionListViewModel
    }()
    
    static var previews: some View {
        Group {
            NavigationView {
                AllTransactionsList()
            }
            NavigationView {
                AllTransactionsList()
                    .preferredColorScheme(.dark)
            }
        }
        .environmentObject(transactionListViewModel)
    }
}
