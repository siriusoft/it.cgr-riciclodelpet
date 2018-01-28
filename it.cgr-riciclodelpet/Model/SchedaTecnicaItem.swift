//
//  SchedaTecnicaItem.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 28/01/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//

import Foundation
import UIKit
class SchedaTecnicaItem {
    var pvc: Int
    var pe: Int
    var altriColori: Int
    var ingiallimento: Int
    var note: String
    var metalli: Int
    var approvato: Bool
    
    // var dataCompleted: Date
    
    init(pvc: Int, pe: Int, altriColori: Int, ingiallimento: Int,  note: String, metalli: Int, approvato: Bool) {
        
        self.pvc =  pvc
        self.pe = pe
        self.altriColori = altriColori
        self.ingiallimento = ingiallimento
        self.note = note
        self.metalli = metalli
        self.approvato = approvato
        // self.dataCompleted = dataCompleted
        
    }
}
