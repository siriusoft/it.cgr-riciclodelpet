//
//  FilePDFTableViewController.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 24/03/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//

import UIKit

class FilePDFTableViewController: UITableViewController {
    
    
    var docController:UIDocumentInteractionController!
    var tipoDocumento: String?
    var documentItems = [String]()
    let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let allItems = try? FileManager.default.contentsOfDirectory(atPath: documentDirectory) {
            
            for item in allItems {
                if item.contains(tipoDocumento!) {
                    documentItems.append(item)
                }
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
        return documentItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pdfCell", for: indexPath)

       cell.textLabel?.text = documentItems[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let fileName = documentItems[indexPath.row]
        let path = documentDirectory + "/\(fileName)"
        let fileURL = URL(fileURLWithPath: path, isDirectory: true)
        print(fileURL)
        
        
            // Instantiate the interaction controller
        docController = UIDocumentInteractionController(url: fileURL)
            
       docController.presentOptionsMenu(from: tableView.frame, in: self.view, animated: true)
        
        
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
            // Delete the row from the data source
            let fileName = documentItems[indexPath.row]
            
            do {
                let path = documentDirectory + "/\(fileName)"
                print(path)
                try FileManager.default.removeItem(atPath: path )
                documentItems.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            catch {
                print("unable to delete file")
                tableView.reloadData()
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

}
