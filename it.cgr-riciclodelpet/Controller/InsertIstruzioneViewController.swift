//
//  InsertIstruzioneViewController.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 22/06/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//

import UIKit
import MobileCoreServices
import Firebase
import PDFKit

class InsertIstruzioneViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITableViewDelegate, UITableViewDataSource  {
    
    
    
    var imageUrlDefault = "nessun documento"
    let listaIstruzioniDatabaseRef: DatabaseReference = Database.database().reference().child("istruzioni")
    let storageRef: StorageReference = Storage.storage().reference().child("images")
   
    var anagraficaIstruzione: AnagraficaIstruzione?
    var livelloAlbero: Int?
    var codiceGenitore: String?
    var imageDefault: Bool = true
    var actualTextField: UITextField?
    
    @IBOutlet weak var tableViewTitle: UILabel!
    @IBOutlet weak var descrizioneMacchinario: UITextField!
    @IBOutlet weak var codiceMacchinario: UITextField!    
    @IBOutlet weak var fotoMacchinarioBis: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var anagraficaEsiste: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Procedura di \(anagraficaIstruzione!.codiceGenitore)"
        tableView.reloadData()
        self.hideKeyboardWhenTappedAround()
        
        
        
        
        if let codice = anagraficaIstruzione?.codice {codiceMacchinario.text = codice
            codiceGenitore = anagraficaIstruzione?.codiceGenitore
            if codice != "" {
                anagraficaEsiste = true
            }
        }
        
        if let descrizione = anagraficaIstruzione?.descrizione {
            descrizioneMacchinario.text =  descrizione
            
        }
        
        if let fotoUrl = anagraficaIstruzione?.fotoUrl {
            if fotoUrl != "nessun documento" {
                fotoMacchinarioBis.setTitle("Premi per visionare documento", for: .normal)
                imageDefault = false
                imageUrlDefault = fotoUrl
            } else {
                fotoMacchinarioBis.setTitle("Non esiste alcun documento allegato", for: .normal)
            }
        }
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            if let numeroRighe = anagraficaIstruzione?.listaPassi?.count {
        
                return numeroRighe
                
            } else {return 0}
        
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "caratteristicaCell", for: indexPath as IndexPath)
        
            if let item = anagraficaIstruzione?.listaPassi?[indexPath.row] {
                cell.textLabel?.text = item
                // print(item)
            }
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    @objc func dataPickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy HH:mm"
        actualTextField?.text = dateFormatter.string(from: sender.date)
        
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
           
                self.anagraficaIstruzione?.listaPassi!.remove(at: indexPath.row)
                // Delete the row from the data source
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadData()
            
            
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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
    
    
    
   
    
    @IBAction func aggiungiFoto(_ sender: UIButton) {
        if imageDefault == false {
            let pdfView = PDFView()
            pdfView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(pdfView)
            
            pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
            pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            
            guard let url = URL(string: imageUrlDefault) else { return }
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error!)
                    
                    return
                }
                else {
                    DispatchQueue.main.async {
                        if let pdf = PDFDocument(data: data!) {
                            
                             pdfView.document = pdf
                            
                           
                        } else { print("Impossibile leggere il file pdf")}
                    
                   
                    }
                }
            
            }).resume()
        }
    }
    
    @IBAction func inserisciCaratteristica(_ sender: UIBarButtonItem) {
        
    
            
            let alertController = UIAlertController(title: "Inserisci Passo", message: "", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Inserisci Nuovo Passo " }
            
            let saveAction = UIAlertAction(title: "Salva", style: UIAlertActionStyle.default, handler: { alert -> Void in
                
                
                let nuovaCaratteristica = alertController.textFields![0] as UITextField
                if let caratteristica = nuovaCaratteristica.text {
                    if (self.anagraficaIstruzione?.listaPassi) != nil {
                        self.anagraficaIstruzione?.listaPassi!.append(caratteristica)}
                    else {
                        self.anagraficaIstruzione?.listaPassi = []
                        self.anagraficaIstruzione?.listaPassi!.append(caratteristica)
                    }
                }
                
                
                //self.salvaMacchinario(self)
                self.tableView.reloadData()
                
            })
            let cancelAction = UIAlertAction(title: "Annulla", style: UIAlertActionStyle.default, handler: {
                (action : UIAlertAction!) -> Void in })
            
            
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        
        
        
    }
    
    @IBAction func salvaMacchinario(_ sender: Any) {
        
        guard let codiceMacchinario = codiceMacchinario?.text else { return }
        
        if codiceMacchinario == "" { print("Impossibile salvare una istruzione senza codice")}
            
        else {
            
            let i = navigationController?.viewControllers.index(of: self)
            let previousViewController = navigationController?.viewControllers[i!-1] as! IstruzioniTableViewController
            let listaStessoCodice = previousViewController.listaIstruzioni.filter { (macchinari) -> Bool in
                
                return macchinari.codice.elementsEqual(codiceMacchinario)
            }
            if listaStessoCodice.count > 0 {
                if listaStessoCodice.first!.codiceGenitore != codiceGenitore {
                    print("Codice Istruzione già esistente")
                    let alertController = UIAlertController(title: "Codice Istruzione già esistente!", message: "Impossibile inserire una istruzione con un codice già utilizzato. E' necessario cambiare il codice", preferredStyle: UIAlertControllerStyle.alert)
                    let continuaAction = UIAlertAction(title: "Continua", style: UIAlertActionStyle.default, handler: {
                        (action : UIAlertAction!) -> Void in
                    })
                    alertController.addAction(continuaAction)
                    self.present(alertController, animated: true, completion: nil)
                    return
                } else {
                    print("Sei sicuro di voler modificare l'elemento??")
                    let alertController = UIAlertController(title: "Anagrafica Istruzione", message: "Sicuro di voler modificare il istruzione?", preferredStyle: UIAlertControllerStyle.alert)
                    let continuaAction = UIAlertAction(title: "Continua", style: UIAlertActionStyle.default, handler: {
                        (action : UIAlertAction!) -> Void in
                        if self.imageDefault == true {
                            self.caricaDatiInDatabase(fotoMacchinarioUrl: self.imageUrlDefault)
                        }
                    })
                    let annullaAction = UIAlertAction(title: "Annulla", style: UIAlertActionStyle.default, handler: {
                        (action : UIAlertAction!) -> Void in })
                    alertController.addAction(annullaAction)
                    alertController.addAction(continuaAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                }
                
            }
            print("controllo su codice superato")
            caricaDatiInDatabase(fotoMacchinarioUrl: imageUrlDefault)
        }
        
    }
    
    @IBAction func cambiaPadre(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Cambio Padre", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Inserisci Codice del Nuovo Padre "
        }
        
        let saveAction = UIAlertAction(title: "Salva", style: UIAlertActionStyle.default, handler: { alert -> Void in
            let nuovoPadre = alertController.textFields![0] as UITextField
            self.anagraficaIstruzione?.codiceGenitore = nuovoPadre.text!
            self.codiceGenitore = nuovoPadre.text!
            self.salvaMacchinario(self)
            
        })
        let cancelAction = UIAlertAction(title: "Annulla", style: UIAlertActionStyle.default, handler: {
            (action : UIAlertAction!) -> Void in })
        
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    func caricaDatiInDatabase(fotoMacchinarioUrl: String) {
        anagraficaEsiste = true
        if let articoloItem = codiceMacchinario?.text  {
            
            
                
                if let myListaCaratteristiche = anagraficaIstruzione?.listaPassi {
                    let anagraficaAggiornata = ["Codice": codiceMacchinario.text!, "Descrizione": descrizioneMacchinario.text ?? "","FotoURL": fotoMacchinarioUrl,"ListaPassi": myListaCaratteristiche, "CodiceGenitore": codiceGenitore ?? "CGR"] as [String : Any]
                    listaIstruzioniDatabaseRef.child(articoloItem).setValue(anagraficaAggiornata)
                } else {
                    let anagraficaAggiornata = ["Codice": codiceMacchinario.text!, "Descrizione": descrizioneMacchinario.text ?? "","FotoURL": fotoMacchinarioUrl, "CodiceGenitore": codiceGenitore ?? "CGR"] as [String : Any]
                    listaIstruzioniDatabaseRef.child(articoloItem).setValue(anagraficaAggiornata)
                    
                }
                
                
                
                
            
            
        }
    }
}


