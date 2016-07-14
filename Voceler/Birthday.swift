//
//  Birthday.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 7/13/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import SDAutoLayout
import LTNavigationBar

class Birthday: UIViewController {

    var birthPicker = UIDatePicker()
    var textField:UITextField!
    let formatter = DateFormatter()
    
    override func backAction() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func confirmAction() {
        textField.text = formatter.string(from: birthPicker.date)
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        birthPicker.datePickerMode = .date
        title = "Birthday"
        formatter.dateFormat = "MM-dd-yyyy"
        view.addSubview(birthPicker)
        _ = birthPicker.sd_layout()?
            .topSpaceToView(view, 0)?
            .leftSpaceToView(view, 0)?
            .rightSpaceToView(view, 0)?
            .heightIs(200)
        setBackItem()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(confirmAction))
        birthPicker.maximumDate = Date()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        birthPicker.setDate(formatter.date(from: textField.text!)!, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.lt_reset()
    }
}
