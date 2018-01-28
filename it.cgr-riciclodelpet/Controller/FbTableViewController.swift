
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
    let toDoListRef: DatabaseReference = Database.database().reference().child("todolist")
    var Ricettalist: [ItemRicetta] = []
    
   
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        toDoListRef.observe(.value) { (snapShot) in
            self.toProduceList = []
            for item in snapShot.children {
                let toProduceData = item as! DataSnapshot
                let miscela = toProduceData.childSnapshot(forPath: "Ricetta")
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let numeroRigheRicetta = miscela.childrenCount
                self.getRicetta(ricetta: miscela, numeroRighe: Int(numeroRigheRicetta))
                let toProduceItem = toProduceData.value as! [String: Any]
                let name: String = String(describing: toProduceItem["Name"]!)
                let completed: Bool = toProduceItem["Completed"] as! Bool
                let umisura: String = String(describing: toProduceItem["Umisura"]!)
                let note: String = String(describing: toProduceItem["Note"]!)
                let quantity: Int = toProduceItem["Quantity"] as! Int
                let dataStartString: String = toProduceItem["DataStart"] as! String
                print(dataStartString)
                let dataStart = dateFormatter.date(from: dataStartString)
                let dataCompletedString: String = toProduceItem["DataCompleted"] as! String
                print(dataCompletedString)
                //let dataCompleted = dateFormatter.date(from: dataCompletedString)
                let toProduce = ItemProdottoFinito(umisura: umisura, completed: completed, name: name, quantity: quantity, ricetta: self.Ricettalist, note: note, dataCompleted: dataStart!, dataStart: dataStart!)
                self.toProduceList.append(toProduce)
                self.Ricettalist = []
                
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
        print(toProduceList.count)
        return toProduceList.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoListCell", for: indexPath)
        let todoitem = toProduceList[indexPath.row]
        cell.textLabel?.text = todoitem.name
        cell.detailTextLabel?.text = String(todoitem.quantity) + " " + String(todoitem.umisura)
        cell.accessoryType = todoitem.completed ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Ricettasegue", sender: toProduceList[indexPath.row].ricetta)
    }
    override func prepare(for segue: UIStoryboardSegue , sender: Any? ) {
        if segue.identifier == "Ricettasegue"{
        let vc = segue.destination as! RicettaTableViewController
        vc.Ricettalist = sender as? [ItemRicetta]
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
            
            let deleteItem = toProduceList[indexPath.row]
            
            
            //print(deleteItem.name)
            //p = toDoListRef as! DataSnapshot
            //p.child(deleteItem.name).value(forKey: "Name")
            //print(String(describing: prova))
            self.toDoListRef.child(deleteItem.name).removeValue()
            self.toProduceList.remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
   
    func getRicetta(ricetta: DataSnapshot, numeroRighe: Int) {
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

}
