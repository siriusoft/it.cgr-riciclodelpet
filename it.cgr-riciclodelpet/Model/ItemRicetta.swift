//
//  ItemRicetta.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 03/01/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//


import UIKit

class ItemRicetta {
    var misura: String
    var articolo: String
    var fornitore: String
    var lotto: String
    var quantity: Int
    var note: String
    init(misura: String, articolo: String,fornitore: String,lotto: String, quantity: Int, note: String) {
        self.fornitore = fornitore
        self.articolo = articolo
        self.quantity = quantity
        self.misura = misura
        self.lotto = lotto
        self.note = note
    }
}
