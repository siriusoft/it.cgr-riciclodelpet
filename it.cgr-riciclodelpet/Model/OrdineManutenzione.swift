//
//  OrdineManutenzione.swift
//  it.cgr-riciclodelpet
//
//  Created by Alberto Rimini on 07/04/18.
//  Copyright © 2018 Alberto Rimini. All rights reserved.
//

import UIKit
import Firebase

class AnagraficaMacchinario {
    var codice: String
    var descrizione: String
    var codiceGenitore: String
    var fotoUrl: String?
    var listaCaratteristiche: [String]?
    var listaManutenzioni: [String]?
    var listaFrequenzaManutenzioni: [Int]?
    
    //var livelloNodo: Int
    
    init(codice: String, descrizione: String, codiceGenitore: String, fotoUrl: String?, listaCaratteristiche: [String]? /*, livelloNodo: Int*/, listaManutenzioni: [String]?, listaFrequenzaManutenzioni: [Int]?  ) {
        self.codice = codice
        self.descrizione = descrizione
        self.codiceGenitore = codiceGenitore
        self.listaCaratteristiche = listaCaratteristiche
        self.fotoUrl = fotoUrl
        self.listaManutenzioni = listaManutenzioni
        self.listaFrequenzaManutenzioni = listaFrequenzaManutenzioni
        
        //self.livelloNodo = livelloNodo
        }
    

    
    
    func calcolaProduzioneDaUltimaManutenzione(dataUltimaManutenzione: String, listaLavorazioni:[String] ,completionHandler:@escaping (Int) -> ()) {
        let quantitaRef: DatabaseReference = Database.database().reference().child("quantita")
        var somma: Int = 0
        quantitaRef.observe(.value) { (snapShot) in
            
            for item in snapShot.children {
                // carico da Firebase i dati della classe Dettaglio Produzione
                let firebaseData = item as! DataSnapshot
                //print(lotto)
                let lottoProduzione = firebaseData.value as! [String: Any]
                let dataProduzioneString: String = lottoProduzione["dataFineLotto"] as! String
                let quantita: Int = lottoProduzione["quantita"] as! Int
                let lavorazione: String = lottoProduzione["lavorazione"] as! String
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yy HH:mm"
                if let dataProduzione = dateFormatter.date(from: dataProduzioneString), let data = dateFormatter.date(from: dataUltimaManutenzione) {
                    if listaLavorazioni.contains(lavorazione) && data < dataProduzione {
                        somma += quantita
                    }
                }
                
                
            }
            completionHandler(somma)
        }
        
    }
    
    func calcolaDataUltimaManutenzione(codiceMacchinario: String, descrizioneManutenzione: String, completion:  @escaping (String)-> Void)  {
        
        //codice per caricare da firebase la lista di manutenzioni
        
        let manutenzioniDatabaseRef: DatabaseReference = Database.database().reference().child("listaManutenzioni")
        
        manutenzioniDatabaseRef.queryOrdered(byChild: "codiceMacchinario").queryEqual(toValue: codiceMacchinario).observe(.value, with: { (snapShot) in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yy HH:mm"
            var ultimaData = dateFormatter.date(from: "01/01/01 00:00") as! Date
            for item in snapShot.children {
                // carico da Firebase i dati della classe Dettaglio Produzione
                let firebaseData = item as! DataSnapshot
                let myManutenzione = firebaseData.value as! [String: Any]
                let descrizioneManutenzioneEseguita = myManutenzione["descrizioneManutenzione"] as! String
                if descrizioneManutenzioneEseguita == descrizioneManutenzione {
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
           // print("L'ultima \(descrizioneManutenzione) di \(codiceMacchinario) è \(ultimaDataString)")
            completion(ultimaDataString)
            })
        // fine codice per caricare da firebase la lista di manutenzioni
        
       
    }
    
            
            
        
        
    
        
        
    
}


class Manutenzione {
    var codiceMacchinario: String
    var descrizioneManutenzione: String
    var autore:String
    var dataManutenzione: Date
    var note: String
    
    init(codiceMacchinario: String, descrizioneManutenzione: String, autore: String, dataManutenzione:Date, note: String) {
        self.codiceMacchinario = codiceMacchinario
        self.descrizioneManutenzione = descrizioneManutenzione
        self.autore = autore
        self.dataManutenzione = dataManutenzione
        self.note = note
    }
    
    func calcolaProduzioneDaUltimaManutenzione(listaLavorazioni:[String], completionHandler:@escaping (Int) -> ()) {
        let quantitaRef: DatabaseReference = Database.database().reference().child("quantita")
        var somma: Int = 0
        quantitaRef.observe(.value) { (snapShot) in
        
            for item in snapShot.children {
                // carico da Firebase i dati della classe Dettaglio Produzione
                let firebaseData = item as! DataSnapshot
                //print(lotto)
                let lottoProduzione = firebaseData.value as! [String: Any]
                let dataProduzioneString: String = lottoProduzione["dataFineLotto"] as! String
                let quantita: Int = lottoProduzione["quantita"] as! Int
                let lavorazione: String = lottoProduzione["lavorazione"] as! String
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yy HH:mm"
                
                if let dataProduzione = dateFormatter.date(from: dataProduzioneString) {
                    if self.dataManutenzione < dataProduzione && listaLavorazioni.contains(lavorazione) {
                        print("Lotto \(firebaseData.key): \(quantita) kg")
                        somma += quantita
                    }
                }
            
    
            }
            completionHandler(somma)
        }
     
    }
}
class AnagraficaIstruzione {
    var codice: String
    var descrizione: String
    var codiceGenitore: String
    var fotoUrl: String?
    var listaPassi: [String]?
    
    
    //var livelloNodo: Int
    
    init(codice: String, descrizione: String, codiceGenitore: String, fotoUrl: String?, listaPassi: [String]? /*, livelloNodo: Int*/  ) {
        self.codice = codice
        self.descrizione = descrizione
        self.codiceGenitore = codiceGenitore
        self.listaPassi = listaPassi
        self.fotoUrl = fotoUrl
    }

/*class OrdineManutenzione {
    var numeroOrdine: Int
    var richiedenteId: String
    var dataIniziale: String
    var impianto: String
    var descrizioneManutenzione: String
    var listaImmagini: [UIImage]?
    var noteImmagini:[String]?
    var approvato: String /* si o no */
    var urgenza: Int?
    var approvatoreId: String?
    var esecutoreId: [String]?
    var descrizioneAttivita: [String]?
    var dataAttivita: [String]?
    var completata: String
    var dataFinale: String?
    
    init(numeroOrdine: Int, richiedenteId: String, dataIniziale: String, impianto: String, descrizioneManutenzione: String, listaImmagini: [UIImage]?,  noteImmagini: [String]?, approvato: String, urgenza: Int?, approvatoreId: String?, esecutoreId: [String]?, descrizioneAttivita: [String]?, dataAttivita: [String], completata: String, dataFinale: String? ) {
        self.numeroOrdine = numeroOrdine
        self.richiedenteId = richiedenteId
        self.dataIniziale = dataIniziale
        self.impianto = impianto
        self.descrizioneManutenzione = descrizioneManutenzione
        self.listaImmagini = listaImmagini
        self.noteImmagini = noteImmagini
        self.approvato = approvato
        self.urgenza = urgenza
        self.approvatoreId = approvatoreId
        self.esecutoreId = esecutoreId
        self.descrizioneAttivita = descrizioneAttivita
        self.dataAttivita = dataAttivita
        self.completata = completata
        self.dataFinale = dataFinale

        
    }*/
}

