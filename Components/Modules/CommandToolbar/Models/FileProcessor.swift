//
//  FileProcessor.swift
//  Nea
//
//  Created by PEXAVC on 5/14/23.
//

import Foundation
import SwiftUI
import PDFKit
import GPT3_Tokenizer

class FileProcessor {
    static let shared: FileProcessor = .init()
    
    var tokenizer: GPT3Tokenizer = .init()
    var documentContents: String = ""
    var documentTokenCount: Int = 0
    var documentTokens: [Int] = []
    
    func process(_ url: URL) {
        if let pdf = PDFDocument(url: url) {
            let pageCount = pdf.pageCount
            let documentContent = NSMutableAttributedString()

            for i in 0 ..< pageCount {
                guard let page = pdf.page(at: i) else { continue }
                guard let pageContent = page.attributedString else { continue }
                documentContent.append(pageContent)
            }
            
            documentContents = documentContent.string
            documentTokens = tokenizer.encoder.enconde(text: documentContent.string)
            documentTokenCount = documentTokens.count
            
            print("[FileProcessor] tokencount = \(documentTokenCount)")
            
        } else {
            print("[FileProcessor] error, couldn't create pdf")
        }
    }
}
