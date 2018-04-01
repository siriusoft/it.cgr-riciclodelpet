//
//  DettaglioProduzione.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 28/01/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//

import Foundation
import UIKit
class DettaglioProduzione {
    var lotto: String
    var umisura: String
    var codiceProdotto: String
    var quantity: [Int]
    var tara: [Int]
    var note: [String?]
    var dataLavorazione: [String?]
    var lavorazione: String
    var produttore: String
    
   // var dataCompleted: Date
   
    init(lotto: String, umisura: String, codiceProdotto: String, quantity: [Int], tara: [Int], note: [String], lavorazione: String, dataLavorazione: [String], produttore: String ) {
        
        self.codiceProdotto =  codiceProdotto
        self.quantity = quantity
        self.tara = tara
        self.umisura = umisura
        self.lotto = lotto
        self.note = note
        self.lavorazione = lavorazione
        self.dataLavorazione = dataLavorazione
        self.produttore = produttore
        // self.dataCompleted = dataCompleted
        
    }
    
    func calcoloQuantitaLotto(dettaglioLotto: [Int]) -> Int {
        var sum = 0
        for i in 0...dettaglioLotto.count-1 {
            sum += dettaglioLotto[i]
        }
        return sum
    }
}

