//
//  SchedaDiProduzioneComposer.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 17/03/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//

import UIKit
import Firebase

class SchedaDiProduzioneComposer: NSObject {
    
    let pathToInvoiceHTMLTemplate = Bundle.main.path(forResource: "schedaDiProduzione", ofType: "html")
    
    let pathToSingleItemHTMLTemplate = Bundle.main.path(forResource: "single_itemSP", ofType: "html")
    
    let pathToLastItemHTMLTemplate = Bundle.main.path(forResource: "last_itemSP", ofType: "html")
    let pathToSingleItemRicettaHTMLTemplate = Bundle.main.path(forResource: "single_item_ricettaSP", ofType: "html")
    let pathToLastItemHTMLRicettaTemplate = Bundle.main.path(forResource: "last_item_ricettaSP", ofType: "html")
    let senderInfo = ""
    
    //let recipientInfo = "COEXPAN"
    
    let paymentMethod = ""
    
    let logoImageURL = Bundle.main.path(forResource: "LogoCGR-150dpi-RGB", ofType: "png")
    var nomeFilePdf: String!
    
    var pdfFilename: String!
    
    //var HTMLricettaItems = String
    
    
    
    
    override init() {
        super.init()
    }
    
    
    func renderInvoice(listaDaStampare: [DettaglioProduzione], completionHandler: @escaping (String?) -> ()) {
        // Store the invoice number for future use.
        nomeFilePdf = (listaDaStampare.first?.lotto)! + " " + (listaDaStampare.last?.lotto)!
        
        
            // Load the invoice HTML template code into a String variable.
            //var HTMLContent = try String(contentsOfFile: pathToInvoiceHTMLTemplate!)
            var HTMLContentFinale = ""
            
            popolaRicetta(of: listaDaStampare, completionHandler: { (listaRicetta) in
                print("Ricette caricate in listaRicetta: \(listaRicetta.count)")
                // HTMLContent = HTMLContent.replacingOccurrences(of: "#CODMISC#", with: listaRicetta.first!.lottoPf)
                do {
                    for item in listaDaStampare {
                        var HTMLContent = try String(contentsOfFile: self.pathToInvoiceHTMLTemplate!)
                        
                        // Replace all the placeholders with real values except for the items.
                        // The logo image.
                        
                        HTMLContent = HTMLContent.replacingOccurrences(of: "#LOGO_IMAGE#", with: self.logoImageURL!)
                        // LOTTO number.
                        
                        HTMLContent = HTMLContent.replacingOccurrences(of: "#LOTTO_N#", with: item.lotto)
                        
                        // LOTTO date.
                        if let lottoData = item.dataLavorazione.first {
                            HTMLContent = HTMLContent.replacingOccurrences(of: "#LOTTO_DATA#", with: String(describing: lottoData))
                        }
                        
                        // LAVORAZIONE info.
                        HTMLContent = HTMLContent.replacingOccurrences(of: "#LAVORAZIONE#", with: item.lavorazione)
                        
                        // CODICE OPERATORE info.
                        HTMLContent = HTMLContent.replacingOccurrences(of: "#CODICEOPERATORE#", with: item.produttore)
                        
                        // MISCELATORE info.
                        
                        
                        
                        
                        // Total amount.
                        HTMLContent = HTMLContent.replacingOccurrences(of: "#TOTALE_NETTO#", with: String(item.calcoloQuantitaLotto(dettaglioLotto: item.quantity)))
                        
                        HTMLContent = HTMLContent.replacingOccurrences(of: "#TOTALE_BB#", with: String(item.quantity.count))
                        
                        HTMLContent = HTMLContent.replacingOccurrences(of: "#TOTALE_TARA#", with: String(item.calcoloQuantitaLotto(dettaglioLotto: item.tara)))
                        
                        // The invoice items will be added by using a loop.
                        var allItems = ""
                        var allItemsRicetta = ""
                        
                        // For all the items except for the last one we'll use the "single_item.html" template.
                        // For the last one we'll use the "last_item.html" template.
                        for i in 0..<item.quantity.count {
                            var itemHTMLContent: String!
                            
                            // Determine the proper template file.
                            if i != item.quantity.count - 1 {
                                itemHTMLContent = try String(contentsOfFile: self.pathToSingleItemHTMLTemplate!)
                            }
                            else {
                                itemHTMLContent = try String(contentsOfFile: self.pathToLastItemHTMLTemplate!)
                            }
                            
                            // Replace the description and price placeholders with the actual values.
                            itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#CODICE#", with: item.codiceProdotto)
                            itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#LOTTO#", with: item.lotto)
                            itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#N_BB#", with: String(i + 1))
                            itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#PESO_NETTO#", with: String(item.quantity[i]))
                            itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#TARA#", with: String(item.tara[i]))
                            itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#DATA_PRODUZIONE#", with: item.dataLavorazione[i])
                            itemHTMLContent = itemHTMLContent.replacingOccurrences(of: "#NOTE#", with: item.note[i])
                            
                            // Add the item's HTML code to the general items string.
                            allItems += itemHTMLContent
                        }
                        
                            // Add items to RICETTA
                        for itemRicetta in listaRicetta {
                            if itemRicetta.lottoPf == item.lotto {
                                for i in 0..<itemRicetta.articolo.count {
                                    var itemRicettaHTMLContent: String!
                                    
                                    // Determine the proper template file.
                                    if i != itemRicetta.articolo.count - 1 {
                                        itemRicettaHTMLContent = try String(contentsOfFile: self.pathToSingleItemRicettaHTMLTemplate!)
                                    }
                                    else {
                                        itemRicettaHTMLContent = try String(contentsOfFile: self.pathToLastItemHTMLRicettaTemplate!)
                                    }
                                    
                                    // Replace the description and price placeholders with the actual values.
                                    itemRicettaHTMLContent = itemRicettaHTMLContent.replacingOccurrences(of: "#CODICE#", with: itemRicetta.articolo[i])
                                    
                                    itemRicettaHTMLContent = itemRicettaHTMLContent.replacingOccurrences(of: "#FORNITORE#", with: itemRicetta.fornitore[i])
                                    
                                    itemRicettaHTMLContent = itemRicettaHTMLContent.replacingOccurrences(of: "#LOTTO#", with: itemRicetta.lotto[i])
                                    
                                    itemRicettaHTMLContent = itemRicettaHTMLContent.replacingOccurrences(of: "#QUANTITA_KG#", with: String(describing: itemRicetta.quantityKg[i]!))
                                    
                                    itemRicettaHTMLContent = itemRicettaHTMLContent.replacingOccurrences(of: "#QUANTITA_COLLI#", with: String(describing: itemRicetta.quantityColli[i]!))
                                    
                                    itemRicettaHTMLContent = itemRicettaHTMLContent.replacingOccurrences(of: "#COMPLETATO#", with: itemRicetta.completed[i])
                                    
                                    itemRicettaHTMLContent = itemRicettaHTMLContent.replacingOccurrences(of: "#NOTE_RICETTA#", with: itemRicetta.note[i])
                                    
                                    // Add the item's HTML code to the general items string.
                                    allItemsRicetta += itemRicettaHTMLContent
                                }
                            }
                        }
                        
                        
                        // Set the items.
                        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEMSRICETTA#", with: allItemsRicetta)
                        HTMLContent = HTMLContent.replacingOccurrences(of: "#ITEMS#", with: allItems)
                        HTMLContentFinale += HTMLContent
                    }
                   completionHandler(HTMLContentFinale)
                }
                catch {
                   print("Unable to open and use HTML template files.")
                   completionHandler(nil)
                }
            
            
            })
        
    }
    
    
    func exportHTMLContentToPDF(HTMLContent: String, printFormatter: UIViewPrintFormatter) {
        let printPageRenderer = CustomPrintPageRenderer()
        
       
        printPageRenderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        
        let pdfData = drawPDFUsingPrintPageRenderer(printPageRenderer: printPageRenderer)
        
        pdfFilename = "\(AppDelegate.getAppDelegate().getDocDir())/SchedeDiProduzione\(nomeFilePdf!).pdf"
        pdfData?.write(toFile: pdfFilename, atomically: true)

    }
    
    
    func drawPDFUsingPrintPageRenderer(printPageRenderer: UIPrintPageRenderer) -> NSData! {
        let data = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(data, CGRect.zero, nil)
        for i in 0..<printPageRenderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            printPageRenderer.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        
        UIGraphicsEndPDFContext()
        
        return data
    }
    
    
    func popolaRicetta(of listaLotto:[DettaglioProduzione], completionHandler:@escaping ([ItemRicetta]) -> ()) {
        var listaRicettaLotto = [ItemRicetta]()
        var contatore = 0
        for lotto in listaLotto {
            //print("popolaRicetta: var lotto.lotto: \(lotto.lotto)")
                let ricettaDatabase: DatabaseReference = Database.database().reference().child("ricetta").child(lotto.lotto)
            
            ricettaDatabase.observe(.value, with: { (snapShot) in
                
            
                
                let firebaseData = snapShot
                
                // let lotto = firebaseData.key
                if let lottoRicetta = firebaseData.value as? [String: Any] {
                    //print(lottoRicetta)
                    let articoloArray: [String] = lottoRicetta["articoloricetta"]! as! [String]
                    let fornitoreArray: [String] = lottoRicetta["fornitorericetta"]! as! [String]
                    let lottoArray: [String] = lottoRicetta["lottoricetta"]! as! [String]
                    let noteArray: [String] = lottoRicetta["notaricetta"]! as! [String]
                    let quantityArray: [Int] = lottoRicetta["quantitaricetta"] as! [Int]
                    let colliArray: [Int] = lottoRicetta["numerocolliricetta"] as! [Int]
                    let completedArray: [String] = lottoRicetta["completedricetta"]! as! [String]
                    //let userID = Auth.auth().currentUser!.uid
                    
                    let ricettaLotto = ItemRicetta(lottoPf: lotto.lotto, articolo: articoloArray, fornitore: fornitoreArray, lotto: lottoArray, quantityKg: quantityArray, quantityColli: colliArray, note: noteArray, completed: completedArray)
                    listaRicettaLotto.append(ricettaLotto)
                     //completionHandler(listaRicettaLotto)
                   
                }
                contatore = contatore + 1
                if contatore == listaLotto.count {
                    print("listaRicettaLotto con completion:\(listaRicettaLotto.count)")
                    completionHandler(listaRicettaLotto)
                }
            })
        }
    }
}

