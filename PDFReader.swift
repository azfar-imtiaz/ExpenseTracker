//
//  ContentView.swift
//  PDFReader
//
//  Created by Azfar Imtiaz on 2023-09-12.
//

import SwiftUI
import PDFKit

struct ContentView: View {
    @State private var presentImporter = false
    let filename = "Transaktioner_2023-09-12_11-24-52"
    let fileType = "pdf"
    
    var body: some View {
        VStack {
            Button("Open PDF file") {
                print("\(filename).\(fileType)")
                let text = extractTextFromPDF(fname: filename, fType: fileType)
                print(text)
            }
        }
    }
    
    private func extractTextFromPDF(fname: String, fType: String) -> String {
        if var path = Bundle.main.path(forResource: fname, ofType: fType) {
            let fm = FileManager()
            let exists = fm.fileExists(atPath: path)
            path = "file://" + path
            let fileURL: NSURL = NSURL(string: path)!
            
            if (exists) {
                if let pdfDocument = PDFDocument(url: fileURL as URL) {
                    var allText: [String] = []
                    for pageIndex in 0..<pdfDocument.pageCount {
                        if let page = pdfDocument.page(at: pageIndex) {
                            if let pageText = page.string {
                                allText.append(pageText)
                            }
                        }
                    }
                    return allText.first!
                }
            }
        }
        return "File not found!"
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
