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
    @IBOutlet weak var approvatoLotto: UITextField!
    @IBOutlet weak var ingiallimentoLotto: UITextField!
    
    @IBOutlet weak var noteLotto: UITextField!
    
    @IBOutlet weak var collaLotto: UITextField!
    @IBOutlet weak var altriColoriLotto: UITextField!
    
    var produzioneLotto: DettaglioProduzione?
    let schedaTecnicaRef: DatabaseReference = Database.database().reference().child("qualita")
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let articoloItem = produzioneLotto?.codiceProdotto
        articoloLotto.text = articoloItem!
        let lottoItem = produzioneLotto?.lotto
        lotto.text =  lottoItem!
        schedaTecnicaRef.child(lottoItem!).observe(.value) { (snap) in
           
            guard let schedaTecnica = snap.value as? [String: Any] else {
                print ("scheda tecnica per il lotto non trovata")
                return
            }
            if let pvc = schedaTecnica["PVC"] {
                self.pvcLotto.text = String(describing: pvc)
            }
        
            if let pe = schedaTecnica["PE"] {
                self.peLotto.text = String(describing: pe)
            }
        
            if let metalli = schedaTecnica["Metalli"] {
                self.metalliLotto.text = String(describing: metalli)
            }
       
            if let altriColori = schedaTecnica["Altri Colori"] {
            self.altriColoriLotto.text = String(describing: altriColori)
            }
                
            if let ingiallimento = schedaTecnica["Ingiallimento"] {
                self.ingiallimentoLotto.text = String(describing: ingiallimento)
            }
        
            if let approvato = schedaTecnica["Approvato"] {
                self.approvatoLotto.text = String(describing: approvato)
            }
        
            if let note = schedaTecnica["Note"] {
                self.noteLotto.text = String(describing: note)
            }
            
            if let colle = schedaTecnica["Colle"] {
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
        
        let schedaTecnicaAggiornata = ["PVC": pvcLotto.text, "PE": peLotto.text,"Metalli": metalliLotto.text, "Ingiallimento": ingiallimentoLotto.text, "Altri colori": altriColoriLotto.text, "Colla": collaLotto.text, "Note": noteLotto.text, "Approvato": approvatoLotto.text]
        
        schedaTecnicaRef.child(lotto.text!).setValue(schedaTecnicaAggiornata)
    }
}
