//
//  InsertAnagraficaArticoloViewController.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 25/02/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//

import UIKit
import Firebase
import WebKit
import FirebaseDatabase

class InsertAnagraficaArticoloViewController: UIViewController {

    var anagraficaArticolo: AnagraficaArticoli?
    
    @IBOutlet weak var descrizioneEstesaLabel: UITextField!
    @IBOutlet weak var codiceLabel: UITextField!
    
    @IBOutlet weak var codiceAttivo: UISwitch!
    @IBOutlet weak var descrizioneSinteticaLabel: UITextField!
    
    let anagraficaArticoliRef: DatabaseReference = Database.database().reference().child("anagraficaArticoli")
    
    var anagraficaEsiste: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
      
        
        if let articolo = anagraficaArticolo?.codice {codiceLabel.text = articolo
            anagraficaEsiste = true
        }
        
        if let descrizioneEstesa = anagraficaArticolo?.descrizioneEstesa {
            descrizioneEstesaLabel.text =  descrizioneEstesa }
        
        if let descrizioneSintetica = anagraficaArticolo?.descrizioneSintetica {
            descrizioneSinteticaLabel.text =  descrizioneSintetica }
        
        
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
       
        
        let approvatoFirebase: String?
        if codiceAttivo.isOn {
                approvatoFirebase = "Si"
            } else { approvatoFirebase = "No" }
        let autore = Auth.auth().currentUser!.email
        let anagraficaAggiornata = ["DescrizioneEstesa": descrizioneEstesaLabel.text, "DescrizioneSintetica": descrizioneSinteticaLabel.text,"Autore": autore,"CodiceAttivo": approvatoFirebase]
       
        if anagraficaEsiste {
            let alertController = UIAlertController(title: "Anagrafica Articolo", message: "Sicuro di voler modificare l'articolo?", preferredStyle: UIAlertControllerStyle.alert)
            let continuaAction = UIAlertAction(title: "Continua", style: UIAlertActionStyle.default, handler: {
                (action : UIAlertAction!) -> Void in
                
                if let articoloItem = self.codiceLabel?.text {
                    self.anagraficaArticoliRef.child(articoloItem).setValue(anagraficaAggiornata)
                }
            })
            let annullaAction = UIAlertAction(title: "Annulla", style: UIAlertActionStyle.default, handler: {
                (action : UIAlertAction!) -> Void in })
            alertController.addAction(annullaAction)
            alertController.addAction(continuaAction)
            
            self.present(alertController, animated: true, completion: nil)
            print("sei sicuro di voler modificare i dati?")
        }
        if let articoloItem = codiceLabel?.text {
        anagraficaArticoliRef.child(articoloItem).setValue(anagraficaAggiornata)
        }
    }
        
}
