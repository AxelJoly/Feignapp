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

class SettingsTableViewController: UITableViewController, WCSessionDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var journeyCount: UITextField!
    
    var session : WCSession!
    var firebaseServices: FirebaseServices = FirebaseServices()
    var popupBuilder: CustomPopup = CustomPopup()
    
    
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
            journeyCount.text! = defaults.string(forKey: "nbJourney")!
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
            self.sendMessage()
        }else{
            self.sendMessage()
        }
        
    }

    // Send value of the input UITextfield to the Watch app.
    func sendMessage(){
        
        let messageToSend = ["Message": self.journeyCount.text]
        let defaults = UserDefaults.standard
        let nbJourney = self.journeyCount.text
        defaults.set(nbJourney, forKey: "nbJourney")
        session.sendMessage(messageToSend, replyHandler: { (replyMessage) in
            let value = replyMessage["Message"] as? String
            DispatchQueue.main.async(execute: { () -> Void in
                self.journeyCount.text! = value!
            })
        }) { (error) in
            // Catch any error Handler
            self.alertDisplay(title: "Error", message: error.localizedDescription)
            print("error: \(error.localizedDescription)")
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
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
}
extension String {
    func truncated() -> Substring {
        return prefix(1)
    }
}

