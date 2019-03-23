//
//  PackingListComposer.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 11/03/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//

import UIKit

class PackingListComposer: NSObject {
    
    let pathToInvoiceHTMLTemplate = Bundle.main.path(forResource: "packingList", ofType: "html")
    
    let pathToSingleItemHTMLTemplate = Bundle.main.path(forResource: "single_item", ofType: "html")
    
    let pathToLastItemHTMLTemplate = Bundle.main.path(forResource: "last_item", ofType: "html")
    
    let senderInfo = ""
    
    //let recipientInfo = "COEXPAN"
    
    let paymentMethod = ""
    
    //let logoImageURL = "http://www.appcoda.com/wp-content/uploads/2015/12/blog-logo-dark-400.png"
    let logoImageURL = Bundle.main.path(forResource: "LogoCGR-150dpi-RGB", ofType: "png")
    var packingListNumber: String!
    
    var pdfFilename: String!
    
   
    
    
    override init() {
        super.init()
    }
    
    
    func renderInvoice(packingListInfo: PackingList, recipientInfo: String, ordineNumero: String, ordineData: String) -> String! {
        // Store the invoice number for future use.
        self.packingListNumber = packingListInfo.identificativo
        
        do {
            // Load the invoice HTML template code into a String variable.
            var HTMLContent = try String(contentsOfFile: pathToInvoiceHTMLTemplate!)
            
            // Replace all the placeholders with real values except for the items.
            // The logo image.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#LOGO_IMAGE#", with: logoImageURL!)
            // PL number.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#PL_NUMBER#", with: packingListInfo.identificativo)
            
            // PL date.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#PL_DATE#", with: packingListInfo.annoDdtCollegato!)
            
            
            // Sender info.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#SENDER_INFO#", with: senderInfo)
            
            // Recipient info.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#DESTINATARIO_INFO#", with: recipientInfo.replacingOccurrences(of: "\n", with: "<br>"))
            
            // Ordine info.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ORDINE_N#", with: ordineNumero.replacingOccurrences(of: "\n", with: "<br>"))
            
            // Ordine data.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ORDINE_DATA#", with: ordineData.replacingOccurrences(of: "\n", with: "<br>"))
            
            // DDT method.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#DDT_N#", with: packingListInfo.ddtCollegato!)
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#DDT_DATA#", with: packingListInfo.annoDdtCollegato!)
            
            // Total amount.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#TOTALE_NETTO#", with: String(packingListInfo.sommaKgPackingList()))
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#TOTALE_BB#", with: String(packingListInfo.listaColli!.count))
            
            HTMLContent = HTMLContent.replacingOccurrences(of: "#TOTALE_TARA#", with: String(packingListInfo.sommaTaraPackingList()))
            
            // The invoice items will be added by using a loop.
            var allItems = ""
            
            let items = packingListInfo.listaColli!
            // For all the items except for the last one we'll use the "single_item.html" template.
            // For the last one we'll use the "last_item.html" template.
            for i in 0..<items.count {
                var itemHTMLContent: String!
                
                // Determine the proper template file.
                if i != items.count - 1 {
                    itemHTMLContent = try String(contentsOfFile: pathToSingleItemHTMLTemplate!)
                }
                else {
                    itemHTMLContent = try String(contentsOfFile: pathToLastItemHTMLTemplate!)
                }
                
                // Replace the description and price placeholders with the actual values.
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#CODICE#", with: items[i].codice)
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#LOTTO#", with: items[i].lotto)
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#N_BB#", with: String(items[i].numeroBb))
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#PESO_NETTO#", with: String(items[i].quantityKg))
                itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#TARA#", with: String(items[i].taraKg))
               
                
                // Add the item's HTML code to the general items string.
                allItems += itemHTMLContent
            }
            
            // Set the items.
            HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEMS#", with: allItems)
            
            // The HTML code is ready.
            return HTMLContent
            
        }
        catch {
            print("Unable to open and use HTML template files.")
        }
        
        return nil
    }
    
    
    func exportHTMLContentToPDF(HTMLContent: String, printFormatter: UIViewPrintFormatter) {
        let printPageRenderer = CustomPrintPageRenderer()
        //formatter.maximumContentHeight = 605.0
        //let printFormatter2 = UIMarkupTextPrintFormatter(markupText: HTMLContent)
        printPageRenderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        
        let pdfData = drawPDFUsingPrintPageRenderer(printPageRenderer: printPageRenderer)
        
        pdfFilename = "\(AppDelegate.getAppDelegate().getDocDir())/PackingList\(packingListNumber!).pdf"
        pdfData?.write(toFile: pdfFilename, atomically: true)
        
        print(pdfFilename)
    }
    
    
    func drawPDFUsingPrintPageRenderer(printPageRenderer: UIPrintPageRenderer) -> NSData! {
        let data = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(data, CGRect.zero, nil)
        for i in 0..<printPageRenderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            printPageRenderer.drawPage(at: i, in: CGRect.init(x: 0, y: 0, width: 595.2, height: 841.8))
        }
        
        UIGraphicsEndPDFContext()
        
        return data
    }
    
}
