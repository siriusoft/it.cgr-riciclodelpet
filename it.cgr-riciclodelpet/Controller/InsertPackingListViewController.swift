//
//  InsertPackingListViewController.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 06/03/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//


    
    import UIKit
    import Firebase
class InsertPackingListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ShowPackingList {
    
    func AddItemtoPackingList(dettaglioPackingList: PackingList) {
        tableView.reloadData()
    }
    
        
        
        var dettaglioPackingList: PackingList?
        
        @IBOutlet weak var dataLabel: UITextField!
        
        
        
        @IBOutlet weak var idLabel: UITextField!
        @IBOutlet weak var dataIdLabel: UITextField!
        @IBOutlet weak var ddtLabel: UITextField!
        @IBOutlet weak var ddtDataLabel: UITextField!
    
        @IBOutlet weak var tableView: UITableView!
        
        
        
        var somma: Int = 0
        
        
        let packingListDatabaseRef: DatabaseReference = Database.database().reference().child("packinglist")
        
        
        
        
        
        
        
        
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.hideKeyboardWhenTappedAround()
            // articoloPickerList = ["PETSA1TPC01","PETSN1TPC01","PETSF1TPC01"]
            
            let leftSwipe = UISwipeGestureRecognizer(target: self, action:  #selector(swipeAction(swipe:)))
            leftSwipe.direction = UISwipeGestureRecognizerDirection.left
            self.view.addGestureRecognizer(leftSwipe)
            
            
            if let id =  dettaglioPackingList?.identificativo { idLabel.text = id }
            if let ddt = dettaglioPackingList?.ddtCollegato { ddtLabel.text = ddt }
            if let ddtData = dettaglioPackingList?.annoDdtCollegato { ddtDataLabel.text = ddtData}
            
            
        }
        
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PackingListCell", for: indexPath as IndexPath)
            let listaColli = dettaglioPackingList?.listaColli
            let item = listaColli![indexPath.row]
            
            cell.textLabel?.text = "N. \(indexPath.row + 1) - " +   String(describing: item.codice)  + ", \(String(describing: item.lotto)), BB: \(String(describing: item.numeroBb))"
            cell.detailTextLabel!.text = "N.:" + String(describing: item.quantityKg) + " Kg, T:" + String(describing: item.taraKg) + " Kg"
            return cell
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            // #warning Incomplete implementation, return the number of rows
            if let numeroRighe = dettaglioPackingList?.listaColli?.count {
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
                
                self.dettaglioPackingList?.listaColli?.remove(at: indexPath.row)
                
                // Delete the row from the data source
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadData()
                
            } else if editingStyle == .insert {
                // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            }
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
        }
        
        /*
         // Override to support rearranging the table view.
         override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
         
         }
         */
        
        
        // Override to support conditional rearranging of the table view.
        func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
            // Return false if you do not want the item to be re-orderable.
            return false
        }
        
        
        
        
        func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
            
            
        }
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        
        
        
        
        @IBAction func dataEditing(_ sender: UITextField) {
            let datePickerView:UIDatePicker = UIDatePicker()
            
            datePickerView.datePickerMode = UIDatePickerMode.date
            datePickerView.locale =  NSLocale(localeIdentifier: "it_IT") as Locale
            sender.inputView = datePickerView
            datePickerView.addTarget(self, action: #selector(self.datePickerValueChanged), for: UIControlEvents.valueChanged)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yy"
            sender.text = dateFormatter.string(from: datePickerView.date)
        }
        
        @objc func datePickerValueChanged(sender:UIDatePicker) {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yy"
            
           //
            if dataLabel.isEditing { dataLabel.text = dateFormatter.string(from: sender.date) }
            if ddtDataLabel.isEditing {ddtDataLabel.text = dateFormatter.string(from: sender.date)}
            
        }
        
        
        @IBAction func startEditing(_ sender: UIBarButtonItem) {
            tableView.isEditing = !tableView.isEditing
        }
        
        @IBAction func inserisciDati(_ sender: Any) {
            
            let id = idLabel.text!
            let dataId = dataIdLabel.text!
            let autore = Auth.auth().currentUser!.email
            let ddt = ddtLabel.text
            let ddtData = ddtDataLabel.text
            var qrCodeLista = [String]()
            let lista = dettaglioPackingList?.listaColli
            if lista!.count > 0 {
                for item in lista! {
                let qrCode = item.codiceBarra
                qrCodeLista.append(qrCode)
                }
                packingListDatabaseRef.child(id).setValue(["QRCodeLista": qrCodeLista , "Autore": autore!, "DdtNumero": ddt!, "DdtData": ddtData!, "IdData": dataId])
            } else {print("Non si può salvare un packing list vuoto")}
                    
            
        }
        
        
        
        // MARK: - Navigation
        
       @IBAction func ricettaAdd(_ sender: Any) {
        
            let predicate2 = { (element: ItemProdottoFinito) in
            return element.lotto
            }
        
            let array = dettaglioPackingList!.listaColli!
            var listaArticoliPerDdt = [Articolo]()
        
            let lottoDictionary = Dictionary(grouping: array,by: predicate2)
            for (lotto,items) in lottoDictionary {
                var totale = 0
                var totaleTara = 0
                var i = 0
                var codice = ""
                for item in items {
                    
                    totale += item.quantityKg
                    i += 1
                    codice = item.codice
                    totaleTara += item.taraKg
                }
                
                let articolo = Articolo(articolo: codice ,lotto: lotto, kg: totale, colli: i, tara: totaleTara)
                listaArticoliPerDdt.append(articolo)
            }
            performSegue(withIdentifier: "ddtSegue", sender: listaArticoliPerDdt)
        }
       
        
        // In a storyboard-based application, you will often want to do a little preparation before navigation
        
        
        func stampaEtichetta(at indexPath: IndexPath) -> UIContextualAction {
            let action = UIContextualAction(style: .normal, title: "stampa") { (action, view, completion) in
                
                let item = self.dettaglioPackingList!.listaColli![indexPath.row]
                let codiceBarraTesto = "I%\(String(describing: item.codice))L%\(String(describing: item.lotto))N%\(item.numeroBb)Q%\(item.quantityKg)T%\(item.taraKg)F%"
                self.performSegue(withIdentifier: "stampaEtichettaBisSegue", sender: codiceBarraTesto)
                
                completion(true)
                
                
            }
            return action
        }
        
        @objc func swipeAction(swipe: UISwipeGestureRecognizer) {
            switch swipe.direction.rawValue {
            case 1:
                
                performSegue(withIdentifier: "scannerSegue", sender: dettaglioPackingList/*?.listaColli*/)
            case 2:
                
            performSegue(withIdentifier: "scannerSegue", sender: dettaglioPackingList/*?.listaColli*/)
            default:
                break
            }
        }
        
        override func prepare(for segue: UIStoryboardSegue , sender: Any? ) {
            if segue.identifier == "scannerSegue" {
                let vc = segue.destination as! ScannerViewController
                vc.packingListCompleto = sender as? PackingList
                vc.delegate = self
                
            }
            if segue.identifier == "stampaEtichettaBisSegue" {
                
                let vc = segue.destination as! EtichettaViewController
                vc.codiceBarraTesto = sender as? String
            }
            
            if segue.identifier == "ddtSegue" {
                
                let vc = segue.destination as! DdtTableViewController
                vc.ddtList = sender as? [Articolo]
            }
            
        }


}

