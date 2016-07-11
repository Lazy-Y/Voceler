//
//  CollectionCell.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 7/10/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import SDAutoLayout

class CollectionCell: UITableViewCell {
    @IBOutlet weak var starBtn: UIButton!

    @IBAction func starAction(_ sender: AnyObject) {
        isStared = !isStared
        setBtn()
    }
    
    func setBtn() {
        if isStared{
            starBtn.setImage(#imageLiteral(resourceName: "star_filled").withRenderingMode(.alwaysTemplate), for: [])
        }
        else {
            starBtn.setImage(#imageLiteral(resourceName: "star").withRenderingMode(.alwaysTemplate), for: [])
        }
    }
    
    var isStared = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        _ = textLabel?.sd_layout().rightSpaceToView(contentView, 35)
        starBtn.tintColor = pinkColor
        setBtn()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
