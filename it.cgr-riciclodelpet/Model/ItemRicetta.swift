//
//  ItemRicetta.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 03/01/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//


import UIKit

class ItemRicetta {
    var lottoPf: String
    var quantityColli: [Int?]
    var articolo: [String]
    var fornitore: [String]
    var lotto: [String]
    var quantityKg: [Int?]
    var note: [String]
    var completed: [String]
    init(lottoPf: String, articolo: [String],fornitore: [String],lotto: [String], quantityKg: [Int?], quantityColli: [Int?],  note: [String], completed: [String]) {
        self.lottoPf = lottoPf
        self.fornitore = fornitore
        self.articolo = articolo
        self.quantityKg = quantityKg
        self.quantityColli = quantityColli
        self.lotto = lotto
        self.note = note
        self.completed = completed
    }
}
