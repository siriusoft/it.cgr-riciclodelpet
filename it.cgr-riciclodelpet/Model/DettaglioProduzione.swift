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
    var note: [String]
    
   // var dataCompleted: Date
   
    init(lotto: String, umisura: String, codiceProdotto: String, quantity: [Int],  note: [String]) {
        
        self.codiceProdotto =  codiceProdotto
        self.quantity = quantity
        self.umisura = umisura
        self.lotto = lotto
        self.note = note
        // self.dataCompleted = dataCompleted
        
    }
}

