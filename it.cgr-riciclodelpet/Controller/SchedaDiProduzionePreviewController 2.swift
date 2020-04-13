//
//  SchedaDiProduzionePreviewController.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 17/03/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//

import UIKit
import MessageUI
import Firebase


class SchedaDiProduzionePreviewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var webPreview: UIWebView!
    
    var listaProduzioneDaStampare: [DettaglioProduzione]?
    
    var schedaDiProduzioneComposer = SchedaDiProduzioneComposer()
    
    var HTMLContent: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        createSchedaDiProduzioneAsHTML()
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
        schedaDiProduzioneComposer.exportHTMLContentToPDF(HTMLContent: HTMLContent, printFormatter: webPreview.viewPrintFormatter())
        showOptionsAlert()
    }
    
    
    // MARK: Custom Methodspa
    
    func createSchedaDiProduzioneAsHTML() {
       
        schedaDiProduzioneComposer.renderInvoice(listaDaStampare: listaProduzioneDaStampare!, completionHandler: {(schedaDiProduzioneHTML) in
            if let schedaDiProduzioneHTMLNonVuota = schedaDiProduzioneHTML {
            
                self.webPreview.loadHTMLString(schedaDiProduzioneHTMLNonVuota, baseURL: NSURL(string: (self.schedaDiProduzioneComposer.pathToInvoiceHTMLTemplate!))! as URL)
                self.HTMLContent = schedaDiProduzioneHTML
            }
        })
    }
    
    
    
    func showOptionsAlert() {
        let alertController = UIAlertController(title: "Invia Scheda di Produzoine List", message: "Le schede di produziono sono state esportate in un file .pdf. Cosa vuoi fare adesso?", preferredStyle: UIAlertControllerStyle.alert)
        
        let actionPreview = UIAlertAction(title: "Creare Anteprima", style: UIAlertActionStyle.default) { (action) in
            if let filename = self.schedaDiProduzioneComposer.pdfFilename, let url = URL(string: filename) {
                let request = URLRequest(url: url)
                self.webPreview.loadRequest(request)
            }
        }
        
        let actionEmail = UIAlertAction(title: "Invia file per Email", style: UIAlertActionStyle.default) { (action) in
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
            mailComposeViewController.setSubject("Schede di Produzone")
            mailComposeViewController.addAttachmentData(NSData(contentsOfFile: (schedaDiProduzioneComposer.pdfFilename)!)! as Data, mimeType: "application/pdf", fileName: "SchedeDiProduzione")
            present(mailComposeViewController, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}




