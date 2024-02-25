//
//  main.swift
//  TransactionCategorization
//
//  Created by Azfar Imtiaz on 2023-10-28.
//

import Foundation
import CreateML

struct TransactionInstance: Encodable {
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

func convertTransactionsInstancesToJSON(transactions: [TransactionInstance]) -> [Dictionary<String, String>] {
    return transactions.map { transaction in
        return ["text": transaction.text, "value": transaction.value]
    }
    
    /* var transactionsJSON: [Data] = []
    for transaction in transactions {
        do {
            let transactionInstanceJSON = try JSONEncoder().encode(transaction)
            transactionsJSON.append(transactionInstanceJSON)
        } catch {
            print(error)
        }
    }
    return transactionsJSON */
}

let filename: String = "/Users/azfar/iOSProjects/Expense Tracker/training_data.txt"
let trainingTransactions = loadTrainingData(filename: filename)
let processedTransactions = preprocessTrainingData(transactions: trainingTransactions)
let transactionsJSON = convertTransactionsInstancesToJSON(transactions: processedTransactions)
print(transactionsJSON)

let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("transactions.json")

do {
    let jsonData = try JSONSerialization.data(withJSONObject: transactionsJSON, options: .prettyPrinted)
    
    try jsonData.write(to: fileURL)
    
    let data = try MLDataTable(contentsOf: URL(fileURLWithPath: fileURL.path))
    print(data)
    
    let (trainingData, testingData) = data.randomSplit(by: 0.8, seed: 5)
    
    let categoryClassifier = try MLTextClassifier(trainingData: trainingData, textColumn: "text", labelColumn: "value")
    
    let trainingAccuracy = (1.0 - categoryClassifier.trainingMetrics.classificationError) * 100
    print("Training accuracy: \(trainingAccuracy)")
    let validationAccurary = (1.0 - categoryClassifier.validationMetrics.classificationError) * 100
    print("Validation accuracy: \(validationAccurary)")
    
    let evaluationMetrics = categoryClassifier.evaluation(on: testingData, textColumn: "text", labelColumn: "value")
    let evaluationAccuracy = (1.0 - evaluationMetrics.classificationError) * 100
    
    print("Evaluation accuracy: \(evaluationAccuracy)")
    
    let metadata = MLModelMetadata(author: "Azfar Imtiaz", shortDescription: "A model trained to categorize bank transactions", version: "1.0")
    try categoryClassifier.write(to: URL(filePath: "/Users/azfar/iOSProjects/Expense Tracker/transactionCategorizer.mlmodel"), metadata: metadata)
        
} catch {
    print(error)
}
