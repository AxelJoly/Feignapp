//
//  HomeViewController.swift
//  TrainApp
//
//  Created by Joly Axel on 24/02/2018.
//  Copyright © 2018 Axel. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {

    @IBOutlet weak var userLabel: UILabel!
    
    var firebaseService: FirebaseServices = FirebaseServices()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // getInfosFirebase()
        firebaseService.getInfosFirebase(label: userLabel!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func logout(_ sender: Any) {
        firebaseService.logoutFirebase(vc: self)
    }
    
}
