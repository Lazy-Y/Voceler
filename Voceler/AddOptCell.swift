//
//  AddOptCell.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 7/7/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit

class AddOptCell: UITableViewCell {

    @IBOutlet weak var textLbl: UILabel!
    var parentTB:UITableView!
    
    func tapped(){
        parentTB.delegate?.tableView!(parentTB, didSelectRowAt: parentTB.indexPath(for: self)!)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        textLbl.addGestureRecognizer(tap)
        textLbl.font = UIFont(name: "Helvetica Neue", size: 16)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
