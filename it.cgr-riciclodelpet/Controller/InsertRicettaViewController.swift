//
//  InsertRicettaViewController.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 10/02/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//

import UIKit
import Firebase
class InsertRicettaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    
    @IBOutlet weak var lottoNome: UILabel!
    
    

    
    @IBOutlet weak var articoloLabel: UITextField!
    @IBOutlet weak var fornitoreLabel: UITextField!
    @IBOutlet weak var lottoLabel: UITextField!
   
    @IBOutlet weak var quantityLabel: UITextField!
    @IBOutlet weak var colliLabel: UITextField!
    @IBOutlet weak var noteLabel: UITextField!
    @IBOutlet weak var tableView: UITableView!


    
    var ricettaLotto: ItemRicetta?
    var firebaseLotto: String?
    
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        tableView.delegate = self
        tableView.dataSource = self
        lottoNome.text = firebaseLotto!
       ricettaLotto = ItemRicetta(lottoPf: firebaseLotto!, articolo: [], fornitore: [], lotto: [], quantityKg: [], quantityColli: [], note: [], completed: [])
       // popolaRicetta()
       let ricettaDatabase: DatabaseReference = Database.database().reference().child("ricetta").child(firebaseLotto!)
        ricettaDatabase.observe(.value) { (snapShot) in
            
            let firebaseData = snapShot
            
            // let lotto = firebaseData.key
            if let lottoRicetta = firebaseData.value as? [String: Any] {
                print(lottoRicetta)
                let articoloArray: [String] = lottoRicetta["articoloricetta"]! as! [String]
                let fornitoreArray: [String] = lottoRicetta["fornitorericetta"]! as! [String]
                let lottoArray: [String] = lottoRicetta["lottoricetta"]! as! [String]
                let noteArray: [String] = lottoRicetta["notaricetta"]! as! [String]
                let quantityArray: [Int] = lottoRicetta["quantitaricetta"] as! [Int]
                let colliArray: [Int] = lottoRicetta["numerocolliricetta"] as! [Int]
                let completedArray: [String] = lottoRicetta["completedricetta"]! as! [String]
                //let userID = Auth.auth().currentUser!.uid
             
                self.ricettaLotto = ItemRicetta(lottoPf: self.firebaseLotto!, articolo: articoloArray, fornitore: fornitoreArray, lotto: lottoArray, quantityKg: quantityArray, quantityColli: colliArray, note: noteArray, completed: completedArray)
                print("la ricetta è \(String(describing: self.ricettaLotto?.articolo))")
            }
         self.tableView.reloadData()
        }
       // tableView.reloadData()
     
    }
        
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RicettaCell", for: indexPath as IndexPath)
        //print("n.\(indexPath.row + 1): \(ricettaLotto?.articolo[indexPath.row]) ")
        cell.textLabel?.text = String(describing: ricettaLotto!.articolo[indexPath.row]) + ", " + String(describing: ricettaLotto!.fornitore[indexPath.row]) + ", " + String(describing: ricettaLotto!.lotto[indexPath.row])
       
        cell.detailTextLabel?.text = " Kg: \(String(describing: ricettaLotto!.quantityKg[indexPath.row]!)) - Colli: \(ricettaLotto!.quantityColli[indexPath.row]!) - \(ricettaLotto!.note[indexPath.row])"
        
        if ricettaLotto!.completed[indexPath.row] == "no" {
            cell.accessoryType = .none
        } else {cell.accessoryType = .checkmark}
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return ricettaLotto!.articolo.count
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        
        return true
        
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            /*
             let deleteQuantity =  quantityArray[indexPath.row]
             let deleTara =  colliArray[indexPath.row]
             let deleteNote =  noteArray[indexPath.row]
             let deleteTempo =  completedArray[indexPath.row]
             
             
             self.prodDettaglioDatabaseRef.child(deleteItem.lotto).removeValue()
             self.qualitaDatabaseRef.child(deleteItem.lotto).removeValue()
             self.quantitaDatabaseRef.child(deleteItem.lotto).removeValue()*/
            self.ricettaLotto!.articolo.remove(at: indexPath.row)
            self.ricettaLotto!.fornitore.remove(at: indexPath.row)
            self.ricettaLotto!.lotto.remove(at: indexPath.row)
            
            self.ricettaLotto!.quantityKg.remove(at: indexPath.row)
            self.ricettaLotto!.quantityColli.remove(at: indexPath.row)
            self.ricettaLotto!.note.remove(at: indexPath.row)
            self.ricettaLotto!.completed.remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       let cell = tableView.dequeueReusableCell(withIdentifier: "RicettaCell", for: indexPath as IndexPath)
        //cell.accessoryType = item.completed ? .checkmark : .none
        
        
        print(ricettaLotto!.completed[indexPath.row])
        if ricettaLotto!.completed[indexPath.row] == "no" {
           cell.accessoryType = .checkmark
            ricettaLotto!.completed[indexPath.row] = "si"
            
        } else {
            cell.accessoryType = .none
           ricettaLotto!.completed[indexPath.row] = "no"
            
        }
        tableView.reloadData()
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
        
        let articoloToMove = ricettaLotto!.articolo[fromIndexPath.row]
        ricettaLotto!.articolo.remove(at: fromIndexPath.row)
        ricettaLotto!.articolo.insert(articoloToMove, at: to.row)
        
        let fornitoreToMove = ricettaLotto!.fornitore[fromIndexPath.row]
        ricettaLotto!.fornitore.remove(at: fromIndexPath.row)
        ricettaLotto!.fornitore.insert(fornitoreToMove, at: to.row)
        
        let lottoToMove = ricettaLotto!.lotto[fromIndexPath.row]
        ricettaLotto!.lotto.remove(at: fromIndexPath.row)
        ricettaLotto!.lotto.insert(lottoToMove, at: to.row)
        
        let quantityToMove = ricettaLotto!.quantityKg[fromIndexPath.row]
        ricettaLotto!.quantityKg.remove(at: fromIndexPath.row)
        ricettaLotto!.quantityKg.insert(quantityToMove, at: to.row)
        
        let colliToMove = ricettaLotto!.quantityColli[fromIndexPath.row]
        ricettaLotto!.quantityColli.remove(at: fromIndexPath.row)
        ricettaLotto!.quantityColli.insert(colliToMove, at: to.row)
        
        let noteToMove = ricettaLotto!.note[fromIndexPath.row]
        ricettaLotto!.note.remove(at: fromIndexPath.row)
        ricettaLotto!.note.insert(noteToMove, at: to.row)
        
        let completatoToMove = ricettaLotto!.completed[fromIndexPath.row]
        ricettaLotto!.completed.remove(at: fromIndexPath.row)
        ricettaLotto!.completed.insert(completatoToMove, at: to.row)
        
        tableView.reloadData()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func inserisciCollo(_ sender: Any) {
        if let articolo = articoloLabel.text {
            ricettaLotto!.articolo.append(articolo)
           // somma = somma + quantitaInt
            
            if let fornitore = fornitoreLabel.text {
                ricettaLotto!.fornitore.append(fornitore) } else { ricettaLotto!.fornitore.append("") }
            
            if let lotto = lottoLabel.text {
                ricettaLotto!.lotto.append(lotto) } else { ricettaLotto!.note.append("") }
            
            if let colliInt = Int((colliLabel?.text)!) {
                ricettaLotto!.quantityColli.append(colliInt) } else {ricettaLotto!.quantityColli.append(0)}
            
            if let nota = noteLabel.text {
                ricettaLotto!.note.append(nota) } else { ricettaLotto!.note.append("") }
           
            if let quantitaInt = Int((quantityLabel?.text)!) {
                ricettaLotto!.quantityKg.append(quantitaInt)
            } else { ricettaLotto!.quantityKg.append(0) }
            
            ricettaLotto!.completed.append("no")
        } else { print("Non è possibile aggiungere un item senza indicare la quantità")}
        tableView.reloadData()
        
    }
    
    
    
    
    
    
    
    @IBAction func startEditing(_ sender: UIBarButtonItem) {
        tableView.isEditing = !tableView.isEditing
    }
    
    @IBAction func inserisciDati(_ sender: Any) {
        let ricettaRef: DatabaseReference = Database.database().reference().child("ricetta")
        //let quantitaRef: DatabaseReference = Database.database().reference().child("quantita")
       // let articolo = articoloLabel.text!
       // let userID = Auth.auth().currentUser!.email
        
       
        
        if  let firebaseLotto = ricettaLotto?.lottoPf {
            ricettaRef.child(firebaseLotto).setValue(["articoloricetta": ricettaLotto!.articolo, "quantitaricetta": ricettaLotto!.quantityKg, "notaricetta": ricettaLotto!.note, "fornitorericetta": ricettaLotto!.fornitore, "numerocolliricetta": ricettaLotto!.quantityColli, "lottoricetta": ricettaLotto!.lotto, "completedricetta": ricettaLotto!.completed])
        }
                
            
        
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

