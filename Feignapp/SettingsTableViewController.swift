//
//  SettingsTableViewController.swift
//  TrainApp
//
//  Created by Joly Axel on 26/02/2018.
//  Copyright © 2018 Axel. All rights reserved.
//

import UIKit
import WatchConnectivity
import Firebase
import SearchTextField
import SwiftyJSON

class SettingsTableViewController: UITableViewController, WCSessionDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var journeyCount: UITextField!
    @IBOutlet weak var departure: SearchTextField!
    @IBOutlet weak var arrival: SearchTextField!
    
    var session : WCSession!
    var firebaseServices: FirebaseServices = FirebaseServices()
    var popupBuilder: CustomPopup = CustomPopup()
    var stationsArray: [StationStruct] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        journeyCount.delegate = self
        
        if WCSession.isSupported() {
            session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
        let defaults = UserDefaults.standard
        if((defaults.string(forKey: "nbJourney")) != nil){
            self.journeyCount.text! = defaults.string(forKey: "nbJourney")!
            self.departure.text! = defaults.string(forKey: "departure")!
            self.arrival.text! = defaults.string(forKey: "arrival")!
        }
        
      
        DispatchQueue.main.async { () -> Void in
        self.displayStationsList()
        self.fillStations(searchTextField: self.departure)
        self.fillStations(searchTextField: self.arrival)
       
        }
    }

    @IBAction func logout(_ sender: Any) {
       self.firebaseServices.logoutFirebase(vc: self)
    }
    
    @IBAction func deleteUserDefaults(_ sender: Any) {
        
        let prefs = UserDefaults.standard
        prefs.removeObject(forKey:"login")
    }

    @IBAction func updateJourney(_ sender: Any) {
        if (Int(journeyCount.text!)! > 10){
            
            popupBuilder.popUp(title: "Error", message: "Size exceeded, setted to 10 by default.", vc: self)
            self.journeyCount.text = "10"
            if(self.departure.text != self.arrival.text){
            self.sendMessage()
             }else{
                popupBuilder.popUp(title: "Error", message: "Your departure can't be your arrival too", vc: self)
            }
        }else{
            self.sendMessage()
        }
        
    }
    
    
    
    
    // Send value of the input UITextfield to the Watch app.
    func sendMessage(){
        let departureGPS = findElementByName(stationName: self.departure.text!)
        let arrivalGPS = findElementByName(stationName: self.arrival.text!)
        
        if departureGPS["error"] != nil{
            popupBuilder.popUp(title: "Error", message: "Something went wrong, please choose your stations again.", vc: self)
        }else{
            let messageToSend = ["nbJourney": self.journeyCount.text, "departureName": self.departure.text, "arrivalName": self.arrival.text, "departureLat": departureGPS["latitude"], "arrivalLat": arrivalGPS["latitude"], "departureLon": departureGPS["longitude"], "arrivalLon": arrivalGPS["longitude"]]
            let defaults = UserDefaults.standard
            let nbJourney = self.journeyCount.text
            defaults.set(nbJourney, forKey: "nbJourney")
            defaults.set(self.departure.text, forKey: "departure")
            defaults.set(self.arrival.text, forKey: "arrival")
            session.sendMessage(messageToSend, replyHandler: { (replyMessage) in
                // Send a message back
            }) { (error) in
                // Catch any error Handler
                self.alertDisplay(title: "Error", message: error.localizedDescription)
                print("error: \(error.localizedDescription)")
            }
        }
        
    }
    
    // Establish session between the Watch App and iOS App. Retrieve how much journey you want.
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
        // Reply handler, received message
        let value = message["Message"] as? String
        
        // GCD - Present on the screen
        DispatchQueue.main.async { () -> Void in
            self.journeyCount.text = value!
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    // Display UIAlertController with title and message parameters.
    func alertDisplay(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func displayStationsList(){
        if let path = Bundle.main.path(forResource: "stationsFiltered", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let stations = JSON(data)
                if (stations != JSON.null) {
                    for i in 0...stations.count {
                        let stationStruct = StationStruct(name: stations[i]["stop_name"].stringValue, latitude: stations[i]["stop_lat"].stringValue, longitude: stations[i]["stop_lon"].stringValue)
                        self.stationsArray.append(stationStruct)
                    }
                }
            } catch {
               print("Ca passe pas")
            }
        }
    }
    
    func fillStations(searchTextField: SearchTextField){
        var temp: [String] = []
        for i in 0...stationsArray.count - 1{
            temp.append(stationsArray[i].name)
        }
        searchTextField.filterStrings(temp)
    }
    
    func findElementByName(stationName: String) -> [String: String]{
        for i in 0...self.stationsArray.count {
            if(stationName == self.stationsArray[i].name){
                return ["latitude": self.stationsArray[i].latitude, "longitude": self.stationsArray[i].longitude];
            }
        }
        return ["error": "Station not found"]
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
   
}

