//
//  ViewController.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 29/12/17.
//  Copyright © 2017 Alberto Rimini. All rights reserved.
//

import UIKit
import Firebase
import WebKit
class ViewController: UIViewController {

   
    override func viewDidLoad() {
        super.viewDidLoad()
        loginAnonym()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }

    func loginAnonym() {
        Auth.auth().signInAnonymously { (User, Error) in
            if let errore = Error {
                print(errore)
            }
            if let Utenteid = User {
                print("user id è: \(Utenteid.uid)")
            }
        }
    }
    
}

