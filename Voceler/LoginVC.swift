//
//  ViewController.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/21/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

// UI vars


// Code vars


// Actions


// Functions


// Override functions

import UIKit
import TextFieldEffects
import BFPaperButton

class LoginVC: UIViewController {
    
    // UI vars
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var emailField: KaedeTextField!
    @IBOutlet weak var passwordField: KaedeTextField!
    @IBOutlet weak var loginBtn: BFPaperButton!
    @IBOutlet weak var signupBtn: BFPaperButton!
    @IBOutlet weak var resetBtn: BFPaperButton!
    
    
    // Code vars
    
    
    // Actions
    
    
    // Functions
    func initUI(){
        logoImg.setup(radius: 64)
        emailField.setup(radius: 16)
        passwordField.setup(radius: 16)
        loginBtn.setup(radius: 16)
        signupBtn.setup(radius: 16)
        resetBtn.setup(radius: 16)
    }
    
    
    // Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initView()
        initUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension UIViewController{
    func initView(){
        touchToHideKeyboard()
        edgesForExtendedLayout = []
    }
    
    func touchToHideKeyboard(){
        let tab = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tab.isEnabled = true
        view.addGestureRecognizer(tab)
    }
    
    func hideKeyboard(){
        view.endEditing(true)
    }
}

extension UIImageView{
    func setup(radius:CGFloat){
        layer.masksToBounds = true
        layer.cornerRadius = radius
    }
}

extension UITextField{
    func setup(radius:CGFloat){
        layer.cornerRadius = radius
    }
}

extension BFPaperButton{
    func setup(radius:CGFloat){
        isRaised = false
        cornerRadius = radius
    }
}
