//
//  LavorazioniTableViewController.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 22/06/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//

//
//  MacchinariTableViewController.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 14/04/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher




class IstruzioniTableViewController: UITableViewController {
    
    @IBOutlet var macchinariTableView: UITableView!
    var listaNodi: [String] = ["CGR"]
    let imageUrlDefault = "nessun documento"
    let imageDefault: UIImage = #imageLiteral(resourceName: "CGR Iogo firma")
    let listaIstruzioniDatabaseRef: DatabaseReference = Database.database().reference().child("istruzioni")
    var listaIstruzioni = [AnagraficaIstruzione]()
    var listaIstruzioniFiltrata = [AnagraficaIstruzione]()
    var codiceGenitore: String = "CGR"
    /* let chiavi = ["Descrizione","FotoURL", "Codice", "CodiceGenitore", "listaPassi"]
     let tipoChiavi = ["String", "String", "String", "String", "[String]"]*/
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        listaIstruzioniDatabaseRef.observe(.value) { (snapShot) in
            self.listaIstruzioni = []
            self.listaIstruzioniFiltrata = []
            for item in snapShot.children {
                
                let firebaseData = item as! DataSnapshot
                let listaIstruzioniFirebase = firebaseData.value as! [String: Any]
                let chiavi = Array(listaIstruzioniFirebase.keys)
                let valori = Array(listaIstruzioniFirebase.values)
                print("Chiavi: \(chiavi)")
                print("Valori: \(valori[3])")
                
                let descrizione: String = listaIstruzioniFirebase["Descrizione"] as! String
                let fotoUrl: String = listaIstruzioniFirebase["FotoURL"] as! String
                let codice: String = listaIstruzioniFirebase["Codice"] as! String
                let codiceGenitore: String = listaIstruzioniFirebase["CodiceGenitore"] as! String
                let listaPassi = listaIstruzioniFirebase["ListaPassi"] as? [String]
                
                let myIstruzione = AnagraficaIstruzione(codice: codice, descrizione: descrizione, codiceGenitore: codiceGenitore, fotoUrl: fotoUrl, listaPassi: listaPassi)
                self.listaIstruzioni.append(myIstruzione)
                
                //self.listaMacchinari.append(myIstruzione)
                //self.listaIstruzioniFiltrata = self.listaIstruzioniFiltrata
                self.listaIstruzioniFiltrata = self.listaIstruzioni.filter { (lottoProduzione) -> Bool in
                    
                    return lottoProduzione.codiceGenitore.elementsEqual(self.listaNodi.last ?? "CGR")
                    
                }
                self.tableView.reloadData()
                
            }
            
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        return listaIstruzioniFiltrata.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "macchinarioCell", for: indexPath) as! MacchinariTableViewCell
        
        cell.codice.text = listaIstruzioniFiltrata[indexPath.row].codice
        cell.descrizione.text = listaIstruzioniFiltrata[indexPath.row].descrizione
        cell.foto.image = imageDefault
      
        cell.aggiungiLivello.tag = indexPath.row
        cell.aggiungiLivello.addTarget(self, action: #selector(self.inserisciLivello(_:)), for: .touchUpInside)
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        codiceGenitore = listaIstruzioniFiltrata[indexPath.row].codice
        self.title = "Procedura di \(String(describing: codiceGenitore))"
        if listaNodi.last != listaIstruzioniFiltrata[indexPath.row].codiceGenitore {
            listaNodi.append(listaIstruzioniFiltrata[indexPath.row].codiceGenitore)
        }
        listaIstruzioniFiltrata = listaIstruzioni.filter { (lottoProduzione) -> Bool in
            
            return lottoProduzione.codiceGenitore.elementsEqual(codiceGenitore)
            
        }
        tableView.reloadData()
        
    }
    
    @objc func inserisciLivello(_ sender: UIButton) {
        
        performSegue(withIdentifier: "istruzioneSegue", sender: listaIstruzioniFiltrata[sender.tag])
        
    }
    
    func configureTableView() {
        macchinariTableView.rowHeight = UITableViewAutomaticDimension
        macchinariTableView.estimatedRowHeight = 120.0
    }
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deleteItem = listaIstruzioniFiltrata[indexPath.row]
            
            // Inserire controllo che l'elemento eliminato non abbia figli
            let listaVerifica = listaIstruzioni.filter { (lista) -> Bool in
                
                return lista.codiceGenitore.elementsEqual(deleteItem.codice)
            }
            if listaVerifica.count > 0 {
                print("impossibile cancellare")
                let alertController = UIAlertController(title: "Attenzione!", message: "Impossibile cancellare un elemento che contiene figli. Questi vanno cancellati o spostati.", preferredStyle: UIAlertControllerStyle.alert)
                let continuaAction = UIAlertAction(title: "Continua", style: UIAlertActionStyle.default, handler: {
                    (action : UIAlertAction!) -> Void in })
                alertController.addAction(continuaAction)
                self.present(alertController, animated: true, completion: nil)
            }
                // Cancello il macchinario
            else {
                self.listaIstruzioniFiltrata.remove(at: indexPath.row)
                // Delete the row from the data source
                tableView.deleteRows(at: [indexPath], with: .fade)
                self.listaIstruzioniDatabaseRef.child(deleteItem.codice).removeValue()
                //tableView.reloadData()
                
                //Removes image from storage
            
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
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "istruzioneSegue" {
            let vc = segue.destination as! InsertIstruzioneViewController
            vc.anagraficaIstruzione = sender as? AnagraficaIstruzione
            
        }
        if segue.identifier == "nuovaIstruzioneSegue" {
            let vc = segue.destination as! InsertIstruzioneViewController
            vc.anagraficaIstruzione = AnagraficaIstruzione(codice: "", descrizione: "", codiceGenitore: codiceGenitore, fotoUrl: imageUrlDefault, listaPassi: nil)
            vc.codiceGenitore = codiceGenitore
        }
        
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    @IBAction func inseriscimacchinario(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "nuovaIstruzioneSegue", sender: self)
    }
    
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        if listaNodi.count > 0 /*, listaIstruzioniFiltrata.count >0 */  {
            codiceGenitore = listaNodi.last!
            listaNodi.removeLast()
            
        }
        
        listaIstruzioniFiltrata = listaIstruzioni.filter { (macchinari) -> Bool in
            
            return macchinari.codiceGenitore.elementsEqual(codiceGenitore)
        }
        //livelloAttuale = listaIstruzioniFiltrata.first?.codiceGenitore ?? ""
        self.title = "Procedura di \(codiceGenitore)"
        
        tableView.reloadData()
        
    }
    
}
