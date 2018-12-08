//
//  SchedaTecnicaViewController.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 28/01/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//

import UIKit
import Firebase
import WebKit
import FirebaseDatabase


class SchedaTecnicaViewController: UIViewController {

    @IBOutlet weak var articoloLotto: UILabel!
    @IBOutlet weak var lotto: UILabel!
    @IBOutlet weak var metalliLotto: UITextField!
    @IBOutlet weak var pvcLotto: UITextField!
    @IBOutlet weak var peLotto: UITextField!
  
    @IBOutlet weak var psLotto: UITextField!
    @IBOutlet weak var ingiallimentoLotto: UITextField!
    
    @IBOutlet weak var approvatoSwitch: UISwitch!
    @IBOutlet weak var noteLotto: UITextField!
    
    @IBOutlet weak var collaLotto: UITextField!
    @IBOutlet weak var altriColoriLotto: UITextField!
    
    var produzioneLotto: DettaglioProduzione?
    let schedaTecnicaRef: DatabaseReference = Database.database().reference().child("qualita")
    var schedaTecnicaesiste: Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() 
        let articoloItem = produzioneLotto?.codiceProdotto
        articoloLotto.text = "Articolo: \(articoloItem!)"
        let lottoItem = produzioneLotto?.lotto
        lotto.text =  "Lotto: \(lottoItem!)"
        schedaTecnicaRef.child(lottoItem!).observe(.value) { (snap) in
           
            guard let schedaTecnica = snap.value as? [String: Any] else {
                print ("scheda tecnica per il lotto non trovata")
                self.schedaTecnicaesiste = false
                return
            }
            if let pvc = schedaTecnica["PVC"] {
                self.pvcLotto.text = String(describing: pvc)
            }
        
            if let pe = schedaTecnica["PE"] {
                self.peLotto.text = String(describing: pe)
            }
            
            if let ps = schedaTecnica["PS"] {
                self.psLotto.text = String(describing: ps)
            }
        
            if let metalli = schedaTecnica["Metalli"] {
                self.metalliLotto.text = String(describing: metalli)
            }
       
            if let altriColori = schedaTecnica["Altri colori"] {
            self.altriColoriLotto.text = String(describing: altriColori)
            }
                
            if let ingiallimento = schedaTecnica["Ingiallimento"] {
                self.ingiallimentoLotto.text = String(describing: ingiallimento)
            }
        
            if let approvato = schedaTecnica["Approvato"] {
                if String(describing: approvato) == "Si" {
                    self.approvatoSwitch.setOn(true, animated: false)
                    
                } else {
                    self.approvatoSwitch.setOn(false, animated: false)
                }
                //self.approvatoLotto.text = String(describing: approvato)
            }
        
            if let note = schedaTecnica["Note"] {
                self.noteLotto.text = String(describing: note)
            }
            
            if let colle = schedaTecnica["Colla"] {
                self.collaLotto.text = String(describing: colle)
            }
        
            
         }
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
       
        if schedaTecnicaesiste {
            print("sei sicuro di voler modificare i dati?")
            let alert = UIAlertController(title: "Scheda Tecnica già esiste", message: "Sei sicuro di volerla modificare?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { action in
                    self.dismiss(animated: true, completion: nil)
               
                }))
            alert.addAction(UIAlertAction(title: "Continua", style: UIAlertActionStyle.default, handler: { action in
                
                    self.inserisciSchedaTecnicaInFirebase()
                    self.dismiss(animated: true, completion: nil)
                }))
            self.present(alert, animated: true, completion: nil)

          } else { inserisciSchedaTecnicaInFirebase()}
       
        
    }
    
    func inserisciSchedaTecnicaInFirebase() {
        let lottoItem = produzioneLotto?.lotto
        let approvatoFirebase: String?
        if approvatoSwitch.isOn {
            approvatoFirebase = "Si"
        } else { approvatoFirebase = "No" }
        let schedaTecnicaAggiornata = ["PVC": pvcLotto.text, "PE": peLotto.text, "PS": psLotto.text, "Metalli": metalliLotto.text, "Ingiallimento": ingiallimentoLotto.text, "Altri colori": altriColoriLotto.text, "Colla": collaLotto.text, "Note": noteLotto.text, "Approvato": approvatoFirebase]
        
        schedaTecnicaRef.child(lottoItem!).setValue(schedaTecnicaAggiornata)
    }
}
