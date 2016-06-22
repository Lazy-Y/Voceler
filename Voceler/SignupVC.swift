//
//  SignupVC.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/21/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import SDAutoLayout

class SignupVC: UIViewController {
    // UI vars
    
    
    // Code vars
    
    
    // Actions
    @IBAction func backAct(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // Functions
    func initUI(){
        // init birth lable
        let birthLbl = UILabel()
        birthLbl.text = "Birthday"
        birthLbl.font = UIFont(name: birthLbl.font!.fontName, size: 20)
        view.addSubview(birthLbl)
        _ = birthLbl.sd_layout().topSpaceToView(view, 8)?
            .leftSpaceToView(view, 20)?
            .widthIs(100)?
            .heightIs(30)
        
        // init birth picker
        let birthPicker = UIDatePicker()
        birthPicker.datePickerMode = .date
        birthPicker.maximumDate = Date()
        view.addSubview(birthPicker)
        _ = birthPicker.sd_layout()
            .topSpaceToView(birthLbl, 20)?
            .leftSpaceToView(view, 20)?
            .rightSpaceToView(view, 20)?
            .heightIs(40)
    }
    
    
    // Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initView()
        initUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
