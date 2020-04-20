//
//  DdtTableViewController.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 09/03/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//

import UIKit

class DdtTableViewController: UITableViewController {

    var ddtList: [Articolo]?
    var articoloDictionary: [String:[Articolo]] = [:]
    var listaChiavi: [String] = []
    var totaleKgDdt = 0
    var totaleColliDdt = 0
    var totaleKgTara = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        let headerView = UIView()
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 40)
        headerView.backgroundColor = .green
        tableView.tableHeaderView = headerView
        let totaleDdtLabel = UILabel()
        totaleDdtLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 30)
        totaleDdtLabel.textAlignment = .center
        //totaleDdtLabel.font = UIFont.boldSystemFont(ofSize: 10)
        totaleDdtLabel.minimumScaleFactor = 0.5
        totaleDdtLabel.adjustsFontSizeToFitWidth = true
        totaleDdtLabel.adjustsFontForContentSizeCategory = true
       
        headerView.addSubview(totaleDdtLabel)
        
        let predicate = { (element: Articolo) in
            return element.articolo
        }
        articoloDictionary = Dictionary(grouping: ddtList!,by: predicate)
        
        for (chiave,_) in articoloDictionary {
            listaChiavi.append(chiave)
        }
        
        for item in ddtList! {
            totaleKgDdt += item.kg
            totaleColliDdt += item.colli
            totaleKgTara += item.tara
        }
        totaleDdtLabel.text = "P.Netto:\(totaleKgDdt) Kg, Tara: \(totaleKgTara) Kg, \(totaleColliDdt) Colli"
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
        
        return articoloDictionary.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
       
        if let item = self.articoloDictionary[listaChiavi[section]] {
        
        return item.count
        } else { return 0 }
    }
 
   override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {

        let header = view as? UITableViewHeaderFooterView
    //header?.textLabel?.font = //UIFont(name: "Futura", size: 14) // change it according to ur requirement
    //UIFont.boldSystemFont(ofSize: 12)
    header?.textLabel?.textColor = UIColor.black // change it according to ur requirement
    header?.textLabel?.minimumScaleFactor = 0.5
    header?.textLabel?.adjustsFontForContentSizeCategory = true
    header?.textLabel?.adjustsFontSizeToFitWidth = true
    
    }
    
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let chiave = self.listaChiavi[section]
        let listaPerChiave = articoloDictionary[chiave]
        var totaleColli = 0
        var totaleKg = 0
        var totaleTara = 0
        for item in listaPerChiave! {
            totaleKg += item.kg
            totaleColli += item.colli
            totaleTara += item.tara
        }
        let header = "\(chiave):\(totaleKg) Kg,T: \(totaleTara) Kg,\(totaleColli) Colli"
        
        
        
        return header
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ddtList = self.articoloDictionary[listaChiavi[indexPath.section]]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ddtCell", for: indexPath)
        let item = ddtList![indexPath.row]
        cell.textLabel?.text = "\(item.lotto), \(item.kg) kg, \(item.colli) colli. Approvato: \(item.qualita)"
        // Configure the cell...
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
