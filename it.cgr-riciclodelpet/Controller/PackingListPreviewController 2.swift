//
//  PackingListPreviewController.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 11/03/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//

import UIKit
import MessageUI


class PackingListPreviewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var webPreview: UIWebView!
    
    var packingListInfo: PackingList!
    
    var packingListComposer: PackingListComposer!
    
    var HTMLContent: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        createPackingListAsHTML()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: IBAction Methods
    
    
    @IBAction func exportToPDF(_ sender: AnyObject) {
        packingListComposer.exportHTMLContentToPDF(HTMLContent: HTMLContent, printFormatter: webPreview.viewPrintFormatter())
        showOptionsAlert()
    }
    
    
    // MARK: Custom Methodspa
    
    func createPackingListAsHTML() {
        
        let alertController = UIAlertController(title: "Completa dati per PL", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Inserisci Cliente"
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Inserisci Numero Ordine Cliente"
        }
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Inserisci Data Ordine Cliente"
        }
        let saveAction = UIAlertAction(title: "Salva", style: UIAlertActionStyle.default, handler: { alert -> Void in
            let cliente = alertController.textFields![0] as UITextField
            let ordineCliente = alertController.textFields![1] as UITextField
            let dataOrdineCliente = alertController.textFields![2] as UITextField
            if let packingListHTML = self.packingListComposer.renderInvoice(packingListInfo: self.packingListInfo, recipientInfo: cliente.text!, ordineNumero: ordineCliente.text!, ordineData: dataOrdineCliente.text!) {
                
                self.webPreview.loadHTMLString(packingListHTML, baseURL: NSURL(string: self.packingListComposer.pathToInvoiceHTMLTemplate!)! as URL)
                self.HTMLContent = packingListHTML
            }
        })
        let cancelAction = UIAlertAction(title: "Annulla", style: UIAlertActionStyle.default, handler: {
            (action : UIAlertAction!) -> Void in })
        
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        packingListComposer = PackingListComposer()
        
        
    }
    
    
    
    func showOptionsAlert() {
        let alertController = UIAlertController(title: "Invia Packing List", message: "Il tuo packng list è stato esportato in un file .pdf. Cosa vuoi fare adesso?", preferredStyle: UIAlertControllerStyle.alert)
        
        let actionPreview = UIAlertAction(title: "Creare Anteprima", style: UIAlertActionStyle.default) { (action) in
            if let filename = self.packingListComposer.pdfFilename, let url = URL(string: filename) {
                let request = URLRequest(url: url)
                self.webPreview.loadRequest(request)
            }
        }
        
        let actionEmail = UIAlertAction(title: "Invialo per Email", style: UIAlertActionStyle.default) { (action) in
            DispatchQueue.main.async {
                self.sendEmail()
            }
        }
        
        let actionNothing = UIAlertAction(title: "Nulla", style: UIAlertActionStyle.default) { (action) in
            
        }
        
        alertController.addAction(actionPreview)
        alertController.addAction(actionEmail)
        alertController.addAction(actionNothing)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController.mailComposeDelegate = self
            mailComposeViewController.setSubject("Packing List")
            mailComposeViewController.addAttachmentData(NSData(contentsOfFile: packingListComposer.pdfFilename)! as Data, mimeType: "application/pdf", fileName: "PackingList")
            present(mailComposeViewController, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}



