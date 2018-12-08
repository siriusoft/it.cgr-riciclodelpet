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




class MacchinariTableViewController: UITableViewController {
    
    @IBOutlet var macchinariTableView: UITableView!
    var listaNodi: [String] = ["CGR"]
    let imageUrlDefault = "https://firebasestorage.googleapis.com/v0/b/cgr-riciclodelpet.appspot.com/o/images%2FDefaultImage.jpg?alt=media&token=692a5cbd-1ab9-4973-8321-956dc815457c"
    let imageDefault: UIImage = #imageLiteral(resourceName: "CGR Iogo firma")
    let listaMacchinariDatabaseRef: DatabaseReference = Database.database().reference().child("macchinari")
    var listaMacchinari = [AnagraficaMacchinario]()
    var listaMacchinariFiltrata = [AnagraficaMacchinario]()
    var codiceGenitore: String = "CGR"
   /* let chiavi = ["Descrizione","FotoURL", "Codice", "CodiceGenitore", "ListaCaratteristiche"]
    let tipoChiavi = ["String", "String", "String", "String", "[String]"]*/
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        listaMacchinariDatabaseRef.observe(.value) { (snapShot) in
            self.listaMacchinari = []
            self.listaMacchinariFiltrata = []
            for item in snapShot.children {
                
                let firebaseData = item as! DataSnapshot
                let listaMacchinariFirebase = firebaseData.value as! [String: Any]
                let chiavi = Array(listaMacchinariFirebase.keys)
                let valori = Array(listaMacchinariFirebase.values)
                print("Chiavi: \(chiavi)")
                print("Valori: \(valori[3])")
                
                let descrizione: String = listaMacchinariFirebase["Descrizione"] as! String
                let fotoUrl: String = listaMacchinariFirebase["FotoURL"] as! String
                let codice: String = listaMacchinariFirebase["Codice"] as! String
                let codiceGenitore: String = listaMacchinariFirebase["CodiceGenitore"] as! String
                let listaManutenzioni = listaMacchinariFirebase["ListaManutenzioni"] as? [String]
                let listaFrequenzaManutenzioni = listaMacchinariFirebase["ListaFrequenzaManutenzioni"] as? [Int]
                let listaCaratteristiche = listaMacchinariFirebase["ListaCaratteristiche"] as? [String]
                
                let myMacchinario = AnagraficaMacchinario(codice: codice, descrizione: descrizione, codiceGenitore: codiceGenitore, fotoUrl: fotoUrl, listaCaratteristiche: listaCaratteristiche, listaManutenzioni: listaManutenzioni, listaFrequenzaManutenzioni: listaFrequenzaManutenzioni)
                    self.listaMacchinari.append(myMacchinario)
                
                //self.listaMacchinari.append(myMacchinario)
                //self.listaMacchinariFiltrata = self.listaMacchinariFiltrata
                self.listaMacchinariFiltrata = self.listaMacchinari.filter { (lottoProduzione) -> Bool in
                    
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
        return listaMacchinariFiltrata.count
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "macchinarioCell", for: indexPath) as! MacchinariTableViewCell
        
        cell.codice.text = listaMacchinariFiltrata[indexPath.row].codice
        cell.descrizione.text = listaMacchinariFiltrata[indexPath.row].descrizione
        if let imageUrl = listaMacchinariFiltrata[indexPath.row].fotoUrl {
            if imageUrl == imageUrlDefault {
                cell.foto.image = imageDefault
            }
            else {
            let url = URL(string: imageUrl)
            cell.foto.kf.setImage(with: url)
            
            /*
                 // Senza utilizzo di Kingfisher e senza cache
                 
                URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
               
                DispatchQueue.main.async { cell.foto.image = UIImage(data: data!) }
                //dispatch_async(dispatch_get_main_queue(),{ cell.foto.image = UIImage(data: data!)})
            }).resume() */
            }
        }
        cell.aggiungiLivello.tag = indexPath.row
        cell.aggiungiLivello.addTarget(self, action: #selector(self.inserisciLivello(_:)), for: .touchUpInside)
        

        return cell
    }
    
   
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        codiceGenitore = listaMacchinariFiltrata[indexPath.row].codice
        self.title = "Componenti di \(String(describing: codiceGenitore))"
        if listaNodi.last != listaMacchinariFiltrata[indexPath.row].codiceGenitore {
        listaNodi.append(listaMacchinariFiltrata[indexPath.row].codiceGenitore)
        }
        listaMacchinariFiltrata = listaMacchinari.filter { (lottoProduzione) -> Bool in
            
            return lottoProduzione.codiceGenitore.elementsEqual(codiceGenitore)
            
        }
        tableView.reloadData()
        
    }
    
    @objc func inserisciLivello(_ sender: UIButton) {
      
        performSegue(withIdentifier: "macchinarioSegue", sender: listaMacchinariFiltrata[sender.tag])

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
            let deleteItem = listaMacchinariFiltrata[indexPath.row]
            
            // Inserire controllo che l'elemento eliminato non abbia figli
            let listaVerifica = listaMacchinari.filter { (lista) -> Bool in
                
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
            self.listaMacchinariFiltrata.remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.listaMacchinariDatabaseRef.child(deleteItem.codice).removeValue()
            //tableView.reloadData()
            let url = deleteItem.fotoUrl
            let storageRef = Storage.storage().reference(forURL: url!)
                //Removes image from storage
                storageRef.delete { error in
                    if let error = error {
                        print(error)
                    } else {
                        // File deleted successfully
                    }
                }
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
        if segue.identifier == "macchinarioSegue" {
            let vc = segue.destination as! InsertMacchinarioViewController
            vc.anagraficaMacchinario = sender as? AnagraficaMacchinario
           
        }
        if segue.identifier == "nuovoMacchinarioSegue" {
            let vc = segue.destination as! InsertMacchinarioViewController
            vc.anagraficaMacchinario = AnagraficaMacchinario(codice: "", descrizione: "", codiceGenitore: codiceGenitore, fotoUrl: imageUrlDefault, listaCaratteristiche: nil, listaManutenzioni: nil, listaFrequenzaManutenzioni: nil)
            vc.codiceGenitore = codiceGenitore
        }
        
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    @IBAction func inseriscimacchinario(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "nuovoMacchinarioSegue", sender: self)
    }
    
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        if listaNodi.count > 0 /*, listaMacchinariFiltrata.count >0 */  {
            codiceGenitore = listaNodi.last!
            listaNodi.removeLast()
            
        }
        
        listaMacchinariFiltrata = listaMacchinari.filter { (macchinari) -> Bool in
            
            return macchinari.codiceGenitore.elementsEqual(codiceGenitore)
        }
        //livelloAttuale = listaMacchinariFiltrata.first?.codiceGenitore ?? ""
        self.title = "Componenti di \(codiceGenitore)"
        
        tableView.reloadData()

    }
    
}
