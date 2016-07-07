//
//  OptionsVC.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 7/7/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import BFPaperButton
import SDAutoLayout

class OptionsVC: UIViewController {
    // UIVars
    var addBtn:BFPaperButton!
    var table:UITableView!
    
    // FieldVars
    
    // Actions
    
    // Functions
    func setupUI() {
        // Setup Nav
        edgesForExtendedLayout = []
        let leftBtn = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(backAction))
        navigationController?.navigationBar.tintColor = UIColor.white()
        navigationItem.leftBarButtonItem = leftBtn
        navigationItem.title = "Options"
        
        // Setup add button
        addBtn = BFPaperButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100), raised: false)!
        view.addSubview(addBtn)
        _ = addBtn.sd_layout()
            .bottomSpaceToView(view, 0)!
            .leftSpaceToView(view, 0)!
            .rightSpaceToView(view, 0)!
            .heightIs(50)
        addBtn.setTitle("Add Option", for: [])
        addBtn.backgroundColor = themeColor
        addBtn.tintColor = UIColor.white()
        addBtn.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        
        // Setup Table
        table = UITableView()
        view.addSubview(table)
        _ = table.sd_layout()
            .topSpaceToView(view, 0)!
            .leftSpaceToView(view, 0)!
            .rightSpaceToView(view, 0)!
            .bottomSpaceToView(addBtn, 0)!
        table.backgroundColor = lightGray
    }
    
    func addAction(){
        print("Hello world")
    }
    
    func backAction() {
        navigationController!.popViewController(animated: true)
    }
    
    // Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
    }
}
