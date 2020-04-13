//
//  EtichettaViewController.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 16/02/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//

import UIKit
import Firebase
    class EtichettaViewController: UIViewController, UIPrintInteractionControllerDelegate  {

   
    var codiceBarraTesto: String?
    var filter: CIFilter!
    let anagraficaArticoliRef: DatabaseReference = Database.database().reference().child("anagraficaArticoli")
    @IBOutlet weak var codiceLabel: UILabel!
    @IBOutlet weak var descrizioneLabel: UILabel!
    @IBOutlet weak var quantitaLabel: UILabel!
    
    @IBOutlet weak var taraLabel: UILabel!
    @IBOutlet weak var lottoLabel: UILabel!
    
    @IBOutlet weak var bigBagNumeroLabel: UILabel!
    
    @IBOutlet weak var codiceBarraLabel: UILabel!
    @IBOutlet weak var codiceImage: UIImageView!
    
    @IBOutlet weak var EtichettaView: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // codiceBarraTesto = "L9000M1PETLMACN1TPI01"
        if let barCode = codiceBarraTesto {
            let data = barCode.data(using: .ascii, allowLossyConversion: false)
           // filter = CIFilter(name: "CICode128BarcodeGenerator")
            filter = CIFilter(name: "CIQRCodeGenerator")
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let image = UIImage(ciImage: filter.outputImage!.transformed(by: transform))
            codiceImage.image = image
            codiceBarraLabel.text = barCode
            
            let lottoLowerBound = barCode.range(of: "L%")!.upperBound
            let lottoUpperBound = barCode.range(of: "N%")!.lowerBound
            lottoLabel.text = String(barCode[lottoLowerBound..<lottoUpperBound])
            
            let quantitaLowerBound = barCode.range(of: "Q%")!.upperBound
            let quantitaUpperBound = barCode.range(of: "T%")!.lowerBound
            quantitaLabel.text = String(barCode[quantitaLowerBound..<quantitaUpperBound]) + " Kg"
            
            let taraLowerBound = barCode.range(of: "T%")!.upperBound
            let taraUpperBound = barCode.range(of: "F%")!.lowerBound
            taraLabel.text =  String(barCode[taraLowerBound..<taraUpperBound]) + " Kg"
            
            let codiceLowerBound = barCode.range(of: "I%")!.upperBound
            let codiceUpperBound = barCode.range(of: "L%")!.lowerBound
            codiceLabel.text = String(barCode[codiceLowerBound..<codiceUpperBound])
            
            let bbNumeroLowerBound = barCode.range(of: "N%")!.upperBound
            let bbNumeroUpperBound = barCode.range(of: "Q%")!.lowerBound
            bigBagNumeroLabel.text = String(barCode[bbNumeroLowerBound..<bbNumeroUpperBound])
            
            anagraficaArticoliRef.child(codiceLabel.text!).observe(.value) { (snap) in
                guard let schedaAnagrafica = snap.value as? [String: Any] else {
                    let alert = UIAlertController(title: "Attenzione!", message: "Codice articolo non trovato.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    //print("codice articolo non trovato.")
                    return
                }
                if let descrizioneEstesa = schedaAnagrafica["DescrizioneEstesa"] {
                    self.descrizioneLabel.text = String(describing: descrizioneEstesa)
                }
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
        func printInteractionController(_ printInteractionController: UIPrintInteractionController, choosePaper paperList: [UIPrintPaper]) -> UIPrintPaper {
            print(paperList)
            return(paperList[1])
        }
    
    @IBAction func stampaEtichetta(_ sender: Any) {
        
        
 /*
        // 2. Assign print formatter to UIPrintPageRenderer
        
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(fmt, startingAtPageAtIndex: 0)
       
        // 3. Assign paperRect and printableRect
        
        let page = CGRect(x: 0, y: 0, width:595.2, height: 420.9) // A5, 72 dpi
        
        let printable = page.insetBy(dx: 0, dy: 0)
        
        render.setValue(NSValue(cgRect: page), forKey: "paperRect")
        render.setValue(NSValue(cgRect: printable), forKey: "printableRect")
       
 */
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = UIPrintInfoOutputType.general
        printInfo.jobName = "My Print Job"
        printInfo.orientation = .portrait // IT DOES NOTHING!!!!!!
        
        // Set up print controller
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        printController.showsPaperSelectionForLoadedPapers = true
        
        // Assign a UIImage version of my UIView as a printing iten
        let myImage = EtichettaView!.toImage()
        let borderHeight: CGFloat = 100.0
        let borderWidth: CGFloat = 20.0
        let internalPrintView = UIImageView(frame: CGRect(x:0, y:0, width: myImage.size.width, height: myImage.size.height))
        let printView = UIView(frame: CGRect(x:0, y:0, width: myImage.size.width + borderWidth*2, height: myImage.size.height + borderHeight*2))
        internalPrintView.image = myImage
        internalPrintView.center = CGPoint(x: printView.frame.size.width/2, y: printView.frame.size.height/4)
        printView.addSubview(internalPrintView)
        printController.printingItem = printView.toImage()
       
        
        // Do it
        printController.present(from: self.view.frame, in: self.view, animated: true, completionHandler: nil)
    }
        
}

extension UIView {
    func toImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

extension UIImage {
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
