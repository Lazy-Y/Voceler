//
//  TagsController.swift
//  BlazingVote
//
//  Created by Zhenyang Zhong on 6/5/16.
//  Copyright © 2016 ZhenyangZhong. All rights reserved.
//

import UIKit
import TagListView
import RATreeView
import SDAutoLayout

class TagsController: UIViewController, TagListViewDelegate, UITextFieldDelegate, RATreeViewDelegate, RATreeViewDataSource {
    var optTBV = UITableView()
    
    @IBOutlet weak var tagView: TagListView!
    
    @IBAction func doneAction(sender: AnyObject) {
        let first = navigationController?.viewControllers[0] as! AskProblemVC
        first.handler.setText("", withAnimation: false)
        first.optArr.removeAll()
        first.table.reloadData()
        tagView.removeAllTags()
        textField.text = ""
        optTBV.isHidden = true
        treeView.isHidden = false
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
                treeView.isHidden = false
                tagView.isHidden = false
            }
        }
    }
    
    @IBOutlet weak var addBtn: UIButton!
    let treeView = RATreeView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        view.backgroundColor = lightGray
        
        // Do any additional setup after loading the view.
        tagView.textFont = UIFont.systemFont(ofSize: 16)
        tagView.alignment = .left
        tagView.delegate = self
        tagView.enableRemoveButton = true
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        
        view.addSubview(optTBV)
        _ = optTBV.sd_layout()
            .topSpaceToView(textField, 8)!
            .bottomSpaceToView(view, 0)!
            .leftSpaceToView(view, 0)!
            .rightSpaceToView(view, 0)!
        optTBV.backgroundColor = lightGray
        optTBV.isHidden = true
        
        addBtn.imageView?.setIcon(img: #imageLiteral(resourceName: "plus-50").withRenderingMode(.alwaysTemplate), color: themeColor)
        
        let noti = NotificationCenter.default()
        noti.addObserver(self, selector: #selector(textChange(noti:)), name: Notification.Name.UITextFieldTextDidChange, object: textField)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEdit))
        tagView.addGestureRecognizer(tap)
        
        treeView.delegate = self
        treeView.dataSource = self
        treeView.backgroundColor = .white()
        view.addSubview(treeView)
        _ = treeView.sd_layout().topSpaceToView(tagView, 20)?.bottomSpaceToView(view, 0)?.leftSpaceToView(view, 0)?.rightSpaceToView(view, 0)
    }
    
    let categories = NSDictionary(contentsOfFile: Bundle.main().pathForResource("Categories", ofType: "plist")!)!
    
    func textChange(noti:Notification) {
        if textField.text == "" {
            optTBV.isHidden = true
            tagView.isHidden = false
            treeView.isHidden = false
        }
        else {
            optTBV.isHidden = false
            tagView.isHidden = true
            treeView.isHidden = true
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
    
    func treeView(_ treeView: RATreeView, numberOfChildrenOfItem item: AnyObject?) -> Int{
        if let item = item as? NSArray{
            return (item[1] as! NSDictionary).count
        }
        else{
            return categories.count
        }
    }
    
    func treeView(_ treeView: RATreeView, cellForItem item: AnyObject?) -> UITableViewCell{
        let cell = TreeViewCell()
        let arr = item as! NSArray
        cell.setUp(level: treeView.levelForCell(forItem: item!), text: arr[0] as! String, numOfChild: (arr[1] as! NSDictionary).count)
        return cell
    }
    
    func treeView(_ treeView: RATreeView, child index: Int, ofItem item: AnyObject?) -> AnyObject{
        if let item = (item as? NSArray)?[1] as? NSDictionary{
            return [item.allKeys[index],item.allValues[index]]
        }
        else{
            return [categories.allKeys[index], categories.allValues[index]]
        }
    }
    
    func treeView(_ treeView: RATreeView, willExpandRowForItem item: AnyObject) {
        (treeView.cell(forItem: item) as! TreeViewCell).change(expand: true)
    }
    
    func treeView(_ treeView: RATreeView, willCollapseRowForItem item: AnyObject) {
        (treeView.cell(forItem: item) as! TreeViewCell).change(expand: false)
    }
    
    func treeView(_ treeView: RATreeView, didSelectRowForItem item: AnyObject) {
        treeView.cell(forItem: item)?.isSelected = false
    }
}
