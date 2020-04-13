//
//  AnagraficaArticoliTableViewController.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 25/02/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//

import UIKit
import Firebase
import WebKit
import FirebaseDatabase

class AnagraficaArticoliTableViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    let anagraficaArticoliDatabaseRef: DatabaseReference = Database.database().reference().child("anagraficaArticoli")
    
    var listaArticoli = [AnagraficaArticoli]()
    var listaArticoliFiltrata = [AnagraficaArticoli]()
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSearchbar()
        
         anagraficaArticoliDatabaseRef.observe(.value) { (snapShot) in
            self.listaArticoli = []
            self.listaArticoliFiltrata = []
            for item in snapShot.children {
                
                let firebaseData = item as! DataSnapshot
                let codiceArticolo = firebaseData.key
                
                let anagraficaArticolo = firebaseData.value as! [String: Any]
                let descrizioneEstesa: String = String(describing: anagraficaArticolo["DescrizioneEstesa"]!)
                let descrizioneSintetica: String = String(describing: anagraficaArticolo["DescrizioneSintetica"]!)
                let autore: String = String(describing: anagraficaArticolo["Autore"]!)
                let codiceAttivo: String = String(describing: anagraficaArticolo["CodiceAttivo"]!)
                
                let articolo = AnagraficaArticoli(codice: codiceArticolo, descrizioneEstesa: descrizioneEstesa, descrizioneSintetica: descrizioneSintetica, autore: autore, codiceAttivo: codiceAttivo )
                self.listaArticoli.append(articolo)
                
                self.listaArticoliFiltrata = self.listaArticoli
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
        return listaArticoliFiltrata.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticoloCell", for: indexPath)
        let item = listaArticoliFiltrata[indexPath.row]
        cell.detailTextLabel?.text = item.descrizioneEstesa
        cell.textLabel?.text = "\(item.codice): \(item.descrizioneSintetica)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "anagraficaArticoloSegue", sender: listaArticoliFiltrata[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue , sender: Any? ) {
        if segue.identifier == "anagraficaArticoloSegue" {
            let vc = segue.destination as! InsertAnagraficaArticoloViewController
            vc.anagraficaArticolo = sender as? AnagraficaArticoli
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
            
            let deleteItem = listaArticoliFiltrata[indexPath.row]
            self.listaArticoliFiltrata.remove(at: indexPath.row)
            self.anagraficaArticoliDatabaseRef.child(deleteItem.codice).removeValue()
            
            
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
            listaArticoliFiltrata = listaArticoli
            tableView.reloadData()
            return
        }
        listaArticoliFiltrata = listaArticoli.filter { (lottoProduzione) -> Bool in
            
            return lottoProduzione.codice.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    
    @IBAction func aggiungiLotto(_ sender: Any) {
        performSegue(withIdentifier: "anagraficaArticoloSegue", sender: nil/*AnagraficaArticoli(codice: "", descrizioneEstesa: "", descrizioneSintetica: "", autore: "", codiceAttivo: "")*/ )
        
        
    }
    
}


