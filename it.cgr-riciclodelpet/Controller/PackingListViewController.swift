//
//  PackingListViewController.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 25/02/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//

import UIKit
import Firebase
import WebKit
import FirebaseDatabase





class PackingListViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    let packingListDatabaseRef: DatabaseReference = Database.database().reference().child("packinglist")
    
    var packingList = [PackingList]()
    var packingListFiltrata = [PackingList]()
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSearchbar()
        
        packingListDatabaseRef.observe(.value) { (snapShot) in
            self.packingList = []
            self.packingListFiltrata = []
            for item in snapShot.children {
                
                let firebaseData = item as! DataSnapshot
                let id = firebaseData.key
                let packingListFirebase = firebaseData.value as! [String: Any]
                let barCodeArray: [String] = packingListFirebase["QRCodeLista"] as! [String]
                //let idData: String = packingListFirebase["IdData"] as! String
                let ddtData: String = packingListFirebase["DdtData"] as! String
                let ddt: String = packingListFirebase["DdtNumero"] as! String
                var listaColli = [ItemProdottoFinito]()
                for qrCode in barCodeArray {
                    
                    let QrCodeItemSpedito = CodiceBarra(barCode: qrCode)
                    if let itemSpedito = QrCodeItemSpedito.riconosciQrCode() {
                    listaColli.append(itemSpedito)
                    }
                }
                let autore = Auth.auth().currentUser!.email
                let myPackingList = PackingList(autore: autore!, identificativo: id, ddtCollegato: ddt, annoDdtCollegato: ddtData, listaColli: listaColli)
                self.packingList.append(myPackingList)
                self.packingListFiltrata = self.packingList
                self.tableView.reloadData()
                
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
        return packingListFiltrata.count
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let stampa = stampaPackingList(at: indexPath)
        return UISwipeActionsConfiguration(actions: [stampa])
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PackingListCell", for: indexPath)
        let item = packingListFiltrata[indexPath.row]
        
        /*
         //Eventuali controlli nella scheda tecnica
         qualitaDatabaseRef.child(item.lotto).observe(.value) { (snap) in
            guard let schedaTecnica = snap.value as? [String: Any]
                else {
                    cell.detailTextLabel?.text = String(item.calcoloQuantitaLotto(dettaglioLotto: item.quantity)) + " Kg, " + String(item.quantity.count) + " colli" + ", Approvato: Scheda tecnica mancante "
                    return
                    
            }
            
            guard let approvato = schedaTecnica["Approvato"] else {return}
            cell.detailTextLabel?.text = String(item.calcoloQuantitaLotto(dettaglioLotto: item.quantity)) + " Kg, " + String(item.quantity.count) + " colli" + ", Approvato: " + String(describing: approvato)
        }*/
        if let ddt = item.ddtCollegato, let anno = item.annoDdtCollegato {
            cell.textLabel?.text = "N. " + item.identificativo + " - Ddt N.: " + String(ddt) + " del " + String(anno)
        }
        else {
        cell.textLabel?.text = item.identificativo + ", " + "D.d.t non collegato"
        }
        cell.detailTextLabel?.text = "N.Colli: " + String(describing: item.listaColli!.count) + ", Kg Totali: " + String(item.sommaKgPackingList())
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "dettaglioPackingListSegue", sender: packingListFiltrata[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue , sender: Any? ) {
        if segue.identifier == "dettaglioPackingListSegue" {
            let vc = segue.destination as! InsertPackingListViewController
            vc.dettaglioPackingList = sender as? PackingList
        }
        if segue.identifier == "idSeguePresentPreview" {
           
            let vc = segue.destination as! PackingListPreviewController
            vc.packingListInfo = sender as! PackingList
            
        }
    }
    /*
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "schedaTecnicaSegue", sender: listaProduzioneFiltrata[indexPath.row])
    }
    */
    
    
    
    
    
    // Override to support conditional editing of the table view.
   /* override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        
        return true
        
    }
   */
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let deleteItem = packingListFiltrata[indexPath.row]
            self.packingListFiltrata.remove(at: indexPath.row)
            self.packingListDatabaseRef.child(deleteItem.identificativo).removeValue()
            
            
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
            
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
            packingListFiltrata = packingList
            tableView.reloadData()
            return
        }
        packingListFiltrata = packingList.filter { (lottoProduzione) -> Bool in
            
            return (lottoProduzione.annoDdtCollegato?.lowercased().contains(searchText.lowercased()))!
        }
        tableView.reloadData()
    }
    
   
    @IBAction func aggiungiPackingList(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "dettaglioPackingListSegue", sender: PackingList(autore: (Auth.auth().currentUser?.email)!, identificativo: String(calcolaid()), ddtCollegato: nil, annoDdtCollegato: nil, listaColli: []))
            
        }
    func calcolaid() -> Int {
        var a = 0
        for item in packingList {
            if Int(item.identificativo)! > a { a = Int(item.identificativo)!}
        }
        return a + 1
    }
    
    func stampaPackingList(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "stampa") { (action, view, completion) in
            
            // stampare il modello pdf da html
            
            //MARK: visualizzare in nuovo UIWebViewController il packing list
            self.performSegue(withIdentifier: "idSeguePresentPreview", sender: self.packingList[indexPath.row])
            completion(true)
        
            
        }
        return action
    }
    
    
}

