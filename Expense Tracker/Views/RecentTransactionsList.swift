//
//  RecentTransactionsList.swift
//  Expense Tracker
//
//  Created by Azfar Imtiaz on 2023-08-15.
//

import SwiftUI

struct RecentTransactionsList: View {
    @EnvironmentObject var transactionListViewModel: TransactionListViewModel
    var month: String
    
    var body: some View {
        VStack {
            HStack {
                Text("Recent Transactions")
                    .bold()
                
                Spacer()
                
                NavigationLink {
                    AllTransactionsList()
                } label: {
                    HStack(spacing: 4) {
                        Text("See All")
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(Color.text)
                }
            }
            .padding(.top)
            
            if !month.isEmpty {
                ForEach(Array(transactionListViewModel.getTransactionsByMonth(month: month).prefix(5).enumerated()), id: \.element) { index, transaction in
                    TransactionRow(transaction: transaction)
                    
                    Divider().opacity(index == 4 ? 0 : 1)
                }
            } else {
                ForEach(Array(transactionListViewModel.transactions.prefix(5).enumerated()), id: \.element) { index, transaction in
                    TransactionRow(transaction: transaction)
                    
                    Divider().opacity(index == 4 ? 0 : 1)
                }
            }
        }
        .padding()
        .background(Color.systemBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.primary.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

struct RecentTransactionsList_Previews: PreviewProvider {
    static let transactionListViewModel: TransactionListViewModel = {
        let transactionListViewModel = TransactionListViewModel()
        transactionListViewModel.transactions = transactionListPreviewData
        return transactionListViewModel
    }()

    static var previews: some View {
        Group {
            RecentTransactionsList(month: "")
            RecentTransactionsList(month: "")
                .preferredColorScheme(.dark)
        }
        .environmentObject(transactionListViewModel)
    }
}
