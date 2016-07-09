//
//  TagsController.swift
//  BlazingVote
//
//  Created by Zhenyang Zhong on 6/5/16.
//  Copyright © 2016 ZhenyangZhong. All rights reserved.
//

import UIKit
import TagListView

class TagsController: UIViewController, TagListViewDelegate, UITextFieldDelegate {

    var optTBV = UITableView()
    
    @IBOutlet weak var tagView: TagListView!
    
    @IBAction func back() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneAction(sender: AnyObject) {
        let first = navigationController?.viewControllers[0] as! AskProblemVC
        first.handler.setText("", withAnimation: false)
        let second = navigationController?.viewControllers[1] as! OptionsVC
        second.optArr.removeAll()
        second.table.reloadData()
        tagView.removeAllTags()
        textField.text = ""
        optTBV.isHidden = true
        tagView.isHidden = false
        navigationController?.dismiss(animated: true, completion: {
            _ = self.navigationController!.popToRootViewController(animated: false)
        })
    }
    
    @IBOutlet weak var textField: UITextField!
    @IBAction func addAction(sender: AnyObject) {
        if let text = textField.text{
            if !text.isEmpty {
                for tag in tagView.tagViews{
                    if tag.titleLabel?.text == text{
                        return
                    }
                }
                _ = tagView.addTag(text)
                textField.text = ""
                optTBV.isHidden = true
                tagView.isHidden = false
            }
        }
    }
    
    @IBOutlet weak var addBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        view.backgroundColor = lightGray
        
        // Do any additional setup after loading the view.
        tagView.textFont = UIFont.systemFont(ofSize: 16)
        tagView.alignment = .left
        tagView.delegate = self
        tagView.enableRemoveButton = true
        tagView.backgroundColor = lightGray
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        
        view.addSubview(optTBV)
        _ = optTBV.sd_layout()
            .topSpaceToView(textField, 8)!
            .bottomSpaceToView(view, 0)!
            .leftSpaceToView(view, 10)!
            .rightSpaceToView(view, 10)!
        optTBV.backgroundColor = lightGray
        optTBV.isHidden = true
        
        addBtn.imageView?.setIcon(img: #imageLiteral(resourceName: "plus-50").withRenderingMode(.alwaysTemplate), color: themeColor)
        
        let noti = NotificationCenter.default()
        noti.addObserver(self, selector: #selector(textChange(noti:)), name: Notification.Name.UITextFieldTextDidChange, object: textField)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEdit))
        tagView.addGestureRecognizer(tap)
    }
    
    func textChange(noti:Notification) {
        if textField.text == "" {
            optTBV.isHidden = true
            tagView.isHidden = false
        }
        else {
            optTBV.isHidden = false
            tagView.isHidden = true
        }
    }
    
    func endEdit(){
        textField.endEditing(true)
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) -> Void{
        self.tagView.removeTagView(tagView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
