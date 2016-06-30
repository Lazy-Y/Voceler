//
//  OptCell.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/27/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import FoldingCell

class OptCell: FoldingCell, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var likeBtn: UIImageView!
    @IBOutlet weak var numOfLike: UILabel!
    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var contentTF: UITextView!
    @IBOutlet weak var contentCV: UIView!
    @IBOutlet weak var userTBV: UITableView!
    @IBOutlet weak var moreImg: UIImageView!
    @IBOutlet weak var reportImg: UIImageView!
    
    var tableView: UITableView!
    var indexPath: IndexPath!
    
    func setUp(tbv:UITableView, row:IndexPath, color:UIColor, foreViewText:String, num:Int, contentViewText:String) {
        tableView = tbv
        indexPath = row
        textField.text = foreViewText
        numOfLike.text = String(num)
        
        containerView.board(radius: 16, width: 1.5, color: UIColor(cgColor: containerView.layer.borderColor!))
        foregroundView.board(radius: 16, width: 1.5, color: UIColor(cgColor: foregroundView.layer.borderColor!))
        likeBtn.setIcon(img: #imageLiteral(resourceName: "like"), color: pinkColor)
        controlView.backgroundColor = lightGray
        controlView.board(radius: 0, width: 1, color: .black())
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeAction))
        controlView.addGestureRecognizer(tap)
        let textTap = UITapGestureRecognizer(target: self, action: #selector(textTapped))
        textField.addGestureRecognizer(textTap)
        contentTF.text = contentViewText
        contentCV.backgroundColor = lightGray
        contentCV.board(radius: 0, width: 1, color: .black())
        let contentTap = UITapGestureRecognizer(target: self, action: #selector(textTapped))
        contentTF.addGestureRecognizer(contentTap)
        contentTF.font = UIFont(name: "Helvetica Neue", size: 18)
        textField.font = UIFont(name: "Helvetica Neue", size: 18)
        
        userTBV.register(UINib(nibName: "UserListCell", bundle: nil), forCellReuseIdentifier: "UserListCell")
        userTBV.delegate = self
        userTBV.dataSource = self
        userTBV.separatorStyle = .none
        userTBV.board(radius: 0, width: 1, color: .black())
        
        moreImg.setIcon(img: #imageLiteral(resourceName: "more-50"), color: .black())
        reportImg.setIcon(img: #imageLiteral(resourceName: "police-50"), color: .black())
    }

    func likeAction(){
        likeBtn.setIcon(img: #imageLiteral(resourceName: "like_filled"), color: pinkColor)
    }
    
    func textTapped() {
        tableView.delegate!.tableView!(tableView, didSelectRowAt: indexPath)
    }
    
    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {
        return (itemIndex < 1) ? 0.33 : 0.26
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserListCell")!
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
}
