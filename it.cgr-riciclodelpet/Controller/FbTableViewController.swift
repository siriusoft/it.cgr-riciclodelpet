
//
//  FbTableViewController.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 29/12/17.
//  Copyright © 2017 Alberto Rimini. All rights reserved.
//

import UIKit
import Firebase
import WebKit
import FirebaseDatabase





class FbTableViewController: UITableViewController, UISearchBarDelegate {

    var codificaLotto: String?
    @IBOutlet weak var searchBar: UISearchBar!
    
    

    let prodDettaglioDatabaseRef: DatabaseReference = Database.database().reference().child("produzionedettaglio")
    let qualitaDatabaseRef: DatabaseReference = Database.database().reference().child("qualita")
    let quantitaDatabaseRef: DatabaseReference = Database.database().reference().child("quantita")
    var listaProduzione = [DettaglioProduzione]()
    var listaProduzioneFiltrata = [DettaglioProduzione]()
    var listaRicetta = [ItemRicetta]()
    var listaRicettaFiltrata = [ItemRicetta]()
    var userID = ""
    
   
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSearchbar()
        let fineQuery = codificaLotto! + "Z"
       
        prodDettaglioDatabaseRef.queryOrderedByKey().queryStarting(atValue: codificaLotto!).queryEnding(atValue: fineQuery).observe(.value) { (snapShot) in
            self.listaProduzione = []
            self.listaProduzioneFiltrata = []
            self.listaRicetta = []
            self.listaRicettaFiltrata = []
            
            for item in snapShot.children {
                // carico da Firebase i dati della classe Dettaglio Produzione
                let firebaseData = item as! DataSnapshot
                let lotto = firebaseData.key
                //print(lotto)
                let lottoProduzione = firebaseData.value as! [String: Any]
                let codiceProdotto: String = String(describing: lottoProduzione["Articolo"]!)
                let umisura = "Kg"
                let lavorazione: String = String(describing: lottoProduzione["Lavorazione"]!)
                let noteArray: [String] = lottoProduzione["Dettaglionota"]! as! [String]
                let quantityArray: [Int] = lottoProduzione["Dettaglioquantita"] as! [Int]
                let taraArray: [Int] = lottoProduzione["Dettagliotara"] as! [Int]
                let dataArray: [String] = lottoProduzione["Dettagliotempo"]! as! [String]
                
                // carico da Firebase i dati della classe ItemRicetta
                
                
                let ricettaDatabase: DatabaseReference = Database.database().reference().child("ricetta").child(lotto)
                ricettaDatabase.observe(.value) { (snapShot) in
                 
                        
                        let firebaseData = snapShot
                        
                        // let lotto = firebaseData.key
                        if let lottoRicetta = firebaseData.value as? [String: Any] {
                            let articoloArray: [String] = lottoRicetta["articoloricetta"]! as! [String]
                            let fornitoreArray: [String] = lottoRicetta["fornitorericetta"]! as! [String]
                            let lottoArray: [String] = lottoRicetta["lottoricetta"]! as! [String]
                            let noteArray: [String] = lottoRicetta["notaricetta"]! as! [String]
                            let quantityArray: [Int] = lottoRicetta["quantitaricetta"] as! [Int]
                            let colliArray: [Int] = lottoRicetta["numerocolliricetta"] as! [Int]
                            let completedArray: [String] = lottoRicetta["completedricetta"]! as! [String]
                            //let userID = Auth.auth().currentUser!.uid
                            
                            let ricettaLotto = ItemRicetta(lottoPf: lotto, articolo: articoloArray, fornitore: fornitoreArray, lotto: lottoArray, quantityKg: quantityArray, quantityColli: colliArray, note: noteArray, completed: completedArray)
                            //print("la ricetta è \(String(describing: ricettaLotto.articolo))")
                            self.listaRicetta.append(ricettaLotto)
                        }
               
                    }
               
                
               let handle = self.quantitaDatabaseRef.child(lotto).child("operatore").observe(.value, with: { data in
                guard let operatore = data.value as? String else { return }
                let lottoProdotto = DettaglioProduzione(lotto: lotto, umisura: umisura, codiceProdotto: codiceProdotto, quantity: quantityArray, tara: taraArray, note: noteArray, lavorazione: lavorazione, dataLavorazione: dataArray, produttore: operatore)
                
                
                
                
              
                self.listaProduzione.append(lottoProdotto)
                
                self.listaProduzioneFiltrata = self.listaProduzione
                self.tableView.reloadData()
                    
                })
                self.quantitaDatabaseRef.removeObserver(withHandle: handle)
                
                
                
            }   
  
        }

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
      //  self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    private func setUpSearchbar() {
        searchBar.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return listaProduzioneFiltrata.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoListCell", for: indexPath)
        let item = listaProduzioneFiltrata[indexPath.row]
        qualitaDatabaseRef.child(item.lotto).observe(.value) { (snap) in
            guard let schedaTecnica = snap.value as? [String: Any]
                else {
                    cell.detailTextLabel?.text = String(item.calcoloQuantitaLotto(dettaglioLotto: item.quantity)) + " Kg, " + String(item.quantity.count) + " colli" + ", Approvato: Scheda tecnica mancante "
                        return
                        
                }
            
            guard let approvato = schedaTecnica["Approvato"] else {return}
            cell.detailTextLabel?.text = String(item.calcoloQuantitaLotto(dettaglioLotto: item.quantity)) + " Kg, " + String(item.quantity.count) + " colli" + ", Approvato: " + String(describing: approvato)
        }
        cell.textLabel?.text = item.lotto + ", " + item.codiceProdotto + ", " + item.lavorazione
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "dettaglioSegue", sender: listaProduzioneFiltrata[indexPath.row])
    }
    
    
    override func prepare(for segue: UIStoryboardSegue , sender: Any? ) {
        if segue.identifier == "dettaglioSegue" {
            let vc = segue.destination as! InsertDataViewController
            vc.produzioneLotto = sender as? DettaglioProduzione
            vc.codificaLotto = codificaLotto!
        }
        if segue.identifier == "schedaTecnicaSegue" {
            let vc = segue.destination as! SchedaTecnicaViewController
            vc.produzioneLotto = sender as? DettaglioProduzione
        }
        if segue.identifier == "SchedaDiProduzionePreviewSegue" {
            let vc = segue.destination as! SchedaDiProduzionePreviewController
            vc.listaProduzioneDaStampare = sender as? [DettaglioProduzione]
        }
        
    }
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "schedaTecnicaSegue", sender: listaProduzioneFiltrata[indexPath.row])
    }
    
    
     
    

   
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
       
            return true
        
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let deleteItem = listaProduzioneFiltrata[indexPath.row]
            self.listaProduzioneFiltrata.remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
            self.quantitaDatabaseRef.child(deleteItem.lotto).removeValue()
            self.prodDettaglioDatabaseRef.child(deleteItem.lotto).removeValue()
            self.qualitaDatabaseRef.child(deleteItem.lotto).removeValue()
            
           
            
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }       
    }
   
 
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            listaProduzioneFiltrata = listaProduzione
            tableView.reloadData()
            return
        }
        listaProduzioneFiltrata = listaProduzione.filter { (lottoProduzione) -> Bool in
           
            return lottoProduzione.lotto.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    
    @IBAction func aggiungiLotto(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Aggiungi Lotto", message: "Vuoi creare un nuovo lotto oppure una nuova miscela?", preferredStyle: UIAlertControllerStyle.alert)
        
        let actionNuovoLotto = UIAlertAction(title: "Nuovo Lotto", style: UIAlertActionStyle.default) { (action) in
            let userID = Auth.auth().currentUser!.uid
            
            let nuovoLotto = self.codificaLotto! + self.trasformaNomeLotto(lottonum: self.calcolaUltimoLotto()! + 1 ) + "M1"
             self.performSegue(withIdentifier: "dettaglioSegue", sender: DettaglioProduzione(lotto: nuovoLotto, umisura: "Kg", codiceProdotto: "", quantity: [], tara: [], note: [], lavorazione: "", dataLavorazione: [], produttore: userID))
            
            
        }
        
        let actionNuovaMiscela = UIAlertAction(title: "Nuova Miscela", style: UIAlertActionStyle.default) { (action) in
            let userID = Auth.auth().currentUser!.email
            let lottoNumero = self.trasformaNomeLotto(lottonum: self.calcolaUltimoLotto()!)
            let nuovaMiscela = self.codificaLotto! + lottoNumero + "M" + String(self.calcolaUltimaMiscela(lotto: lottoNumero)! + 1)
            let ultimaMiscela = self.codificaLotto! + lottoNumero + "M" + String(self.calcolaUltimaMiscela(lotto: lottoNumero)!)
            let articolo = self.calcolaArticolo(lotto: ultimaMiscela )
            self.performSegue(withIdentifier: "dettaglioSegue", sender: DettaglioProduzione(lotto: nuovaMiscela, umisura: "Kg", codiceProdotto: articolo, quantity: [], tara: [], note: [], lavorazione: "", dataLavorazione: [], produttore: userID!))
        }
        
        let actionNothing = UIAlertAction(title: "Cancella", style: UIAlertActionStyle.default) { (action) in
            
        }
        
        alertController.addAction(actionNuovoLotto)
        alertController.addAction(actionNuovaMiscela)
        alertController.addAction(actionNothing)
        
        present(alertController, animated: true, completion: nil)
    
    
        
        
        
        performSegue(withIdentifier: "dettaglioSegue", sender: DettaglioProduzione(lotto: "", umisura: "Kg", codiceProdotto: "", quantity: [], tara: [], note: [], lavorazione: "", dataLavorazione: [], produttore: ""))
       
       
    }
    
    func trasformaNomeLotto(lottonum: Int) -> String {
        var lotto = String(lottonum)
        while lotto.count < 4 {
            lotto = "0" + lotto
            print(lotto.count)
        }
       return lotto
    }
    
    func calcolaUltimoLotto() -> Int? {
        var a = 0
        
        for item in listaProduzione {
            guard let lottoLowerBound = item.lotto.range(of: codificaLotto!)?.upperBound else{ return nil }
            guard let lottoUpperBound = item.lotto.range(of: "M")?.lowerBound else{ return nil}
            let lotto = Int(String(item.lotto[lottoLowerBound..<lottoUpperBound]))
            if lotto! > a { a = lotto! }
        }
        print(a)
        return a
    }
    
    func calcolaArticolo(lotto: String ) -> String {
        for item in listaProduzione {
            if item.lotto == lotto { return item.codiceProdotto}
        }
        return ""
    }
    
    
    func calcolaUltimaMiscela(lotto: String) -> Int? {
        var a = 0
        let ultimoLotto = codificaLotto! + lotto
        let misceleDelLotto = listaProduzione.filter { (lottoProduzione) -> Bool in
            
            return lottoProduzione.lotto.lowercased().contains(ultimoLotto.lowercased())
        }
        for item in misceleDelLotto {
        
            if let miscelaBound = item.lotto.range(of: "M")?.upperBound {
                if let miscela = Int(String(item.lotto[miscelaBound])) {
                    if miscela > a { a = miscela }
                }
            }
            
        }
        print(a)
        return a
    }
    
    
    @IBAction func stampaSchedaDiProduzione(_ sender: Any) {
         let alertController = UIAlertController(title: "Stampa", message: "Vuoi creare un file .pdf o .csv?", preferredStyle: UIAlertControllerStyle.alert)
        let pdfAction = UIAlertAction(title: "Pdf", style: UIAlertActionStyle.default, handler: {
            (action : UIAlertAction!) -> Void in
            self.performSegue(withIdentifier: "SchedaDiProduzionePreviewSegue", sender: self.listaProduzioneFiltrata)
        })
        
        let csvAction = UIAlertAction(title: "Csv", style: UIAlertActionStyle.default, handler: {
            (action : UIAlertAction!) -> Void in
            self.createCSV(listaProduzione: self.listaProduzioneFiltrata)
        })
        alertController.addAction(pdfAction)
        alertController.addAction(csvAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func createCSV(listaProduzione: [DettaglioProduzione]) -> Void {
       
        let fileName = "\(AppDelegate.getAppDelegate().getDocDir())/SchedeDiProduzione\(listaProduzione.first!.lotto) \(listaProduzione.last!.lotto).csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        var csvText = "Data,Codice Prodotto,Lotto,N.BB,Kg,Tara,Lav,Operatore,Note\n"
        
        for scheda in listaProduzione {
            for i in 0..<scheda.quantity.count {
                let newLine = "\(String(describing: scheda.dataLavorazione[i])),\(scheda.codiceProdotto),\(scheda.lotto),\(i + 1),\(scheda.quantity[i]),\(scheda.tara[i]),\(scheda.lavorazione),\(scheda.produttore),\(scheda.note[i])\n"
                csvText.append(newLine)
            }
            
            
        }
        
        do {
            try csvText.write(toFile: fileName, atomically: true, encoding: String.Encoding.utf8)
            let alertController = UIAlertController(title: "Operazione terminata con successo!", message: "Il file . csv si trova nella sezione dei documenti.", preferredStyle: UIAlertControllerStyle.alert)
            let continuaAction = UIAlertAction(title: "Continua", style: UIAlertActionStyle.default, handler: {
                (action : UIAlertAction!) -> Void in
            })
            alertController.addAction(continuaAction)
            self.present(alertController, animated: true, completion: nil)
        } catch {
            
            let alertController = UIAlertController(title: "Errore", message: "Impossibile creare il file .csv:  \(error)", preferredStyle: UIAlertControllerStyle.alert)
            let continuaAction = UIAlertAction(title: "Continua", style: UIAlertActionStyle.default, handler: {
                (action : UIAlertAction!) -> Void in
            })
            alertController.addAction(continuaAction)
            self.present(alertController, animated: true, completion: nil)
            
            print("Failed to create file")
            print("\(error)")
        }
        print(path ?? "not found")
    }
}
    

