//
//  ViewController.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/21/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

// UIVars

// FieldVars

// Actions

// Functions

// Override functions

import UIKit
import TextFieldEffects
import BFPaperButton
import SwiftString
import SCLAlertView
import FirebaseAuth
import SwiftSpinner
import FirebaseDatabase
import GoogleSignIn
import Firebase

class LoginVC: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate{
    // UIVars
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var emailField: KaedeTextField!
    @IBOutlet weak var passwordField: KaedeTextField!
    @IBOutlet weak var loginBtn: BFPaperButton!
    @IBOutlet weak var signupBtn: BFPaperButton!
    @IBOutlet weak var resetBtn: BFPaperButton!
    @IBOutlet weak var googleLoginBtn: GIDSignInButton!
    
    // FieldVars
    var repassField: UITextField?
    
    // Actions
    @IBAction func loginAct(_ sender: AnyObject) {
        if checkEmail(showAlert: true) && checkPassword(showAlert: true){
            let spinner = SwiftSpinner.show("Login...")
            spinner.backgroundColor = themeColor
            FIRAuth.auth()?.signIn(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
                DispatchQueue.main.async(execute: {
                    SwiftSpinner.hide()
                    if let error = error{
                        _ = SCLAlertView().showError("Sorry", subTitle: error.localizedDescription)
                    }
                    else if let user = user{
                        let standard = UserDefaults.standard
                        standard.set(self.emailField.text!, forKey: "username")
                        standard.set(self.passwordField.text!, forKey: "password")
                        currUser = UserModel.getUser(uid: user.uid, getWall: true, getProfile: true)
                        drawer.centerViewController = VC(name: "Question")
                        self.show(drawer, sender: self)
                    }
                    else {
                        _ = SCLAlertView().showError("Sorry", subTitle: "Unable to find the user.")
                    }
                })
            })
        }
    }
    @IBAction func signupAct(_ sender: AnyObject) {
        if checkEmail(showAlert: true) && checkPassword(showAlert: true){
            showConfirmPsw()
        }
    }
    @IBAction func resetAct(_ sender: AnyObject) {
        if let text = emailField.text , text.isEmail(){
            let spinner = SwiftSpinner.show("Processing...")
            spinner.backgroundColor = themeColor
            FIRAuth.auth()?.sendPasswordReset(withEmail: text, completion: { (error) in
                SwiftSpinner.hide()
                DispatchQueue.main.async(execute: {
                    if let error = error{
                        _ = SCLAlertView().showError("Sorry", subTitle: error.localizedDescription)
                    }
                    else {
                        _ = SCLAlertView().showSuccess("Success", subTitle: "An Email to reset password has been sent to you.")
                    }
                })
            })
        }
        else {
            _ = SCLAlertView().showError("Sorry", subTitle: "Incorrect Email format.")
        }
    }
    
    // Functions
    func initUI(){
        logoImg.setup(radius: 64)
        emailField.setup(radius: 5)
        passwordField.setup(radius: 5)
        loginBtn.setup(radius: 5)
        signupBtn.setup(radius: 5)
        resetBtn.setup(radius: 5)
        loginBtn.backgroundColor = themeColor
        signupBtn.backgroundColor = themeColor
    }
    
    func initNoti(){
        let notiCenter = NotificationCenter.default
        notiCenter.addObserver(self, selector: #selector(emailChange(noti:)), name: Notification.Name.UITextFieldTextDidChange, object: emailField)
        notiCenter.addObserver(self, selector: #selector(passwordChange(noti:)), name: Notification.Name.UITextFieldTextDidChange, object: passwordField)
    }
    
    func emailChange(noti:Notification) {
        if checkEmail(){
            emailField.textColor = UIColor.black
        }
        else {
            emailField.textColor = UIColor.red
        }
    }
    
    func passwordChange(noti:Notification) {
        if checkPassword(){
            passwordField.textColor = UIColor.black
        }
        else {
            passwordField.textColor = UIColor.red
        }
    }
    
    func checkEmail(showAlert:Bool = false) -> Bool {
        if emailField.text!.isEmail() {
            return true
        }
        else {
            if showAlert{
                _ = SCLAlertView().showError("Sorry", subTitle: "Incorrect Email format.")
            }
            return false
        }
    }
    
    func checkPassword(showAlert:Bool = false) -> Bool{
        if passwordField.text!.length >= 6 {
            return true
        }
        else {
            if showAlert{
                _ = SCLAlertView().showError("Sorry", subTitle: "A valid password has at lease 6 characters.")
            }
            return false
        }
    }
    
    func showConfirmPsw() {
        let alert = SCLAlertView()
        repassField = alert.addTextField()
        repassField?.isSecureTextEntry = true
        _ = alert.addButton("Done", action: alertClose)
        _ = alert.showEdit("Sign up", subTitle: "Please re-enter your password.", closeButtonTitle: "Cancel")
    }
    
    func alertClose(){
        if let text = repassField?.text{
            if text != passwordField.text{
                _ = SCLAlertView().showError("Sorry", subTitle: "Two passwords are not the same")
            }
            else {
                let spinner = SwiftSpinner.show("Signing up...")
                spinner.backgroundColor = themeColor
                FIRAuth.auth()?.createUser(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
                    SwiftSpinner.hide()
                    if let error = error{
                        _ = SCLAlertView().showError("Sorry", subTitle: error.localizedDescription)
                    }
                    else if let user = user{
                        let ref = FIRDatabase.database().reference().child("Users").child(user.uid)
                        ref.child("email").setValue(user.email)
                        currUser = UserModel.getUser(uid: user.uid, getWall: true, getProfile: true)
                        let alert = SCLAlertView().showSuccess("Success", subTitle: "Signup successfully!")
                        let standard = UserDefaults.standard
                        standard.set(user.email, forKey: "username")
                        standard.set(self.passwordField.text, forKey: "password")
                        alert.setDismissBlock({ 
                            drawer.centerViewController = VC(name: "Question")
                            self.show(drawer, sender: self)
                        })
                    }
                    else {
                        _ = SCLAlertView().showError("Sorry", subTitle: "Unknown error occurs")
                    }
                })
            }
        }
    }
    
    func googleSignIn(){
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    // Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        googleSignIn()
        initView()
        initUI()
        initNoti()
        print(loginBtn.backgroundColor)
        let standard = UserDefaults.standard
        if let username = standard.string(forKey: "username"){
            emailField.text = username
            if let password = standard.string(forKey: "password"){
                passwordField.text = password
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let user = FIRAuth.auth()?.currentUser{
            show(drawer, sender: self)
            currUser = UserModel.getUser(uid: user.uid, getWall: true, getProfile: true)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error{
            _ = SCLAlertView().showError("Sorry", subTitle: error.localizedDescription)
        }
        else{
            let auth = user.authentication
            let cred = FIRGoogleAuthProvider.credential(withIDToken: auth!.idToken, accessToken: auth!.accessToken)
            FIRAuth.auth()?.signIn(with: cred, completion: { (user, error) in
                if let error = error{
                    _ = SCLAlertView().showError("Sorry", subTitle: error.localizedDescription)
                }
                else{
                    print("Login successfully")
                }
            })
        }
    }

}
