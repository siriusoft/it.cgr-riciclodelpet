//
//  AnagraficaLavorazioniTableViewController.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 24/03/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//

import UIKit
import Firebase
import WebKit
import FirebaseDatabase



    
class AnagraficaLavorazioniTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    let anagraficaLavorazioniDatabaseRef: DatabaseReference = Database.database().reference().child("anagraficaLavorazioni")
    
    var listaLavorazioni = [AnagraficaLavorazioni]()
    var listaLavorazioniFiltrata = [AnagraficaLavorazioni]()
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSearchbar()
        
        anagraficaLavorazioniDatabaseRef.observe(.value) { (snapShot) in
            self.listaLavorazioni = []
            self.listaLavorazioniFiltrata = []
            for item in snapShot.children {
                
                let firebaseData = item as! DataSnapshot
                let codiceLavorazione = firebaseData.key
                
                let anagraficaLavorazione = firebaseData.value as! [String: Any]
                let descrizione: String = String(describing: anagraficaLavorazione["Descrizione"]!)
                let autore: String = String(describing: anagraficaLavorazione["Autore"]!)
                let Lavorazione = AnagraficaLavorazioni(codiceLavorazione: codiceLavorazione, descrizioneLavorazione: descrizione, autore: autore)
                self.listaLavorazioni.append(Lavorazione)
                
                self.listaLavorazioniFiltrata = self.listaLavorazioni
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
        return listaLavorazioniFiltrata.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LavorazioneCell", for: indexPath)
        let item = listaLavorazioniFiltrata[indexPath.row]
        cell.detailTextLabel?.text = item.descrizioneLavorazione
        cell.textLabel?.text = "\(item.codiceLavorazione)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "anagraficaLavorazioneSegue", sender: listaLavorazioniFiltrata[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue , sender: Any? ) {
        if segue.identifier == "anagraficaLavorazioneSegue" {
            let vc = segue.destination as! InsertAnagraficaLavorazioneViewController
            vc.anagraficaLavorazione = sender as? AnagraficaLavorazioni
        }
        
    }
    
    
    
    
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        
        return true
        
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let deleteItem = listaLavorazioniFiltrata[indexPath.row]
            self.listaLavorazioniFiltrata.remove(at: indexPath.row)
            self.anagraficaLavorazioniDatabaseRef.child(deleteItem.codiceLavorazione).removeValue()
            
            
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
            listaLavorazioniFiltrata = listaLavorazioni
            tableView.reloadData()
            return
        }
        listaLavorazioniFiltrata = listaLavorazioni.filter { (lottoProduzione) -> Bool in
            
            return lottoProduzione.codiceLavorazione.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    
    @IBAction func aggiungiLotto(_ sender: Any) {
        performSegue(withIdentifier: "anagraficaLavorazioneSegue", sender: nil/*AnagraficaArticoli(codice: "", descrizioneEstesa: "", descrizioneSintetica: "", autore: "", codiceAttivo: "")*/ )
        
        
    }
    
}



