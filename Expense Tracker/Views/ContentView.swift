//
//  ContentView.swift
//  Expense Tracker
//
//  Created by Azfar Imtiaz on 2023-08-08.
//

import SwiftUI
import SwiftUICharts

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Title
                    Text("Overview")
                        .font(.title)
                        .bold()
                    
                    // Line chart
                    CardView {
                        VStack {
                            ChartLabel("$900", type: .largeTitle)
                            LineChart()
                                .padding(.horizontal, 2)
                        }
                        .background(Color.systemBackground)
                    }
                    .data([8, 2, 4, 6, 12, 9, 2])
                    .chartStyle(ChartStyle(backgroundColor: Color.systemBackground, foregroundColor: ColorGradient(Color.icon.opacity(0.4), Color.icon)))
                    .frame(height: 300)
                    
                    
                    // Recent most 5 transactions
                    RecentTransactionsList()
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .background(Color.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Image(systemName: "bell.badge")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.icon, .primary)
                }
            }
        }
        .navigationViewStyle(.stack)
        .accentColor(.primary)
    }
}

struct ContentView_Previews: PreviewProvider {
    static let transactionListViewModel: TransactionListViewModel = {
        let transactionListViewModel = TransactionListViewModel()
        transactionListViewModel.transactions = transactionListPreviewData
        return transactionListViewModel
    }()

    static var previews: some View {
        Group {
            ContentView()
            ContentView()
                .preferredColorScheme(.dark)
        }
        .environmentObject(transactionListViewModel)
    }
}
