import Foundation

func main() {
	let filename: String = "/Users/azfar/Downloads/Transaktioner_2023-09-12_19-20-18.csv"
	
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

}

main()
exit(EXIT_SUCCESS)