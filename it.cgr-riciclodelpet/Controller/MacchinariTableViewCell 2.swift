//
//  MacchinariTableViewCell.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 14/04/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//

import UIKit

class MacchinariTableViewCell: UITableViewCell {

    @IBOutlet weak var foto: UIImageView!    
    @IBOutlet weak var aggiungiLivello: UIButton!
    @IBOutlet weak var descrizione: UILabel!
    @IBOutlet weak var codice: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
