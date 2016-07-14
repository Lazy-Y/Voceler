//
//  ProfileCell.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 7/12/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import TextFieldEffects

class ProfileCell: UITableViewCell {
    
    @IBOutlet weak var textField: AkiraTextField!
    @IBOutlet weak var editImg: UIImageView!
    @IBOutlet weak var rightConst: NSLayoutConstraint!
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textField.borderStyle = .none
        editImg.setIcon(img: #imageLiteral(resourceName: "edit_row-50"), color: .gray())
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        contentView.addGestureRecognizer(tap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
