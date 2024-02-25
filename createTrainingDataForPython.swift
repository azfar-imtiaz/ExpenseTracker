import Foundation
import CoreML
import NaturalLanguage

func readCSV() -> [Dictionary<String, Any>] {
    if let filename = Bundle.main.url(forResource: "transactions_23-24", withExtension: "csv") {
        print(filename)
    } else {
        print("File not found in bundle!")
    }
    
    let filename: String = "/Users/azfar/iOSProjects/Expense Tracker/transactions_23-24.csv"
    
    var transactions: [Dictionary<String, Any>] = []
    let fileURL = URL(fileURLWithPath: filename)
    do {
        let text = try String(contentsOf: fileURL, encoding: .ascii)
        let lines = text.split(whereSeparator: \.isNewline)
        for index in 2..<lines.count {
            let line = lines[index]
            let elements = line.split(separator: ",")
            transactions.append([
                "transactionDate": elements[5],
                "transactionReference": elements[8].replacingOccurrences(of: "\"", with: ""),
                "transactionType": elements[9].replacingOccurrences(of: "\"", with: ""),
                "transactionAmount": elements[10],
                "remainingBalance": elements[11]
            ])
        }
    } catch {
        print("Error processing: \(filename): \(error)")
    }

    for index in 0...5 {
        print(transactions[index])
        print("----------------------------------")
    }

    return transactions

}

let transactions = readCSV()
let modelURL = URL(fileURLWithPath: "/Users/azfar/iOSProjects/Expense Tracker/transactionCategorizer.mlmodel")
guard let model = try? MLModel(contentsOf: modelURL) else {
    fatalError("Failed to load the CoreML model!")
}

print(model)

guard let transactionClassifier = try? transactionCategorizer(configuration: MLModelConfiguration()) else {
    fatalError("Failed to create a model instance!")
}

for transaction in transactions {
    let predictedCategory = try model.prediction(input: transaction["transactionType"] as! String)
    print("\(transaction["transactionType"]) -> \(predictedCategory)")
}