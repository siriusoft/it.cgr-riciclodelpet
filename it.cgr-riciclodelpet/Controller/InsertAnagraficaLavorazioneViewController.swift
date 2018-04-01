//
//  InsertAnagraficaLavorazioneViewController.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 24/03/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//

import UIKit
import Firebase
import WebKit
import FirebaseDatabase

class InsertAnagraficaLavorazioneViewController: UIViewController {
    
    var anagraficaLavorazione: AnagraficaLavorazioni?
    
    @IBOutlet weak var descrizioneEstesaLabel: UITextField!
    @IBOutlet weak var codiceLabel: UITextField!
    
    let anagraficaLavorazioniRef: DatabaseReference = Database.database().reference().child("anagraficaLavorazioni")
    var anagraficaEsiste: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        
        if let Lavorazione = anagraficaLavorazione?.codiceLavorazione {codiceLabel.text = Lavorazione
            anagraficaEsiste = true
        }
        
        if let descrizioneEstesa = anagraficaLavorazione?.descrizioneLavorazione {
            descrizioneEstesaLabel.text =  descrizioneEstesa }
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func modificaDatiPremuto(_ sender: Any) {
        
        let autore = Auth.auth().currentUser!.email
        let anagraficaAggiornata = ["Descrizione": descrizioneEstesaLabel.text, "Autore": autore]
        if anagraficaEsiste {
            let alertController = UIAlertController(title: "Anagrafica Lavorazione", message: "Sicuro di voler modificare i dati della lavorazione?", preferredStyle: UIAlertControllerStyle.alert)
            let continuaAction = UIAlertAction(title: "Continua", style: UIAlertActionStyle.default, handler: {
                (action : UIAlertAction!) -> Void in
                
                if let lavorazioneItem = self.codiceLabel?.text {
                    self.anagraficaLavorazioniRef.child(lavorazioneItem).setValue(anagraficaAggiornata)
                }
            })
            let annullaAction = UIAlertAction(title: "Annulla", style: UIAlertActionStyle.default, handler: {
                (action : UIAlertAction!) -> Void in })
            alertController.addAction(annullaAction)
            alertController.addAction(continuaAction)
            
            self.present(alertController, animated: true, completion: nil)
            print("sei sicuro di voler modificare i dati?")
        }
        if let LavorazioneItem = codiceLabel?.text {
            anagraficaLavorazioniRef.child(LavorazioneItem).setValue(anagraficaAggiornata)
        }
    }
    
}

