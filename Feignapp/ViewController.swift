//
//  ViewController.swift
//  TrainApp
//
//  Created by Joly Axel on 27/01/2018.
//  Copyright © 2018 Axel. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import FirebaseAuth
import PopupDialog
import LocalAuthentication


class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var wallpaperImage: UIImageView!
    
    var dataArray: NSMutableArray = NSMutableArray()
    var state: boolean_t = 0
    var firebaseServices: FirebaseServices = FirebaseServices()
    var popupBuilder: CustomPopup = CustomPopup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        textFieldPlaceholderInit(textField: passwordTextField, placeholder: "Password", color: UIColor.init(white: 0.9, alpha: 0.9))
        textFieldPlaceholderInit(textField: emailTextField, placeholder: "Email", color: UIColor.init(white: 0.9, alpha: 0.9))
        emailTextField.textColor = UIColor.white
        passwordTextField.textColor = UIColor.white
        setPaddingPlaceholder(textField: self.emailTextField)
        setPaddingPlaceholder(textField: self.passwordTextField)
        // Do any additional setup after loading the view, typically from a nib.
   
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Login function to FirebaseAuth service.
    @IBAction func login(_ sender: Any) {
       self.firebaseServices.loginFirebase(email: self.emailTextField.text!, password: self.passwordTextField.text!, vc: self)
    }
    
    @IBAction func authFaceID(_ sender: Any) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [unowned self] (success, authenticationError) in
                
                DispatchQueue.main.async {
                    if success {
                        print("FaceID-ed!")
                        let defaults = UserDefaults.standard
                        let log = defaults.dictionary(forKey: "login")
                        
                        if(log != nil){
                            
                            let email = log!["email"] as! String
                            let password = log!["password"] as! String
                            self.firebaseServices.loginFirebase(email: email, password: password, vc: self)
                        
                    } else {
                        // error
                            self.popupBuilder.popUp(title: "Error", message: "No user setted. Please log in a first time to configure.", vc: self)
                            print("error!")
                         
                    }
                    }else{
                        self.popupBuilder.popUp(title: "Error", message: "Too ugly to be the owner.", vc: self)
                        print("error!")
                    }
                }
            }
        } else {
            // no biometry
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == emailTextField  {
            wallpaperImage.fadeOut()
            placeholderState()
        }
        if textField == passwordTextField {
            wallpaperImage.fadeOut()
            placeholderState()
        }
    }
    
    // Return key dismiss keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        wallpaperImage.fadeIn()
        return true
    }
    
    // Touching outside dismiss keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        wallpaperImage.fadeIn()
        self.view.endEditing(true)
    }
    
    // When textfields are empty, placeholder should set the default value.
    func placeholderState(){
        
        if(passwordTextField.text != ""){
            textFieldPlaceholderInit(textField: passwordTextField, placeholder: "", color: UIColor.init(white: 0.8, alpha: 0.8))
            
        }else{
            textFieldPlaceholderInit(textField: passwordTextField, placeholder: "Password", color: UIColor.init(white: 0.8, alpha: 0.8))
           textFieldPlaceholderInit(textField: emailTextField, placeholder: "Email", color: UIColor.init(white: 0.8, alpha: 0.8))
        }
        if(emailTextField.text != ""){
            textFieldPlaceholderInit(textField: emailTextField, placeholder: "", color: UIColor.init(white: 0.8, alpha: 0.8))
        }else{
            textFieldPlaceholderInit(textField: passwordTextField, placeholder: "Password", color: UIColor.init(white: 0.8, alpha: 0.8))
            textFieldPlaceholderInit(textField: emailTextField, placeholder: "Email", color: UIColor.init(white: 0.8, alpha: 0.8))
        }
    }
    
    // Set placeholder value to the textfield
    func textFieldPlaceholderInit(textField: UITextField, placeholder: String, color: UIColor){
       textField.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                            attributes: [NSAttributedString.Key.foregroundColor: color])
    }
    
    // Set padding of placeholder from the left corner
    func setPaddingPlaceholder(textField: UITextField){
        let paddingView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 15, height: textField.frame.height)))
        textField.leftView = paddingView
        textField.leftViewMode = UITextField.ViewMode.always
    }
    
}

//Extension of UIView defining fading in and out functions to animate the view
extension UIView {
    func fadeIn(_ duration: TimeInterval = 0.3, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)  }
    
    func fadeOut(_ duration: TimeInterval = 0.3, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.7
        }, completion: completion)
    }
}

