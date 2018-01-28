//
//  ItemProdottoFinito.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 03/01/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//

import Foundation
import UIKit
class ItemProdottoFinito {
    var ricetta: [ItemRicetta]
    var umisura: String
    var completed: Bool
    var name: String
    var quantity: Int
    var note: String
    var dataCompleted: Date
    var dataStart: Date
    init(umisura: String, completed: Bool,name: String, quantity: Int, ricetta: [ItemRicetta], note: String, dataCompleted: Date, dataStart: Date) {
        self.completed = completed
        self.name =  name
        self.quantity = quantity
        self.umisura = umisura
        self.ricetta = ricetta
        self.note = note
        self.dataCompleted = dataCompleted
        self.dataStart = dataStart
    }
}
