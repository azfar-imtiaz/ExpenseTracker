//
//  ContentView.swift
//  Expense Tracker
//
//  Created by Azfar Imtiaz on 2023-08-08.
//

import SwiftUI
import SwiftUICharts

struct ContentView: View {
    @State private var selectedMonth: String = ""
    @State private var totalExpenses: Double = 0.0
    @State private var data: TransactionPrefixSum = []
    @EnvironmentObject var transactionListViewModel: TransactionListViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Title
                    Text("Overview")
                        .font(.title)
                        .bold()
                    
                    let transactionArray = transactionListViewModel.groupTransactionsByMonth().map { (key, value) in
                        return (key, value)
                    }
                    
                    Picker("Select month", selection: $selectedMonth) {
                        ForEach(transactionArray, id: \.0) { month, _ in
                            Button {
                                self.selectedMonth = month
                                self.data = transactionListViewModel.accumulateTransactions(month: selectedMonth)
                                self.totalExpenses = data.last?.1 ?? 0
                                print(totalExpenses)
                            } label: {
                                Text(month)
                            }
                        }
                    }
                    .padding(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.primary)
                    )
                    .onAppear {
                        if let firstMonth = transactionArray.first {
                            selectedMonth = firstMonth.0
                            self.data = transactionListViewModel.accumulateTransactions(month: selectedMonth)
                            self.totalExpenses = data.last?.1 ?? 0
                        }
                    }
                    .onChange(of: selectedMonth) { newMonth in
                        selectedMonth = newMonth
                        self.data = transactionListViewModel.accumulateTransactions(month: newMonth)
                        self.totalExpenses = data.last?.1 ?? 0
                    }
                    
//                        Menu(selectedMonth) {
//                            ForEach(transactionArray, id: \.0) { month, _ in
//                                Button(action: {
//                                    self.selectedMonth = month
//                                    self.data = transactionListViewModel.accumulateTransactions(month: self.selectedMonth)
//                                    self.totalExpenses = self.data.last?.1 ?? 0
//                                    print(self.totalExpenses)
//                                }) {
//                                    Text(month)
//                                        .font(.title3.bold())
//                                }
//                                .buttonStyle(BorderedButtonStyle())
//                            }
//                        }
//                        .menuStyle(BorderlessButtonMenuStyle())
                    
                    if !self.data.isEmpty {
                        // get the second element of the last tuple in the list, which is basically the cumulative sum up until the selected date
                        // let totalExpenses = data.last?.1 ?? 0
                        
                        CardView {
                            VStack(alignment: .leading) {
                                ChartLabel(self.totalExpenses.formatted(.currency(code: "SEK")), type: .largeTitle, format: "%.02f kr")
                                    .id(self.totalExpenses)
                                LineChart()
                                    .padding(.horizontal, 2)
                            }
                            .background(Color.systemBackground)
                        }
                        .data(data)
                        .chartStyle(ChartStyle(backgroundColor: Color.systemBackground, foregroundColor: ColorGradient(Color.icon.opacity(0.4), Color.icon)))
                        .frame(height: 300)
                    }
                    
                    // Recent most 5 transactions
                    RecentTransactionsList(month: selectedMonth)
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
