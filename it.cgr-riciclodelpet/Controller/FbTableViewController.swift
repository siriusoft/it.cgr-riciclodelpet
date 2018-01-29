
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





class FbTableViewController: UITableViewController {

    var toProduceList: [ItemProdottoFinito] = []
    let prodDettaglioDatabaseRef: DatabaseReference = Database.database().reference().child("produzionedettaglio")
    let qualitaDatabaseRef: DatabaseReference = Database.database().reference().child("qualita")
    var listaProduzione: [DettaglioProduzione] = []
    
   
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        prodDettaglioDatabaseRef.observe(.value) { (snapShot) in
            self.listaProduzione = []
            for item in snapShot.children {
                let firebaseData = item as! DataSnapshot
                //let miscela = firebaseData.childSnapshot(forPath: "Ricetta")
                //let dateFormatter = DateFormatter()
                //dateFormatter.dateFormat = "yyyy-MM-dd"
                //let numeroRigheRicetta = miscela.childrenCount
                //self.getRicetta(ricetta: miscela, numeroRighe: Int(numeroRigheRicetta))
                let lotto = firebaseData.key
                let lottoProduzione = firebaseData.value as! [String: Any]
                print(lottoProduzione)
                let codiceProdotto: String = String(describing: lottoProduzione["Articolo"]!)
                let umisura = "Kg"
                let noteArray: [String] = lottoProduzione["Dettaglionota"]! as! [String]
                let quantityArray: [Int] = lottoProduzione["Dettaglioquantita"] as! [Int]
                //let dataStartString: String = lottoProduzione["DataStart"] as! String
                //print(dataStartString)
                //let dataStart = dateFormatter.date(from: dataStartString)
                //let dataCompletedString: String = lottoProduzione["DataCompleted"] as! String
               // print(dataCompletedString)
                //let dataCompleted = dateFormatter.date(from: dataCompletedString)
                let lottoProdotto = DettaglioProduzione(lotto: lotto, umisura: umisura, codiceProdotto: codiceProdotto, quantity: quantityArray, note: noteArray)
                self.listaProduzione.append(lottoProdotto)
                //self.Ricettalist = []
                
            }
         self.tableView.reloadData()
        }


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        return listaProduzione.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoListCell", for: indexPath)
        let item = listaProduzione[indexPath.row]
        qualitaDatabaseRef.child(item.lotto).observe(.value) { (snap) in
            guard let schedaTecnica = snap.value as? [String: Any] else { return }
            guard let approvato = schedaTecnica["Approvato"] else {return}
            cell.detailTextLabel?.text = String(self.calcoloQuantitaLotto(dettaglioLotto: item.quantity)) + " Kg, " + String(item.quantity.count) + " colli" + ", Approvato: " + String(describing: approvato)
        }
        cell.textLabel?.text = item.lotto + ", " + item.codiceProdotto
        
        //cell.accessoryType = item.completed ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ricettaSegue", sender: listaProduzione[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue , sender: Any? ) {
        if segue.identifier == "ricettaSegue" {
            let vc = segue.destination as! RicettaTableViewController
            vc.produzioneLotto = sender as? DettaglioProduzione
        }
        if segue.identifier == "schedaTecnicaSegue" {
            let vc = segue.destination as! SchedaTecnicaViewController
            vc.produzioneLotto = sender as? DettaglioProduzione
        }
    }
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "schedaTecnicaSegue", sender: listaProduzione[indexPath.row])
    }
    
    
     
    

   
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let deleteItem = toProduceList[indexPath.row]
            
            
            //print(deleteItem.name)
            //p = toDoListRef as! DataSnapshot
            //p.child(deleteItem.name).value(forKey: "Name")
            //print(String(describing: prova))
            self.prodDettaglioDatabaseRef.child(deleteItem.name).removeValue()
            self.toProduceList.remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
   
  /*  func getRicetta(ricetta: DataSnapshot, numeroRighe: Int) {
        for n in 1...numeroRighe {
            let miscela = ricetta.childSnapshot(forPath: "Item\(n)")
            let miscelaItem = miscela.value as! [String: Any]
            let articolo: String = String(describing: miscelaItem["articolo"]!)
            let fornitore: String = String(describing: miscelaItem["fornitore"]!)
            let lotto: String = String(describing: miscelaItem["lotto"]!)
            let misura: String = String(describing: miscelaItem["misura"]!)
            let note: String = String(describing: miscelaItem["note"]!)
            let quantity: Int = miscelaItem["quantita"] as! Int
            let rigaRicetta = ItemRicetta(misura: misura, articolo: articolo, fornitore: fornitore, lotto: lotto, quantity: quantity, note: note)
             Ricettalist.append(rigaRicetta)
        }
 
    } */
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

    func calcoloQuantitaLotto(dettaglioLotto: [Int]) -> Int {
        var sum = 0
        for i in 0...dettaglioLotto.count-1 {
             sum += dettaglioLotto[i]
        }
        return sum
        
    }

}
