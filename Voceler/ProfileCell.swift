//
//  ProfileCell.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 7/12/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import TextFieldEffects

class ProfileCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var textField: AkiraTextField!
    @IBOutlet weak var editImg: UIImageView!
    @IBOutlet weak var rightConst: NSLayoutConstraint!
    var textValue:NSMutableString!{
        didSet{
            textField.text = textValue as String
        }
    }
    
    var parent:ProfileVC!
    
    func tapped() {
        parent.cellTapped(textField: textField)
    }
    
    func setEdit(editMode:Bool) {
        editImg.isHidden = !editMode
        if textField.placeholder != parent.attributeArr[2] && textField.placeholder != parent.attributeArr[3]{
            textField.isEnabled = editMode
        }
        if editMode{
            rightConst.constant = 30
        }
        else {
            rightConst.constant = 8
        }
    }
    
    func setVC(vc:ProfileVC){
        parent = vc
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textValue.replaceCharacters(in: NSMakeRange(0, textValue.length), with: textField.text!)
        print(textValue)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textField.borderStyle = .none
        textField.delegate = self
        editImg.setIcon(img: #imageLiteral(resourceName: "edit_row-50"), color: .gray())
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        contentView.addGestureRecognizer(tap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}