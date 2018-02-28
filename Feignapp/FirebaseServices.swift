//
//  FirebaseInterface.swift
//  TrainApp
//
//  Created by Joly Axel on 26/02/2018.
//  Copyright © 2018 Axel. All rights reserved.
//

import UIKit
import Firebase

class FirebaseServices {
    
    var popupBuilder: CustomPopup = CustomPopup()
    // Retrieve user data from Firebase
    func getInfosFirebase(label: UILabel){
        let user = Auth.auth().currentUser
        if let user = user {
            let email = user.email!
            label.text! = "Welcome \(String(describing: email))"
        }
    }
    
    // Close the user's session with Firebase Auth and return to the home page
    func logoutFirebase(vc: UIViewController){
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("logout successfully.")
            vc.dismiss(animated: true, completion: {});
            vc.navigationController?.popViewController(animated: true);
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    func loginFirebase(email: String, password: String, vc: UIViewController){
        Auth.auth().signIn(withEmail: email , password: password) { (user, error) in
            if let error = error{
                self.popupBuilder.popUp(title: "Error", message: "Bad email / password.", vc: vc)
            }else if let user = user{
                let defaults = UserDefaults.standard
                let login = ["email": email, "password": password]
                defaults.set(login, forKey: "login")
                print("Logged in!")
                vc.performSegue(withIdentifier: "Login", sender: self)
            }
        }
    }
    
}
