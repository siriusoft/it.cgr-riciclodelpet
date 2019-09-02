//
//  InsertMacchinarioViewController.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 14/04/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//

import UIKit
import MobileCoreServices
import Firebase

class InsertMacchinarioViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate  {
    
    
    
    let imageUrlDefault = "https://firebasestorage.googleapis.com/v0/b/cgr-riciclodelpet.appspot.com/o/images%2FDefaultImage.jpg?alt=media&token=692a5cbd-1ab9-4973-8321-956dc815457c"
    let utilizzoMacchinariRef: DatabaseReference = Database.database().reference().child("utilizzoMacchinari")
    let listaMacchinariDatabaseRef: DatabaseReference = Database.database().reference().child("macchinari")
    let storageRef: StorageReference = Storage.storage().reference().child("images")
    let listaManutenzioniRef: DatabaseReference = Database.database().reference().child("listaManutenzioni")
    var anagraficaMacchinario: AnagraficaMacchinario?
    //var livelloAlbero: Int?
    var codiceGenitore: String?
    var imageDefault: Bool = true
    var dataManutenzione: String = ""
    var actualTextField: UITextField?
    var originalScrollViewFrame: CGRect? = nil
    var originalMacchinarioViewFrame: CGRect? = nil
    var imageTappedCount: Int = 0
    
    
   
    
    

    
    @IBOutlet var imagePinchGesture: UIPinchGestureRecognizer!
    @IBOutlet var imageTapGesture: UITapGestureRecognizer!
    @IBOutlet weak var macchinarioView: UIImageView!
    @IBOutlet weak var myUIScrollView: UIScrollView!
    @IBOutlet weak var tableViewTitle: UILabel!
    @IBOutlet weak var manutenzioneControl: UISegmentedControl!
    @IBOutlet weak var descrizioneMacchinario: UITextField!
    @IBOutlet weak var codiceMacchinario: UITextField!
    @IBOutlet weak var fotoMacchinarioBis: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var anagraficaEsiste: Bool = false
    
    
 

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fotoMacchinarioBis.isHidden = true
        
        self.myUIScrollView.maximumZoomScale = 5.0
        self.myUIScrollView.minimumZoomScale = 0.5
        originalScrollViewFrame = myUIScrollView.frame
        originalMacchinarioViewFrame = macchinarioView.frame
        
        self.title = "Parte di \(anagraficaMacchinario!.codiceGenitore)"
        
        tableView.reloadData()
        self.hideKeyboardWhenTappedAround()
        
        
        if let codice = anagraficaMacchinario?.codice {codiceMacchinario.text = codice
            codiceGenitore = anagraficaMacchinario?.codiceGenitore
            if codice != "" {
                anagraficaEsiste = true
            }
        }
        
        if let descrizione = anagraficaMacchinario?.descrizione {
            descrizioneMacchinario.text =  descrizione }
        
        if let fotoURL = anagraficaMacchinario?.fotoUrl {
            if fotoURL != imageUrlDefault {
                imageDefault = false
                let url = URL(string: fotoURL)
                URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                    if error != nil {
                    print(error!)
                    
                    return
                    }
                    else {
                        DispatchQueue.main.async {
                    if let image = UIImage(data: data!) {
                      /*
                        self.fotoMacchinarioBis.setImage(image, for: .normal)
                        self.fotoMacchinarioBis.setImage(image, for: .highlighted) */
                        self.macchinarioView.image = image
                        
                    } else {
                        print("sono passato per la riga 76")
                        self.imageDefault = true}
                
                  /*  else {
                        
                        self.fotoMacchinarioBis.setImage(#imageLiteral(resourceName: "CGR Iogo firma"), for: .normal)
                        self.fotoMacchinarioBis.setImage(#imageLiteral(resourceName: "CGR Iogo firma"), for: .highlighted)
                    }*/
                        }
                    }
               
                }).resume()
            }
            else {
                print("Sono passato per riga 79")
              /*  fotoMacchinarioBis.setImage(#imageLiteral(resourceName: "CGR Iogo firma"), for: .normal)
                fotoMacchinarioBis.setImage(#imageLiteral(resourceName: "CGR Iogo firma"), for: .highlighted) */
                self.macchinarioView.image = #imageLiteral(resourceName: "CGR Iogo firma")
                imageDefault = true
            }
        }
        
        
        
        
        
      

        // Do any additional setup after loading the view.
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return macchinarioView
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if manutenzioneControl.selectedSegmentIndex == 0 {
            if let numeroRighe = anagraficaMacchinario?.listaCaratteristiche?.count {
           
            return numeroRighe
            
            } else {return 0}
        }
        if manutenzioneControl.selectedSegmentIndex == 1 {
            if let numeroRighe = anagraficaMacchinario?.listaManutenzioni?.count {
                
                return numeroRighe
                
            } else {return 0}
        
        } else {return 0}
        
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            if manutenzioneControl.selectedSegmentIndex == 1 {
        
                let controlla = controllaUltimaManutenzione(at: indexPath)
                return UISwipeActionsConfiguration(actions: [controlla])
            }
            else {
                return nil
            }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "caratteristicaCell", for: indexPath as IndexPath)
        if manutenzioneControl.selectedSegmentIndex == 0 {
            if let item = anagraficaMacchinario?.listaCaratteristiche?[indexPath.row] {
            cell.textLabel?.text = item
               // print(item)
            }
        }
        if manutenzioneControl.selectedSegmentIndex == 1 {
                if let item = anagraficaMacchinario?.listaManutenzioni?[indexPath.row] {
                    cell.textLabel?.text = item + " ogni " + String(anagraficaMacchinario!.listaFrequenzaManutenzioni![indexPath.row]) + " Kg"
                    // print(item)
                }
        
        }
        return cell
    }
    
   
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if manutenzioneControl.selectedSegmentIndex == 1 {
            
           
            
            let alertController = UIAlertController(title: "Inserisci Manutenzione", message: "", preferredStyle: UIAlertControllerStyle.alert)
            
            
           
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Inserisci Data Manutenzione"
                let datePickerView:UIDatePicker = UIDatePicker()
                
                datePickerView.datePickerMode = UIDatePickerMode.dateAndTime
                datePickerView.locale =  NSLocale(localeIdentifier: "it_IT") as Locale
                textField.inputView = datePickerView
                self.actualTextField = textField
                datePickerView.addTarget(self, action: #selector(self.dataPickerValueChanged), for: UIControlEvents.valueChanged)
               
                

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yy HH:mm"
               self.dataManutenzione = dateFormatter.string(from: datePickerView.date)
                textField.text = self.dataManutenzione
            
            }
            
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Inserisci Nota"
            }
            
            let saveAction = UIAlertAction(title: "Salva", style: UIAlertActionStyle.default, handler: { alert -> Void in
                
                
                let dataManutenzione = alertController.textFields![0] as UITextField
                let notaManutenzione = alertController.textFields![1] as UITextField
                let userID = Auth.auth().currentUser!.email
                let nuovaManutenzione = ["codiceMacchinario": self.codiceMacchinario.text!, "descrizioneManutenzione": self.anagraficaMacchinario!.listaManutenzioni![indexPath.row], "autore": userID ?? "Ignoto", "dataManutenzione": dataManutenzione.text!, "note": notaManutenzione.text ?? ""]
                let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
                activityIndicator.startAnimating()
                activityIndicator.center = self.view.center
                self.view.addSubview(activityIndicator)
                
                self.listaManutenzioniRef.childByAutoId().setValue(nuovaManutenzione)
                
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
                _ = self.navigationController?.popViewController(animated: true)
                //self.salvaMacchinario(self)
                self.tableView.reloadData()
                
            })
            
            let cancelAction = UIAlertAction(title: "Annulla", style: UIAlertActionStyle.default, handler: {
                (action : UIAlertAction!) -> Void in })
            
            
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
            }
            
        
    }
    
    @objc func dataPickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy HH:mm"
        actualTextField?.text = dateFormatter.string(from: sender.date)
        
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if manutenzioneControl.selectedSegmentIndex == 0 {
                self.anagraficaMacchinario?.listaCaratteristiche!.remove(at: indexPath.row)
                // Delete the row from the data source
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadData()
            }
            if manutenzioneControl.selectedSegmentIndex == 1 {
                self.anagraficaMacchinario?.listaManutenzioni!.remove(at: indexPath.row)
                 self.anagraficaMacchinario?.listaFrequenzaManutenzioni!.remove(at: indexPath.row)
                // Delete the row from the data source
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadData()
            }
            
            
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
       
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            self.macchinarioView.image = image
            // fotoMacchinarioBis.setImage(image, for: .normal)
            // fotoMacchinarioBis.setImage(image, for: .highlighted)
            imageDefault = false
            
        }
        
        picker.dismiss(animated: true, completion:nil)
    }
    
    func uploadProfileImage(imageData: Data)
    {
        let activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        activityIndicator.startAnimating()
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
       
        let profileImageRef = storageRef.child("\(String(describing: codiceMacchinario.text!)).jpg")
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
       
        
        profileImageRef.putData(imageData, metadata: uploadMetaData) { (uploadedImageMeta, error) in
            
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            
            if error != nil
            {
                print("Error took place \(String(describing: error?.localizedDescription))")
                return
            } else {
                
                profileImageRef.downloadURL(completion: { (url, error) in
                    
                    if error == nil {
                        
                        if let urlString = url?.absoluteString {
                            print("indirizzo URL è: \(urlString)")
                            self.caricaDatiInDatabase(fotoMacchinarioUrl: urlString)
                        }
                        
                    
                    
                    }
                })
                
                
               // self.fotoMacchinario.image = UIImage(data: imageData)
               /* uploadedImageMeta?.storageReference?.downloadURL() { (url, error) in
                    
                    print(url!)
                    
                    if error == nil {
                        print("Meta data of uploaded image \(String(describing: uploadedImageMeta))")
                        self.caricaDatiInDatabase(fotoMacchinarioUrl: url?.absoluteString ?? "")
                    }
                    
                    else {
                        print(error!)
                    }
                } */
                
                
            }
        }
    }
    
    @IBAction func manutenzioneSelezione(_ sender: Any) {
        if manutenzioneControl.selectedSegmentIndex == 0 {
            tableViewTitle.text = "Lista Caratteristiche"
        }
        if manutenzioneControl.selectedSegmentIndex == 1 {
            tableViewTitle.text = "Lista Manutenzioni"
        }
        
        tableView.reloadData()
        
    }
    
 /*   @IBAction func aggiungiFoto(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    } */
    
    @IBAction func aggiungiFoto(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func inserisciCaratteristica(_ sender: UIBarButtonItem) {
        
        if manutenzioneControl.selectedSegmentIndex == 0 {
            
            let alertController = UIAlertController(title: "Inserisci Caratteristica", message: "", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Inserisci Nuova Caratteristica " }
        
            let saveAction = UIAlertAction(title: "Salva", style: UIAlertActionStyle.default, handler: { alert -> Void in
                
                
                let nuovaCaratteristica = alertController.textFields![0] as UITextField
                if let caratteristica = nuovaCaratteristica.text {
                    if (self.anagraficaMacchinario?.listaCaratteristiche) != nil {
                        self.anagraficaMacchinario?.listaCaratteristiche!.append(caratteristica)}
                    else {
                        self.anagraficaMacchinario?.listaCaratteristiche = []
                        self.anagraficaMacchinario?.listaCaratteristiche!.append(caratteristica)
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
        
        if manutenzioneControl.selectedSegmentIndex == 1 {
            
            let alertController = UIAlertController(title: "Inserisci Manutenzione", message: "", preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Inserisci Nuova Manutenzione " }
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Inserisci Frequenza in Kg di produzione "
                textField.keyboardType = UIKeyboardType.numberPad
            }
        
            let saveAction = UIAlertAction(title: "Salva", style: UIAlertActionStyle.default, handler: { alert -> Void in
         
            
                let nuovaManutenzione = alertController.textFields![0] as UITextField
                let nuovaFrequenzaManutenzione = alertController.textFields![1] as UITextField
                
                if let manutenzione = nuovaManutenzione.text {
                    if (self.anagraficaMacchinario?.listaManutenzioni) != nil {
                        self.anagraficaMacchinario?.listaManutenzioni!.append(manutenzione)
                        if let frequenza = nuovaFrequenzaManutenzione.text {
                            self.anagraficaMacchinario?.listaFrequenzaManutenzioni!.append(Int(frequenza) ?? 0)
                        }
                        else {self.anagraficaMacchinario?.listaFrequenzaManutenzioni!.append(0)}
                        
                    }
                    else {
                        self.anagraficaMacchinario?.listaManutenzioni = []
                        self.anagraficaMacchinario?.listaFrequenzaManutenzioni = []
                        self.anagraficaMacchinario?.listaManutenzioni!.append(manutenzione)
                        if let frequenza = nuovaFrequenzaManutenzione.text {
                            self.anagraficaMacchinario?.listaFrequenzaManutenzioni!.append(Int(frequenza) ?? 0)
                        }
                        else {self.anagraficaMacchinario?.listaFrequenzaManutenzioni!.append(0)}
                        
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
    }
    
    @IBAction func salvaMacchinario(_ sender: Any) {
        
        guard let codiceMacchinario = codiceMacchinario?.text else { return }
        
        if codiceMacchinario == "" { print("Impossibile salvare un macchinario senza codice")}
        
        else {
         
            let i = navigationController?.viewControllers.index(of: self)
            let previousViewController = navigationController?.viewControllers[i!-1] as! MacchinariTableViewController
            let listaStessoCodice = previousViewController.listaMacchinari.filter { (macchinari) -> Bool in
            
            return macchinari.codice.elementsEqual(codiceMacchinario)
            }
            if listaStessoCodice.count > 0 {
                if listaStessoCodice.first!.codiceGenitore != codiceGenitore {
                    print("Codice Macchinario già esistente")
                    let alertController = UIAlertController(title: "Codice Macchinario già esistente!", message: "Impossibile inserire un macchinario con un codice già utilizzato. E' necessario cambiare il codice", preferredStyle: UIAlertControllerStyle.alert)
                    let continuaAction = UIAlertAction(title: "Continua", style: UIAlertActionStyle.default, handler: {
                        (action : UIAlertAction!) -> Void in
                    })
                    alertController.addAction(continuaAction)
                    self.present(alertController, animated: true, completion: nil)
                    return
                } else {
                    print("Sei sicuro di voler modificare l'elemento??")
                    let alertController = UIAlertController(title: "Anagrafica Macchinario", message: "Sicuro di voler modificare il macchinario?", preferredStyle: UIAlertControllerStyle.alert)
                    let continuaAction = UIAlertAction(title: "Continua", style: UIAlertActionStyle.default, handler: {
                        (action : UIAlertAction!) -> Void in
                        if self.imageDefault == true {
                            self.caricaDatiInDatabase(fotoMacchinarioUrl: self.imageUrlDefault)
                        }
                        else {
                            if let optimizedImageData = UIImageJPEGRepresentation(self.macchinarioView.image!, 0.6) {
                            self.uploadProfileImage(imageData: optimizedImageData)
                            }
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
            
            if imageDefault == true {
                caricaDatiInDatabase(fotoMacchinarioUrl: imageUrlDefault)
            } else {
                if let optimizedImageData = UIImageJPEGRepresentation(fotoMacchinarioBis.currentImage!, 0.6) {
                    uploadProfileImage(imageData: optimizedImageData)
                }
                
            }
           
        }
        
    }
   
    
    @IBAction func cambiaPadre(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Cambio Padre", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Inserisci Codice del Nuovo Padre "
        }
        
        let saveAction = UIAlertAction(title: "Salva", style: UIAlertActionStyle.default, handler: { alert -> Void in
            let nuovoPadre = alertController.textFields![0] as UITextField
            self.anagraficaMacchinario?.codiceGenitore = nuovoPadre.text!
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
            
            if let myListaManutenzioni = anagraficaMacchinario?.listaManutenzioni {
            //uploadProfileImage(imageData: optimizedImageData)
                if let myListaCaratteristiche = anagraficaMacchinario?.listaCaratteristiche {
                    let anagraficaAggiornata = ["Codice": codiceMacchinario.text!, "Descrizione": descrizioneMacchinario.text ?? "","FotoURL": fotoMacchinarioUrl,"ListaCaratteristiche": myListaCaratteristiche, "ListaManutenzioni": myListaManutenzioni, "ListaFrequenzaManutenzioni": anagraficaMacchinario!.listaFrequenzaManutenzioni!, "CodiceGenitore": codiceGenitore ?? "CGR"] as [String : Any]
                    listaMacchinariDatabaseRef.child(articoloItem).setValue(anagraficaAggiornata)
                } else {
                    let anagraficaAggiornata = ["Codice": codiceMacchinario.text!, "Descrizione": descrizioneMacchinario.text ?? "","FotoURL": fotoMacchinarioUrl, "ListaManutenzioni": myListaManutenzioni, "ListaFrequenzaManutenzioni": anagraficaMacchinario!.listaFrequenzaManutenzioni!, "CodiceGenitore": codiceGenitore ?? "CGR"] as [String : Any]
                    listaMacchinariDatabaseRef.child(articoloItem).setValue(anagraficaAggiornata)
                    
                }
            } else {
                
                if let myListaCaratteristiche = anagraficaMacchinario?.listaCaratteristiche {
                    let anagraficaAggiornata = ["Codice": codiceMacchinario.text!, "Descrizione": descrizioneMacchinario.text ?? "","FotoURL": fotoMacchinarioUrl,"ListaCaratteristiche": myListaCaratteristiche, "CodiceGenitore": codiceGenitore ?? "CGR"] as [String : Any]
                    listaMacchinariDatabaseRef.child(articoloItem).setValue(anagraficaAggiornata)
                } else {
                    let anagraficaAggiornata = ["Codice": codiceMacchinario.text!, "Descrizione": descrizioneMacchinario.text ?? "","FotoURL": fotoMacchinarioUrl, "CodiceGenitore": codiceGenitore ?? "CGR"] as [String : Any]
                    listaMacchinariDatabaseRef.child(articoloItem).setValue(anagraficaAggiornata)
                    
                }
            }
        }
    }
    
    
    @IBAction func ImageTapped(_ sender: Any) {
        imageTappedCount += 1
        if fotoMacchinarioBis.isHidden == true {
            fotoMacchinarioBis.isHidden = false
        } else {
            fotoMacchinarioBis.isHidden = true
        }
      
    
        let screenSize: CGRect = UIScreen.main.bounds
        if  macchinarioView.frame == originalMacchinarioViewFrame! {
            
            myUIScrollView.frame = CGRect(x: myUIScrollView.frame.origin.x, y: myUIScrollView.frame.origin.y, width: screenSize.width, height: screenSize.height * 0.7)
            macchinarioView.frame = CGRect(x:  macchinarioView.frame.origin.x, y: macchinarioView.frame.origin.y, width: screenSize.width, height: screenSize.height * 0.7)
            macchinarioView.contentMode = .scaleAspectFit
            
        //myUIScrollView.bringSubview(toFront: fotoMacchinarioBis)
            
        } else {
            if imageTappedCount > 2 {
                /*myUIScrollView.superview!.setNeedsLayout()
                myUIScrollView.superview!.layoutIfNeeded()
                macchinarioView.superview!.setNeedsLayout()
                macchinarioView.superview!.layoutIfNeeded()*/
                myUIScrollView.frame = originalScrollViewFrame!
                macchinarioView.frame = originalMacchinarioViewFrame!
                macchinarioView.contentMode = .scaleAspectFit
                imageTappedCount = 0
            }
                

            else {
            myUIScrollView.frame = CGRect(x: myUIScrollView.frame.origin.x, y: myUIScrollView.frame.origin.y, width: screenSize.width, height: screenSize.height * 0.7)
            macchinarioView.frame = CGRect(x:  macchinarioView.frame.origin.x, y: macchinarioView.frame.origin.y, width: screenSize.width, height: screenSize.height * 0.7)
        
            }
        }
    
    }
    
@IBAction func pinchImage(_ sender: UIPinchGestureRecognizer) {
        if let imageView = sender.view {
            imageView.transform = imageView.transform.scaledBy(x: sender.scale, y: sender.scale)
            sender.scale = 1
        }
    }
    
    func controllaUltimaManutenzione(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Storico") { (action, view, completion) in
            //inserire azione dell'azione
            print(self.anagraficaMacchinario?.listaManutenzioni![indexPath.row] ?? "nessun valore")
            
           
            
            
            
                
                //calcola data ultima manutenzione direttamente da firebase
                let manutenzioniDatabaseRef: DatabaseReference = Database.database().reference().child("listaManutenzioni")
            
                 manutenzioniDatabaseRef.queryOrdered(byChild: "codiceMacchinario").queryEqual(toValue: self.anagraficaMacchinario?.codice).observe(.value, with: { (snapShot) in
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd/MM/yy HH:mm"
                    var ultimaData = dateFormatter.date(from: "01/01/01 00:00") as! Date
                    
                    for item in snapShot.children {
                        // carico da Firebase i dati della classe Dettaglio Produzione
                        let firebaseData = item as! DataSnapshot
                        let myManutenzione = firebaseData.value as! [String: Any]
                        let descrizioneManutenzione = myManutenzione["descrizioneManutenzione"] as! String
                        if descrizioneManutenzione == self.anagraficaMacchinario?.listaManutenzioni![indexPath.row] {
                          let dataManutenzioneString: String = String(describing: myManutenzione["dataManutenzione"]!)
                          let dateFormatter = DateFormatter()
                          dateFormatter.dateFormat = "dd/MM/yy HH:mm"
                            let dataManutenzione: Date = dateFormatter.date(from: dataManutenzioneString)!
                            if dataManutenzione > ultimaData {
                                ultimaData = dataManutenzione
                            }
                        }
                    }
                   
                    let df = DateFormatter()
                    df.dateFormat = "dd/MM/yy HH:mm"
                    let ultimaDataString = df.string(from: ultimaData)
                    self.utilizzoMacchinariRef.child((self.anagraficaMacchinario?.codice)!).observe(.value, with: { (data) in
                        
                        if let dataValue = data.value as? [String: Any] {
                            if let listaLavorazioni: [String] = dataValue["ListaLavorazioni"] as? [String] {
                                
                                if ultimaDataString == "01/01/01 00:00" {
                                    let alertController = UIAlertController(title: "Storico Manutenzioni", message: "Manutenzione mai registrata nel database", preferredStyle: UIAlertControllerStyle.alert)
                                    let continuaAction = UIAlertAction(title: "Continua", style: UIAlertActionStyle.default, handler: {
                                        (action : UIAlertAction!) -> Void in })
                                    alertController.addAction(continuaAction)
                                    self.present(alertController, animated: true, completion: nil)
                                }
                                else {
                                self.anagraficaMacchinario?.calcolaProduzioneDaUltimaManutenzione(dataUltimaManutenzione: ultimaDataString, listaLavorazioni: listaLavorazioni, completionHandler: { (somma) in
                                    print(listaLavorazioni)
                                    print("La produzione da ultima manutenzione (\(ultimaDataString)) è \(somma)")
                                    
                                    if let frequenza = self.anagraficaMacchinario?.listaFrequenzaManutenzioni![indexPath.row] {
                                        var messaggio = ""
                                        if somma > frequenza {
                                            messaggio = "Ultima manutenzione: \(ultimaDataString). La manutenzione è in ritardo di \(somma - frequenza) kg"
                                        }
                                        else {
                                            messaggio = "Ultima manutenzione: \(ultimaDataString). Mancano ancora \(frequenza - somma) kg alla prossima manutenzione"
                                        }
                                        let alertController = UIAlertController(title: "Storico Manutenzioni", message: messaggio, preferredStyle: UIAlertControllerStyle.alert)
                                        let continuaAction = UIAlertAction(title: "Continua", style: UIAlertActionStyle.default, handler: {
                                            (action : UIAlertAction!) -> Void in })
                                        alertController.addAction(continuaAction)
                                        self.present(alertController, animated: true, completion: nil)
                                    print(messaggio)
                                    }
                                })
                                }
                                
                                
                            }
                        }
                    })
                 
                 
                 
                 })
                
                //
                
            
            
            
            
            
            completion(true)
            
            
        }
        return action
    }

    
    
    
}


