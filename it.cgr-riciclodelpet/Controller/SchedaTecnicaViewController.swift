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
    var produzioneLotto: DettaglioProduzione?
    let schedaTecnicaRef: DatabaseReference = Database.database().reference().child("qualita")
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let lottoItem = produzioneLotto?.lotto
        let articoloItem = produzioneLotto?.codiceProdotto
        articoloLotto.text = articoloItem!
        lotto.text =  lottoItem!
        schedaTecnicaRef.child(lottoItem!).observe(.value) { (snap) in
           
            guard let schedaTecnica = snap.value as? [String: Any] else {
                print ("scheda tecnica per il lotto non trovata")
                return
            }
         let pvc = String(describing: schedaTecnica["PVC"]!)
         self.pvcLotto.placeholder = pvc
         let pe = String(describing: schedaTecnica["PE"]!)
         self.peLotto.placeholder = pe
         let metalli = String(describing: schedaTecnica["Metalli"]!)
         self.metalliLotto.placeholder = metalli
         let ingiallimento = String(describing: schedaTecnica["Ingiallimento"]!)
         self.ingiallimentoLotto.placeholder = ingiallimento
         let approvato = String(describing: schedaTecnica["Approvato"]!)
         self.approvatoLotto.placeholder = approvato
         self.noteLotto.placeholder = (schedaTecnica["Note"] as! String)
            
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

}
