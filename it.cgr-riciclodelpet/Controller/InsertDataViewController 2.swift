//
//  InsertDataViewController.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 08/01/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//

import UIKit
import Firebase
class InsertDataViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var dataLabel: UITextField!

    
    
    @IBOutlet weak var lavorazioneLabel: UITextField!
    @IBOutlet weak var noteLabel: UITextField!
    @IBOutlet weak var taraLabel: UITextField!
    @IBOutlet weak var miscelaLabel: UITextField!
    @IBOutlet weak var lottoLabel: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var articoloLabel: UITextField!
    @IBOutlet weak var quantityLabel: UITextField!
    
    var produzioneLotto: DettaglioProduzione?

    var somma: Int = 0
    var articoloPickerList: [String] = [String]()
    
    let anagraficaArticoliDatabaseRef: DatabaseReference = Database.database().reference().child("anagraficaArticoli")
    let anagraficaLavorazioniDatabaseRef: DatabaseReference = Database.database().reference().child("anagraficaLavorazioni")
    var listaArticoliCodice = [String]()
    var listaLavorazioniCodice = [String]()
    var listaArticoliDescrizioneSintetica = [String]()
    var codificaLotto: String?
    
    
    
    
    
        
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        // articoloPickerList = ["PETSA1TPC01","PETSN1TPC01","PETSF1TPC01"]
        
        
         // CARICO DA FIREBASE GLI ARTICOLI PER PICKER VIEW
        
        anagraficaArticoliDatabaseRef.observe(.value) { (snapShot) in
            self.listaArticoliCodice = []
            self.listaArticoliDescrizioneSintetica = []
            for item in snapShot.children {
                
                let firebaseData = item as! DataSnapshot
                let codiceArticolo = firebaseData.key
                
                let anagraficaArticolo = firebaseData.value as! [String: Any]
                //let descrizioneEstesa: String = String(describing: anagraficaArticolo["DescrizioneEstesa"]!)
                let descrizioneSintetica: String = String(describing: anagraficaArticolo["DescrizioneSintetica"]!)
                let autore: String = String(describing: anagraficaArticolo["Autore"]!)
                let codiceAttivo: String = String(describing: anagraficaArticolo["CodiceAttivo"]!)
                
                if codiceAttivo == "Si" {
                    self.listaArticoliCodice.append(codiceArticolo)
                    self.listaArticoliDescrizioneSintetica.append(descrizioneSintetica)
                    
                }
                
                
                
            }
            
        }
        // CARICO DA FIREBASE LE LAVORAZIONI PER PICKER VIEW
        anagraficaLavorazioniDatabaseRef.queryOrdered(byChild: "Reparto").queryStarting(atValue: codificaLotto!).queryEnding(atValue: codificaLotto!).observe(.value) { (snapShot) in
            self.listaLavorazioniCodice = []
        
            for item in snapShot.children {
                
                let firebaseData = item as! DataSnapshot
                let codiceLavorazione = firebaseData.key
                self.listaLavorazioniCodice.append(codiceLavorazione)
                
            }
        }
        
        
        let lavorazionePicker = UIPickerView()
        lavorazionePicker.delegate = self
        lavorazionePicker.tag = 1
        lavorazioneLabel.inputView = lavorazionePicker
        
        
        let articoloPicker = UIPickerView()
        articoloPicker.tag = 0
        articoloPicker.delegate = self
        articoloLabel.inputView = articoloPicker
        
        
        
        if let articolo =  produzioneLotto?.codiceProdotto { articoloLabel.text = articolo }
        if let lavorazione = produzioneLotto?.lavorazione { lavorazioneLabel.text = lavorazione}
        if let lotto = (produzioneLotto?.lotto) {
            if let lowerBound = lotto.range(of: codificaLotto!)?.upperBound,
                let upperBound = lotto.range(of: "M")?.lowerBound, let miscelaBound = lotto.range(of: "M")?.upperBound {
                lottoLabel.text = String(lotto[lowerBound..<upperBound])
                miscelaLabel.text = String(lotto[miscelaBound])
            }
        }
        
        lavorazioneLabel.text = produzioneLotto?.lavorazione
        
    }
   
    // MARK: UIPickerView Delegation
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return listaArticoliDescrizioneSintetica.count
        }
        else {
           return listaLavorazioniCodice.count
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView.tag == 0 {
            return listaArticoliDescrizioneSintetica[row]
        }
        else {
            return listaLavorazioniCodice[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.tag == 0 {
            articoloLabel.text = listaArticoliCodice[row]
        }
        else {
            lavorazioneLabel.text = listaLavorazioniCodice[row]
        }
    }
    
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProduzioneCell", for: indexPath as IndexPath)
        cell.textLabel?.text = "BB n. \(indexPath.row + 1) - N: " +   String(describing: produzioneLotto!.quantity[indexPath.row])  + " Kg - T: \(produzioneLotto!.tara[indexPath.row]) Kg - \(produzioneLotto!.dataLavorazione[indexPath.row])"
        cell.detailTextLabel!.text = String(describing: produzioneLotto!.note[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let numeroRighe = produzioneLotto?.quantity.count {
            return numeroRighe } else {return 0}
    }
  
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let stampa = stampaEtichetta(at: indexPath)
        return UISwipeActionsConfiguration(actions: [stampa])
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        
        return true
        
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            self.produzioneLotto?.quantity.remove(at: indexPath.row)
            self.produzioneLotto?.tara.remove(at: indexPath.row)
            self.produzioneLotto?.note.remove(at: indexPath.row)
            self.produzioneLotto?.dataLavorazione.remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        quantityLabel.text = String(describing: produzioneLotto!.quantity[indexPath.row])
        taraLabel.text = String(describing: produzioneLotto!.tara[indexPath.row])
        dataLabel.text = produzioneLotto!.dataLavorazione[indexPath.row]
        noteLabel.text = produzioneLotto!.note[indexPath.row]
        
    }
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    
     // Override to support conditional rearranging of the table view.
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
    
    
    
    
   func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        
        let quantityToMove = produzioneLotto!.quantity[fromIndexPath.row]
        produzioneLotto?.quantity.remove(at: fromIndexPath.row)
        produzioneLotto?.quantity.insert(quantityToMove, at: to.row)
        
        let taraToMove = produzioneLotto!.tara[fromIndexPath.row]
        produzioneLotto?.tara.remove(at: fromIndexPath.row)
        produzioneLotto?.tara.insert(taraToMove, at: to.row)
        
        let noteToMove = produzioneLotto!.note[fromIndexPath.row]
        produzioneLotto?.note.remove(at: fromIndexPath.row)
        produzioneLotto?.note.insert(noteToMove, at: to.row)
        
        let tempoToMove = produzioneLotto!.dataLavorazione[fromIndexPath.row]
        produzioneLotto?.dataLavorazione.remove(at: fromIndexPath.row)
        produzioneLotto?.dataLavorazione.insert(tempoToMove, at: to.row)
    
        tableView.reloadData()
    
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func inserisciCollo(_ sender: Any) {
        if let quantitaInt = Int((quantityLabel?.text)!) {
            print("inserisco la quantità")
            produzioneLotto!.quantity.append(quantitaInt)
            somma = somma + quantitaInt
        
        if let taraInt = Int((taraLabel?.text)!) {
            produzioneLotto!.tara.append(taraInt) } else {produzioneLotto!.tara.append(0)}
            
        if let nota = noteLabel.text {
            produzioneLotto!.note.append(nota) } else {  produzioneLotto?.note.append("") }
        if let tempo = dataLabel.text {
           produzioneLotto!.dataLavorazione.append(tempo)
        } else { produzioneLotto!.dataLavorazione.append("") }
        } else { print("Non è possibile aggiungere un item senza indicare la quantità")}
        print(produzioneLotto!.quantity)
        self.tableView.reloadData()
        
    }
    
  
    
    @IBAction func dataEditing(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
       
        datePickerView.datePickerMode = UIDatePickerMode.dateAndTime
        datePickerView.locale =  NSLocale(localeIdentifier: "it_IT") as Locale
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(self.datePickerValueChanged), for: UIControlEvents.valueChanged)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy HH:mm"
       
        dataLabel.text = dateFormatter.string(from: datePickerView.date)
    }
    
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy HH:mm"
        dataLabel.text = dateFormatter.string(from: sender.date)
        
    }
    
    
    @IBAction func startEditing(_ sender: UIBarButtonItem) {
        tableView.isEditing = !tableView.isEditing
    }
    
    @IBAction func inserisciDati(_ sender: Any) {
        
        if produzioneLotto!.quantity.count > 0 {
            let produzioneDettaglioRef: DatabaseReference = Database.database().reference().child("produzionedettaglio")
            let quantitaRef: DatabaseReference = Database.database().reference().child("quantita")
            let articolo = articoloLabel.text!
            let userID = Auth.auth().currentUser!.email
           
            if let lotto = lottoLabel.text {
                if let miscela = miscelaLabel.text {
                    let firebaseLotto = "\(codificaLotto!)\(lotto)M\(miscela)"
                    let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
                    activityIndicator.startAnimating()
                    activityIndicator.center = self.view.center
                    self.view.addSubview(activityIndicator)

                    produzioneDettaglioRef.child(firebaseLotto).setValue(["Articolo": articolo, "Dettaglioquantita": produzioneLotto!.quantity, "Dettaglionota": produzioneLotto!.note, "Dettagliotempo": produzioneLotto!.dataLavorazione, "Dettagliotara": produzioneLotto!.tara, "Lavorazione": lavorazioneLabel.text!])
                let ncolli = produzioneLotto!.quantity.count
                let dataFineLotto = produzioneLotto!.dataLavorazione.last
                
                    somma = produzioneLotto!.calcoloQuantitaLotto(dettaglioLotto: produzioneLotto!.quantity)
                    quantitaRef.child(firebaseLotto).setValue(["ncolli": ncolli,"quantita": somma, "operatore": userID ?? "Ignoto", "lavorazione": lavorazioneLabel.text!, "dataFineLotto": dataFineLotto!])
                    activityIndicator.stopAnimating()
                    activityIndicator.removeFromSuperview()
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            print("Impossibile aggiungere una scheda vuota")
            let alertController = UIAlertController(title: "Errore", message: "Impossibile inserire una scheda vuota", preferredStyle: UIAlertControllerStyle.alert)
            let continuaAction = UIAlertAction(title: "Continua", style: UIAlertActionStyle.default, handler: {
                (action : UIAlertAction!) -> Void in
                
            })
            alertController.addAction(continuaAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Navigation

     @IBAction func ricettaAdd(_ sender: Any) {
        
        if let lotto = lottoLabel.text {
            if let miscela = miscelaLabel.text {
                let firebaseLotto = "\(codificaLotto!)\(lotto)M\(miscela)"
              
                        print("pronto a caricare ricettaviewcontroller")
                        self.performSegue(withIdentifier: "ricettaSegue", sender: firebaseLotto)
                        
                    }
            
        }
    }
    
    
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    
       override func prepare(for segue: UIStoryboardSegue , sender: Any? ) {
                if segue.identifier == "ricettaSegue" {
                    print(" ed il segue è ok")
                    let vc = segue.destination as! InsertRicettaViewController
                    vc.firebaseLotto = sender as? String
                }
                if segue.identifier == "stampaEtichettaSegue" {
                    
                    let vc = segue.destination as! EtichettaViewController
                    vc.codiceBarraTesto = sender as? String
        }
        
        }
    
   
    
   
    
    func stampaEtichetta(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "stampa") { (action, view, completion) in
            let codiceBarraTesto = "I%\(self.produzioneLotto!.codiceProdotto)L%\(self.produzioneLotto!.lotto)N%\(indexPath.row + 1)Q%\(self.produzioneLotto!.quantity[indexPath.row])T%\(self.produzioneLotto!.tara[indexPath.row])F%"
            self.performSegue(withIdentifier: "stampaEtichettaSegue", sender: codiceBarraTesto)
            print(codiceBarraTesto)
            completion(true)
        
            
        }
        return action
    }

}
