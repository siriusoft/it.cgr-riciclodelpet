//
//  MenuTableViewController.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 15/03/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
               /* let manutenzione = ProgrammaDiManutenzione(codiceMacchinario: "MUL1600", descrizioneManutenzione: ["CambioLame"], frequenzaManutenzione: [200000], dateManutenzione: [""])
                manutenzione.calcolaProduzioneDaUltimaManutenzione(dataUltimaManutenzione: "28/03/2018 22:00", reparto: "L", completionHandler: {(somma) in
                    print("la somma è: \(somma)")})*/
                performSegue(withIdentifier: "preconsumoSegue", sender: "L")
                
            }
            if indexPath.row == 1 {
                performSegue(withIdentifier: "preconsumoSegue", sender: "A")
            }
            if indexPath.row == 2 {
                performSegue(withIdentifier: "listaDocumentiSegue", sender: "SchedeDiProduzione")
            }
        }
        if indexPath.section == 1 {
            if indexPath.row == 1 {
                performSegue(withIdentifier: "listaDocumentiSegue", sender: "PackingList")
            }
        }
            
            
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "preconsumoSegue" {
            let vc = segue.destination as! FbTableViewController
            vc.codificaLotto = sender as? String
            
        }
        if segue.identifier == "listaDocumentiSegue" {
            let vc = segue.destination as! FilePDFTableViewController
           vc.tipoDocumento = sender as? String
            
        }
    }
}
