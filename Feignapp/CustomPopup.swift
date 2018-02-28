//
//  CustomPopup.swift
//  TrainApp
//
//  Created by Joly Axel on 27/02/2018.
//  Copyright © 2018 Axel. All rights reserved.
//

import Foundation
import PopupDialog

class CustomPopup{
    
    // create popup with input title and message and display it in the current VC.
    func popUp(title: String, message: String, vc: UIViewController){
        let popup = PopupDialog(title: title, message: message)
        let buttonOne = CancelButton(title: "CANCEL") {
            print("Login stopped")
        }
        popup.addButtons([buttonOne])
        vc.present(popup, animated: true, completion: nil)
    }
}
