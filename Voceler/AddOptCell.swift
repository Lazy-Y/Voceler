//
//  AddOptCell.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 7/7/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import GrowingTextViewHandler

class AddOptCell: UITableViewCell {

    @IBOutlet weak var textView: UITextView!
    var index:Int!
    var parent:AskProblemVC!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    var handler:GrowingTextViewHandler!
    
//    func tapped(){
//        parentTB.delegate?.tableView!(parentTB, didSelectRowAt: parentTB.indexPath(for: self)!)
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
//        textView.addGestureRecognizer(tap)
        textView.font = UIFont(name: "Helvetica Neue", size: 16)
        handler = GrowingTextViewHandler(textView: textView, withHeightConstraint: textViewHeight)
        let notiCenter = NotificationCenter.default
        notiCenter.addObserver(self, selector: #selector(textChange(noti:)), name: Notification.Name.UITextViewTextDidChange, object: textView)
    }
    
    func textChange(noti:Notification) {
        handler.setText(textView.text, withAnimation: true)
        parent.optArr[index] = textView.text
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
