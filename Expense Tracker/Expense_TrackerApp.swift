//
//  Expense_TrackerApp.swift
//  Expense Tracker
//
//  Created by Azfar Imtiaz on 2023-08-08.
//

import SwiftUI

@main
struct Expense_TrackerApp: App {
    @StateObject var transactionListVM = TransactionListViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(transactionListVM)
        }
    }
}
