//
//  AnagraficaArticoli.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 25/02/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//

import Foundation


class AnagraficaArticoli {
    var codice: String
    var descrizioneEstesa: String
    var descrizioneSintetica: String
    var autore: String
    var codiceAttivo: String
    
    
    init(codice: String, descrizioneEstesa: String, descrizioneSintetica: String, autore: String, codiceAttivo: String) {
        
        self.codice = codice
        self.descrizioneEstesa = descrizioneEstesa
        self.descrizioneSintetica = descrizioneSintetica
        self.autore = autore
        self.codiceAttivo = codiceAttivo
    }
}

class AnagraficaLavorazioni {
    var codiceLavorazione: String
    var descrizioneLavorazione: String
    var autore: String
    
    init(codiceLavorazione: String, descrizioneLavorazione: String, autore: String) {
        self.codiceLavorazione = codiceLavorazione
        self.descrizioneLavorazione = descrizioneLavorazione
        self.autore = autore
    }
}

