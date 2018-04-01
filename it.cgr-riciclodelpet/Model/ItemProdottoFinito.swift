//
//  ItemProdottoFinito.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 03/01/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//

import Foundation
import UIKit


class PackingList {
    var autore: String
    var identificativo: String
    var ddtCollegato: String?
    var annoDdtCollegato: String?
    var listaColli: [ItemProdottoFinito]?
    
    init(autore: String, identificativo: String, ddtCollegato: String?, annoDdtCollegato: String?, listaColli: [ItemProdottoFinito]?) {
        self.autore = autore
        self.identificativo = identificativo
        self.ddtCollegato = ddtCollegato
        self.annoDdtCollegato = annoDdtCollegato
        self.listaColli = listaColli
    }

    func sommaKgPackingList() -> Int {
        var somma = 0
        for item in self.listaColli! {
            somma += item.quantityKg
        }
        return somma
    }
    
    func sommaTaraPackingList() -> Int {
        var somma = 0
        for item in self.listaColli! {
            somma += item.taraKg
        }
        return somma
    }
}

class Articolo {
    var articolo: String
    var lotto: String
    var kg: Int
    var colli: Int
    var tara: Int
    
    init(articolo: String, lotto: String, kg:Int, colli: Int, tara: Int) {
        self.articolo = articolo
        self.lotto = lotto
        self.kg = kg
        self.colli = colli
        self.tara = tara
    }
}


class ItemProdottoFinito { 
    var codice: String
    var quantityKg: Int
    var taraKg: Int
    var lotto: String
    var numeroBb: Int
    var dataProduzione: String
    var codiceBarra: String
    init(codice: String, lotto: String, numeroBb: Int, quantityKg: Int, taraKg: Int, dataProduzione: String, codiceBarra: String) {
        self.codice = codice
        self.lotto =  lotto
        self.quantityKg = quantityKg
        self.taraKg = taraKg
        self.numeroBb = numeroBb
        self.dataProduzione = dataProduzione
        self.codiceBarra = codiceBarra
        
    }
    
    // Manca ancora verificare che barCode sia una stringa valida
}

class CodiceBarra {
    var barCode: String
    
    init(barCode: String) {
        self.barCode = barCode
    }
    
    func riconosciQrCode() -> ItemProdottoFinito? {
            
            guard let lottoLowerBound = barCode.range(of: "L%")?.upperBound else {return nil}
            guard let lottoUpperBound = barCode.range(of: "N%")?.lowerBound else{ return nil}
            let lotto = String(barCode[lottoLowerBound..<lottoUpperBound])
            
            guard let quantitaLowerBound = barCode.range(of: "Q%")?.upperBound else{ return nil}
            guard let quantitaUpperBound = barCode.range(of: "T%")?.lowerBound else{ return nil}
            let quantityKg = Int(String(barCode[quantitaLowerBound..<quantitaUpperBound]))
            
            guard let taraLowerBound = barCode.range(of: "T%")?.upperBound else{ return nil}
            guard let taraUpperBound = barCode.range(of: "F%")?.lowerBound else{ return nil}
            let taraKg = Int(String(barCode[taraLowerBound..<taraUpperBound]))
            
            guard let codiceLowerBound = barCode.range(of: "I%")?.upperBound else{ return nil}
            guard let codiceUpperBound = barCode.range(of: "L%")?.lowerBound else{ return nil}
            let codice = String(barCode[codiceLowerBound..<codiceUpperBound])
            
            guard let bbNumeroLowerBound = barCode.range(of: "N%")?.upperBound else{ return nil}
            guard let bbNumeroUpperBound = barCode.range(of: "Q%")?.lowerBound else{ return nil}
            let numeroBb = Int(String(barCode[bbNumeroLowerBound..<bbNumeroUpperBound]))
            
            
            
            let itemProdottoFinito = ItemProdottoFinito(codice: codice, lotto: lotto, numeroBb: numeroBb!, quantityKg: quantityKg!, taraKg: taraKg!, dataProduzione: "", codiceBarra: barCode)
            
            return itemProdottoFinito
            
    }
        
}

