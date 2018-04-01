//
//  ScannerViewController.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 24/02/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//

import UIKit
import AVFoundation

protocol ShowPackingList {
   func AddItemtoPackingList(dettaglioPackingList: PackingList)
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var delegate: ShowPackingList?
    var captureDevice:AVCaptureDevice?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    

    var packingListCompleto: PackingList?
   
    
    var barCodeString: String?
    
    @IBOutlet weak var scannedLabelText: UILabel!
    let codeFrame:UIView = {
        let codeFrame = UIView()
        codeFrame.layer.borderColor = UIColor.green.cgColor
        codeFrame.layer.borderWidth = 2
        codeFrame.frame = CGRect.zero
        codeFrame.translatesAutoresizingMaskIntoConstraints = false
        return codeFrame
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    
        print("Packing list id: \(packingListCompleto!.identificativo)")
       /* let leftSwipe = UISwipeGestureRecognizer(target: self, action:  #selector(swipeAction(swipe:)))
        leftSwipe.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(leftSwipe) */
        
        
        navigationItem.title = "Scanner"
        view.backgroundColor = .white
        
        captureDevice = AVCaptureDevice.default(for: .video)
        // Check if captureDevice returns a value and unwrap it
        if let captureDevice = captureDevice {
            
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                
                let captureSession = AVCaptureSession()
                captureSession.addInput(input)
                
                let captureMetadataOutput = AVCaptureMetadataOutput()
                captureSession.addOutput(captureMetadataOutput)
                
                captureMetadataOutput.setMetadataObjectsDelegate(self, queue: .main)
                captureMetadataOutput.metadataObjectTypes = [.code128, .qr, .ean13,  .ean8, .code39] //AVMetadataObject.ObjectType
                
                captureSession.startRunning()
                
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                videoPreviewLayer?.videoGravity = .resizeAspectFill
                let scannerFrame = CGRect(x: 15, y: 10, width: 300, height: 300)
                
                videoPreviewLayer?.frame = scannerFrame
                view.layer.addSublayer(videoPreviewLayer!)
                
                
            } catch {
                let alert = UIAlertController(title: "Errore!", message: "Dispositivo non trova la telecamera!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                print("Error Device Input")
            }
            
        }
        
    }
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            //print("No Input Detected")
            codeFrame.frame = CGRect.zero
            scannedLabelText.text = "No Data"
            barCodeString = "No Data"
            return
        }
        
        let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        guard let stringCodeValue = metadataObject.stringValue else { return }
        
        view.addSubview(codeFrame)
        
        guard let barcodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObject) else { return }
        codeFrame.frame = barcodeObject.bounds
        
        if let itemScanned = inserisciItemDaQrCode(barCode: stringCodeValue) {
        barCodeString = stringCodeValue
        scannedLabelText.text = "\(itemScanned.codice), \(itemScanned.lotto)\nN.\(String(describing: itemScanned.numeroBb)), \(String(describing: itemScanned.quantityKg)) Kg"
        }
       
        
       
        
    /*    // Play system sound with custom mp3 file
       if let customSoundUrl = Bundle.main.url(forResource: "beep-07", withExtension: "mp3") {
            let customSoundId: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(customSoundUrl as CFURL, &amp;customSoundId)
            //let systemSoundId: SystemSoundID = 1016  // to play apple's built in sound, no need for upper 3 lines
            */
        let customSoundId: SystemSoundID = 1016
        AudioServicesAddSystemSoundCompletion(customSoundId, nil, nil, { (customSoundId, _) -> Void in
                AudioServicesDisposeSystemSoundID(customSoundId)
            }, nil)
            
            AudioServicesPlaySystemSound(customSoundId)
 
        
    }
    func inserisciItemDaQrCode(barCode: String) -> ItemProdottoFinito? {
        
        
        
        guard let lottoLowerBound = barCode.range(of: "L%")?.upperBound else {return nil}
        guard let lottoUpperBound = barCode.range(of: "N%")?.lowerBound else{ return nil}
        let lotto = String(barCode[lottoLowerBound..<lottoUpperBound])
        
        guard let quantitaLowerBound = barCode.range(of: "Q%")?.upperBound else{ return nil}
        guard let quantitaUpperBound = barCode.range(of: "T%")?.lowerBound else{ return nil}
        let quantityKg = Int(String(barCode[quantitaLowerBound..<quantitaUpperBound]))
        
        guard let taraLowerBound = barCode.range(of: "T%")?.upperBound else{ return nil}
        guard let taraUpperBound = barCode.range(of: "F%")?.lowerBound else{ return nil}
        let taraKg = Int(String(barCode[taraLowerBound..<taraUpperBound]))
        
        guard let codiceLowerBound = barCode.range(of: "I%")?.upperBound else{ return nil}
        guard let codiceUpperBound = barCode.range(of: "L%")?.lowerBound else{ return nil}
        let codice = String(barCode[codiceLowerBound..<codiceUpperBound])
        
        guard let bbNumeroLowerBound = barCode.range(of: "N%")?.upperBound else{ return nil}
        guard let bbNumeroUpperBound = barCode.range(of: "Q%")?.lowerBound else{ return nil}
        let numeroBb = Int(String(barCode[bbNumeroLowerBound..<bbNumeroUpperBound]))
        
       
        
        let itemProdottoFinito = ItemProdottoFinito(codice: codice, lotto: lotto, numeroBb: numeroBb!, quantityKg: quantityKg!, taraKg: taraKg!, dataProduzione: "", codiceBarra: barCode)
        
        return itemProdottoFinito
        
    }
    
    @IBAction func addItemToPackingList(_ sender: Any) {
       
        //aggiungere controllo che l'item non sia già stato inserito nell'array packingList
        
        if let barCode = barCodeString {
            let myBarCode = CodiceBarra(barCode: barCode)
            if let itemToPackingList = myBarCode.riconosciQrCode() {
                
                if contenutoInPackingList(qrCode: barCode) {
                print("Collo già presente nella lista")
                    let alert = UIAlertController(title: "Attenzione!", message: "Collo già presente nella lista, impossibile aggiungerlo!", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                packingListCompleto!.listaColli?.append(itemToPackingList)
                
                delegate?.AddItemtoPackingList(dettaglioPackingList: packingListCompleto!)
                self.dismiss(animated: true, completion: nil)
                
                }
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


        
  /*  @objc func swipeAction(swipe: UISwipeGestureRecognizer) {
        switch swipe.direction.rawValue {
        case 1:
            performSegue(withIdentifier: "backToPackingListSegue", sender: packingListCompleto)
        case 2:
            performSegue(withIdentifier: "backToPackingListSegue", sender: packingListCompleto)
        default:
            break
        }
    } */
    
   
    
    func contenutoInPackingList(qrCode: String) -> Bool {
        for item in packingListCompleto!.listaColli! {
            if item.codiceBarra == qrCode {
                return true
            }
        }
        return false
    }
    
}
