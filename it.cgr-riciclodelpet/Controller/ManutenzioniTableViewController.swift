//
//  ManutenzioniTableViewController.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 22/05/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//

import UIKit
import Firebase
import WebKit
import FirebaseDatabase


class ManutenzioniTableViewController: UITableViewController, UISearchBarDelegate {

   
        
    @IBOutlet weak var sceltaVisualizzazione: UISegmentedControl!
    
        @IBOutlet weak var searchBar: UISearchBar!
        
        let anagraficaLavorazioniRef: DatabaseReference = Database.database().reference().child("anagraficaLavorazioni")
        let macchinariRef: DatabaseReference = Database.database().reference().child("macchinari")
        let utilizzoMacchinariRef: DatabaseReference = Database.database().reference().child("utilizzoMacchinari")
        let manutenzioniDatabaseRef: DatabaseReference = Database.database().reference().child("listaManutenzioni")
        let quantitaDatabaseRef: DatabaseReference = Database.database().reference().child("quantita")
        var listaManutenzioni = [Manutenzione]()
        var listaManutenzioniFiltrata = [Manutenzione]()
        var listaChiaveManutenzioni = [String]()
        var listaChiaveManutenzioniFiltrata = [String]()
    
        var listaUltimaManutenzione = [Manutenzione]()
        var listaUltimaManutenzioneFiltrata = [Manutenzione]()
        var listaRitardoManutenzione = [Int]()

        var userID = ""
        var actualTextField: UITextField?
        var dataManutenzione: String = ""
        
        
    
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setUpSearchbar()
            sceltaVisualizzazione.addTarget(self, action: #selector(segmentedControlValueChanged), for:.valueChanged)
            sceltaVisualizzazione.addTarget(self, action: #selector(segmentedControlValueChanged), for:.touchUpInside)
           
            
            
            manutenzioniDatabaseRef.observe(.value) { (snapShot) in
                //print(snapShot)
                self.listaManutenzioni = []
                self.listaManutenzioniFiltrata = []
                /*self.listaRicetta = []
                self.listaRicettaFiltrata = []*/
                
                for item in snapShot.children {
                    // carico da Firebase i dati della classe Dettaglio Produzione
                    let firebaseData = item as! DataSnapshot
                    let chiave = firebaseData.key
                    //print(lotto)
                    let myManutenzione = firebaseData.value as! [String: Any]
                    let codiceMacchinario: String = String(describing: myManutenzione["codiceMacchinario"]!)
                    let dataManutenzioneString: String = String(describing: myManutenzione["dataManutenzione"]!)
                    let descrizioneManutenzione: String = String(describing: myManutenzione["descrizioneManutenzione"]!)
                    let autore: String = String(describing: myManutenzione["autore"]!)
                    let note: String = String(describing: myManutenzione["note"]!)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd/MM/yy HH:mm"
                    let dataManutenzione = dateFormatter.date(from: dataManutenzioneString)!
                    let manutenzioneFirebase = Manutenzione(codiceMacchinario: codiceMacchinario, descrizioneManutenzione: descrizioneManutenzione, autore: autore, dataManutenzione: dataManutenzione, note: note)
                  
                    self.listaChiaveManutenzioni.append(chiave)
                    self.listaManutenzioni.append(manutenzioneFirebase)
                    self.listaManutenzioniFiltrata = self.listaManutenzioni
                    self.listaChiaveManutenzioniFiltrata = self.listaChiaveManutenzioni
                    self.tableView.reloadData()
                    
                }
                
                // inizio CALCOLA LE MANUTENZIONI SCADUTE aggiunte in listaRitardoManutenzione
                for item in self.listaManutenzioni {
                    
                    self.utilizzoMacchinariRef.child(item.codiceMacchinario).observe(.value, with: { (data) in
                        
                        if let dataValue = data.value as? [String: Any] {
                            if let listaLavorazioni: [String] = dataValue["ListaLavorazioni"] as? [String] {
                                if item.dataManutenzione == self.calcolaDataUltimaManutenzione(codiceMacchinario: item.codiceMacchinario, descrizioneManutenzione: item.descrizioneManutenzione) {
                                    self.controllaFrequenzaManutenzione(codiceMacchinario: item.codiceMacchinario, descrizioneManutenzione: item.descrizioneManutenzione, completionHandler2:   { (frequenza) in
                                    print("la frequenza di \(item.descrizioneManutenzione) per il macchinario \(item.codiceMacchinario) è: \(frequenza)")
                                        item.calcolaProduzioneDaUltimaManutenzione(listaLavorazioni: listaLavorazioni, completionHandler: { (somma) in
                                    print("la somma di \(item.descrizioneManutenzione) per il macchinario \(item.codiceMacchinario) è: \(somma)")
                                            if somma >= frequenza {
                                                self.listaUltimaManutenzione.append(item)
                                                self.listaRitardoManutenzione.append(somma-frequenza)
                                            }
                                        })
                                    })
                                }
                            }
                        }
                    })
                }
               // fine CALCOLA LE MANUTENZIONI SCADUTE aggiunte in listaRitardoManutenzione
            }
            
           
            
            
            // Uncomment the following line to preserve selection between presentations
            // self.clearsSelectionOnViewWillAppear = false
            
            // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
            //  self.navigationItem.rightBarButtonItem = self.editButtonItem
        }
        
    @objc func segmentedControlValueChanged(segment: UISegmentedControl) {
        if sceltaVisualizzazione.selectedSegmentIndex == 1 {
            searchBar.isHidden = true
        }   else { searchBar.isHidden = false }
            tableView.reloadData()
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
            if sceltaVisualizzazione.selectedSegmentIndex == 0 {
              return listaManutenzioniFiltrata.count
            }
            else {
                return listaUltimaManutenzione.count
            }
            
        }
        
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if sceltaVisualizzazione.selectedSegmentIndex == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "manutenzioneCell", for: indexPath)
                let item = listaManutenzioniFiltrata[indexPath.row]
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yy HH:mm"
                let dataManutenzioneString = dateFormatter.string(from: item.dataManutenzione)
                cell.detailTextLabel?.text =  dataManutenzioneString + ", note: " + String(item.note)
                cell.textLabel?.text = item.codiceMacchinario  + ", " + item.descrizioneManutenzione
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "manutenzioneCell", for: indexPath)
                let item = listaUltimaManutenzione[indexPath.row]
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yy HH:mm"
                let dataManutenzioneString = dateFormatter.string(from: item.dataManutenzione)
                cell.detailTextLabel?.text =  "Ultima Manutenzione: " + dataManutenzioneString + ", in ritardo di " + String(listaRitardoManutenzione[indexPath.row]) + " Kg"
                cell.textLabel?.text = item.codiceMacchinario + ": " + item.descrizioneManutenzione
                return cell
                
            }
        }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if sceltaVisualizzazione.selectedSegmentIndex == 1 {
            
            
            let alertController = UIAlertController(title: "Inserisci Manutenzione", message: "", preferredStyle: UIAlertControllerStyle.alert)
            
            
            
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Inserisci Data Manutenzione"
                let datePickerView:UIDatePicker = UIDatePicker()
                
                datePickerView.datePickerMode = UIDatePickerMode.dateAndTime
                datePickerView.locale =  NSLocale(localeIdentifier: "it_IT") as Locale
                textField.inputView = datePickerView
                self.actualTextField = textField
                datePickerView.addTarget(self, action: #selector(self.dataPickerValueChanged), for: UIControlEvents.valueChanged)
                
                
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yy HH:mm"
                self.dataManutenzione = dateFormatter.string(from: datePickerView.date)
                textField.text = self.dataManutenzione
                
            }
            
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Inserisci Nota"
            }
            
            let saveAction = UIAlertAction(title: "Salva", style: UIAlertActionStyle.default, handler: { alert -> Void in
                
                
                let dataManutenzione = alertController.textFields![0] as UITextField
                let notaManutenzione = alertController.textFields![1] as UITextField
                let userID = Auth.auth().currentUser!.email
                let nuovaManutenzione = ["codiceMacchinario": self.listaUltimaManutenzione[indexPath.row].codiceMacchinario, "descrizioneManutenzione": self.listaUltimaManutenzione[indexPath.row].descrizioneManutenzione, "autore": userID ?? "Ignoto", "dataManutenzione": dataManutenzione.text!, "note": notaManutenzione.text ?? ""]
                let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
                activityIndicator.startAnimating()
                activityIndicator.center = self.view.center
                self.view.addSubview(activityIndicator)
                
                self.manutenzioniDatabaseRef.childByAutoId().setValue(nuovaManutenzione)
                
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                _ = self.navigationController?.popViewController(animated: true)
                //self.salvaMacchinario(self)
                self.tableView.reloadData()
                
            })
            
            let cancelAction = UIAlertAction(title: "Annulla", style: UIAlertActionStyle.default, handler: {
                (action : UIAlertAction!) -> Void in })
            
            
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        
        
          //  performSegue(withIdentifier: "dettaglioSegue", sender: listaManutenzioniFiltrata[indexPath.row])
    }
        
        
        
      override func prepare(for segue: UIStoryboardSegue , sender: Any? ) {
            if segue.identifier == "dettaglioMacchinarioSegue" {
                let vc = segue.destination as! InsertMacchinarioViewController
                vc.anagraficaMacchinario = sender as? AnagraficaMacchinario
               
            }
        
            
        }
    
        override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
            var macchinario: String? = nil
            if sceltaVisualizzazione.selectedSegmentIndex == 0 {
                macchinario = listaManutenzioniFiltrata[indexPath.row].codiceMacchinario
            } else {
                macchinario = listaUltimaManutenzione[indexPath.row].codiceMacchinario
            }
            
            let handle = self.macchinariRef.child(macchinario!).observe(.value, with: { data in
                guard let listaMacchinariFirebase = data.value as? [String: Any] else { return }
                
                let descrizione: String = listaMacchinariFirebase["Descrizione"] as! String
                let fotoUrl: String = listaMacchinariFirebase["FotoURL"] as! String
                let codice: String = listaMacchinariFirebase["Codice"] as! String
                let codiceGenitore: String = listaMacchinariFirebase["CodiceGenitore"] as! String
                let listaManutenzioni = listaMacchinariFirebase["ListaManutenzioni"] as? [String]
                let listaFrequenzaManutenzioni = listaMacchinariFirebase["ListaFrequenzaManutenzioni"] as? [Int]
                let listaCaratteristiche = listaMacchinariFirebase["ListaCaratteristiche"] as? [String]
                
                
                let myMacchinario = AnagraficaMacchinario(codice: codice, descrizione: descrizione, codiceGenitore: codiceGenitore, fotoUrl: fotoUrl, listaCaratteristiche: listaCaratteristiche, listaManutenzioni: listaManutenzioni, listaFrequenzaManutenzioni: listaFrequenzaManutenzioni)
                
                self.performSegue(withIdentifier: "dettaglioMacchinarioSegue", sender: myMacchinario)
            })
            self.macchinariRef.removeObserver(withHandle: handle)
            
            
           
        }
        
        
        
        
        
        
        // Override to support conditional editing of the table view.
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            // Return false if you do not want the specified item to be editable.
            
            return true
            
        }
        
        
        
        // Override to support editing the table view.
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                if sceltaVisualizzazione.selectedSegmentIndex == 0 {
                //let deleteItem = listaManutenzioniFiltrata[indexPath.row]
                let chiaveToDelete = listaChiaveManutenzioniFiltrata[indexPath.row]
                self.listaManutenzioniFiltrata.remove(at: indexPath.row)
                
                // Delete the row from the data source
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadData()
                searchBar.text = nil
                // CANCELLARE DA FIREBASE DATABASE
               self.manutenzioniDatabaseRef.child(chiaveToDelete).removeValue()
                }
                
                
                
                
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
        
        func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {

            filtraSearchBar()
        }
    
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            filtraSearchBar()
            
        }
    
        func filtraSearchBar() {
            listaChiaveManutenzioniFiltrata = []
            listaManutenzioniFiltrata = []
            guard let searchText = searchBar.text else {return}
            guard  !searchText.isEmpty else {
                listaManutenzioniFiltrata = listaManutenzioni
                listaChiaveManutenzioniFiltrata = listaChiaveManutenzioni
                tableView.reloadData()
                return
            }
            
           
            let listaManutenzioniEnumerated = listaManutenzioni.enumerated().filter { (index,manutenzione) -> Bool in
                if searchBar.selectedScopeButtonIndex == 0 {

                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd/MM/yy HH:mm"
                    let dateString = formatter.string(from: manutenzione.dataManutenzione)
                    return dateString.contains(searchText.lowercased())
                }
                else {
                    return manutenzione.codiceMacchinario.lowercased().contains(searchText.lowercased())
                }
                
            }
            for (index, element) in listaManutenzioniEnumerated {
                listaChiaveManutenzioniFiltrata.append(listaChiaveManutenzioni[index])
                listaManutenzioniFiltrata.append(element)
            }
            print(listaChiaveManutenzioniFiltrata)
            tableView.reloadData()
        }
    
    @objc func dataPickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy HH:mm"
        actualTextField?.text = dateFormatter.string(from: sender.date)
        
        
    }
        
        
        
            
    func calcolaDataUltimaManutenzione(codiceMacchinario: String, descrizioneManutenzione: String) -> Date {
        
        let listaFiltrataCodice = listaManutenzioni.filter { (filtro) -> Bool in
            
            return filtro.codiceMacchinario.lowercased().elementsEqual(codiceMacchinario.lowercased())
            //return filtro.codiceMacchinario.lowercased().contains(codiceMacchinario.lowercased())
        }
            
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy HH:mm"
        var ultimaData = dateFormatter.date(from: "01/01/01 00:00") as! Date
    
        let listaFiltrata = listaFiltrataCodice.filter { (lottoProduzione) -> Bool in
             return lottoProduzione.descrizioneManutenzione.lowercased().elementsEqual(descrizioneManutenzione.lowercased())
            //return lottoProduzione.descrizioneManutenzione.lowercased().contains(descrizioneManutenzione.lowercased())
        }
            
        for item in listaFiltrata {
                
            if item.dataManutenzione > ultimaData {
                    ultimaData = item.dataManutenzione }
            }
        return ultimaData
    }
            
        func controllaFrequenzaManutenzione(codiceMacchinario: String, descrizioneManutenzione: String, completionHandler2:@escaping (Int) -> ()) {
            var frequenza = 0
            self.macchinariRef.child(codiceMacchinario).observe(.value) { (snapShot) in
                
                let firebaseData = snapShot
                let datiManutenzione = firebaseData.value as! [String: Any]
               
                guard let frequenzaManutenzioni: [Int] = datiManutenzione["ListaFrequenzaManutenzioni"] as? [Int] else {
                    print("Per il macchinario \(codiceMacchinario) la manutenzione: \(descrizioneManutenzione) non è in programma")
                    
                                return }
                guard let listaManutenzioni:[String] = datiManutenzione["ListaManutenzioni"] as? [String] else {return}
                
                var index = 0
                for item in listaManutenzioni {
                    if item == descrizioneManutenzione {
                        frequenza = frequenzaManutenzioni[index]
                    }
                    index += 1
                    
                }
               completionHandler2(frequenza)
            }
            
            
        }
           
      
        
    
}


