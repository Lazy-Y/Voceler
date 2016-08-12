//
//  Birthday.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 7/13/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import SDAutoLayout

class Birthday: UIViewController {

    var birthPicker = UIDatePicker()
    var textField:UITextField!
    let formatter = DateFormatter()
    
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
        birthPicker.setDate(formatter.date(from: textField.text!)!, animated: true)
        view.addSubview(birthPicker)
        _ = birthPicker.sd_layout()?
            .topSpaceToView(view, 64)?
            .leftSpaceToView(view, 0)?
            .rightSpaceToView(view, 0)?
            .heightIs(200)
        setBackItem()
        navigationBar.setColor(color: themeColor)
        birthPicker.maximumDate = Date()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(confirmAction))
    }
    
    override func hasCustomNavigationBar() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
