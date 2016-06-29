//
//  OptCell.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/27/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import FoldingCell

class OptCell: FoldingCell {
    
    @IBOutlet weak var likeBtn: UIImageView!
    @IBOutlet weak var numOfLike: UILabel!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var contentTF: UITextView!
    @IBOutlet weak var contentCV: UIView!
    @IBOutlet weak var userTBV: UITableView!
    
    var tableView: UITableView!
    var indexPath: IndexPath!
    
    func setUp(tbv:UITableView, row:IndexPath, color:UIColor, foreViewText:String, num:Int, contentViewText:String) {
        tableView = tbv
        indexPath = row
        setColor(color: color.cgColor)
        textField.text = foreViewText
        numOfLike.text = String(num)
        
        containerView.board(radius: 16, width: 1.5, color: UIColor(cgColor: containerView.layer.borderColor!))
        foregroundView.board(radius: 16, width: 1.5, color: UIColor(cgColor: foregroundView.layer.borderColor!))
        likeBtn.image = #imageLiteral(resourceName: "like").withRenderingMode(.alwaysTemplate)
        likeBtn.tintColor = pinkColor//UIColor.red()
        controlView.backgroundColor = themeColor
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeAction))
        controlView.addGestureRecognizer(tap)
        let textTap = UITapGestureRecognizer(target: self, action: #selector(textTapped))
        textField.addGestureRecognizer(textTap)
        contentTF.text = contentViewText
        contentCV.backgroundColor = UIColor.darkGray()
        let contentTap = UITapGestureRecognizer(target: self, action: #selector(textTapped))
        contentTF.addGestureRecognizer(contentTap)
        userTBV.backgroundColor = themeColor
        contentTF.font = UIFont(name: "Helvetica Neue", size: 18)
        textField.font = UIFont(name: "Helvetica Neue", size: 18)
    }

    func likeAction(){
        likeBtn.image = #imageLiteral(resourceName: "like_filled").withRenderingMode(.alwaysTemplate)
    }
    
    func textTapped() {
        tableView.delegate!.tableView!(tableView, didSelectRowAt: indexPath)
    }
    
    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {
        return (itemIndex < 1) ? 0.33 : 0.26
    }
    
    func setColor(color:CGColor) {
        containerView.layer.borderColor = color
        foregroundView.layer.borderColor = color
    }
}
