//
//  InsertDataViewController.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 08/01/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//

import UIKit
import Firebase
class InsertDataViewController: UIViewController {

    @IBOutlet weak var articoloLabel: UITextField!
    @IBOutlet weak var quantityLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
 @IBAction func inserisciDati(_ sender: Any) {
        let toDoListRef: DatabaseReference = Database.database().reference().child("todolist")
        let articolo = articoloLabel.text!
       // toDoListRef.child(articolo).updateChildValues(["Completed" : false, "Name": articolo, "Quantity": quantityLabel.text!])
        dismiss(animated: true, completion: nil)
        
        
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
