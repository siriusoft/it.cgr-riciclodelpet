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
    var ps: Int
    var altriColori: Int
    var colla: Int
    var ingiallimento: Int
    var note: String
    var metalli: Int
    var approvato: Bool
    
    // var dataCompleted: Date
    
    init(pvc: Int, pe: Int, ps: Int, altriColori: Int, colla: Int, ingiallimento: Int,  note: String, metalli: Int, approvato: Bool) {
        
        self.pvc =  pvc
        self.pe = pe
        self.ps = ps
        self.altriColori = altriColori
        self.colla = colla
        self.ingiallimento = ingiallimento
        self.note = note
        self.metalli = metalli
        self.approvato = approvato
        // self.dataCompleted = dataCompleted
        
    }
}
