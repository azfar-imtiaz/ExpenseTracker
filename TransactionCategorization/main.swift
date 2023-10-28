//
//  main.swift
//  TransactionCategorization
//
//  Created by Azfar Imtiaz on 2023-10-28.
//

import Foundation

struct TransactionInstance {
    var text: String
    var value: String
}

func loadTrainingData(filename: String) -> [TransactionInstance] {
    var transactions: [TransactionInstance] = []
    let fileURL = URL(fileURLWithPath: filename)
    do {
        let text = try String(contentsOf: fileURL, encoding: .ascii)
        let lines = text.split(whereSeparator: \.isNewline)
        for index in 1..<lines.count {
            let line = lines[index]
            var trainingInstance: [String] = []
            if line.contains("\t") {
                trainingInstance = line.split(separator: "\t").map(String.init)
            } else {
                let separator = " - "
                var components = line.components(separatedBy: separator)
                let lastElement = components.last!
                components = Array(components.dropLast())
                trainingInstance = [components.joined(separator: separator), lastElement]
            }
            if trainingInstance.count == 2 {
                transactions.append(TransactionInstance(
                    text: trainingInstance[0],
                    value: trainingInstance[1])
                )
            } else {
                print("Error in parsing \(trainingInstance)!")
            }
        }
    } catch {
        print("Error processing: \(filename): \(error)")
    }
    return transactions
}

func preprocessTrainingData(transactions: [TransactionInstance]) -> [TransactionInstance] {
    var processedTransactions: [TransactionInstance] = []
    for transaction in transactions {
        var text = transaction.text
        var value = transaction.value
        
        if (text.contains("Västtrafik")) {
            value = "Auto & Transport"
        }
        
        if let regex = try? NSRegularExpression(pattern: "[+\\d]+") {
            text = regex.stringByReplacingMatches(in: text,
                                                  range: NSRange(location: 0, length: text.count),
                                                  withTemplate: "number")
        }
        processedTransactions.append(TransactionInstance(text: text, value: value))
    }
    return processedTransactions
}

let filename: String = "/Users/azfar/iOSProjects/Expense Tracker/training_data.txt"
let trainingTransactions = loadTrainingData(filename: filename)
let processedTransactions = preprocessTrainingData(transactions: trainingTransactions)
print(processedTransactions)
