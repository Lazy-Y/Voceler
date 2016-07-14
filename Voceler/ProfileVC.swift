//
//  ProfileVC.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/27/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import DBProfileViewController
import SDAutoLayout
import TextFieldEffects
import BFPaperButton

class ProfileVC: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    // UIVars
    @IBOutlet weak var wallImg: UIImageView!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var controlView: UIView?
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var moneyImg: UIImageView!
    @IBOutlet weak var scrollHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomSpace: NSLayoutConstraint?
    var editBtn = BFPaperButton(raised: false)!
    
    // FieldVars
    let attributeArr = ["Email", "What's up", "Sex", "Birthday", "Region"]
    let contentArr = ["392609144@qq.com", "I'll regrade your ass ignment!", "Male", "10-06-1995", "Los Angeles"]
    var editable = true
    
    // Actions
    override func backAction() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    private var editMode = false
    func editAction() {
        editMode = !editMode
        if editMode{
            usernameTF.layer.borderWidth = 1
        }
        else {
            usernameTF.layer.borderWidth = 0
        }
        table.allowsSelection = editMode
        usernameTF.isEnabled = editMode
        table.reloadData()
    }
    
    func cellTapped(textField:UITextField){
        if editMode{
            switch textField.placeholder! {
            case "Sex":
                if textField.text == "Male"{
                    textField.text = "Female"
                }
                else {
                    textField.text = "Male"
                }
            case "Birthday":
                let vc = VC(name: "Birthday", isNav: false, isCenter: false) as! Birthday
                vc.textField = textField
                navigationController?.navigationBar.lt_setBackgroundColor(themeColor)
                navigationController?.pushViewController(vc, animated: true)
            default:
                textField.becomeFirstResponder()
            }
        }
    }
    
    // Functions
    func setEditable(){
        controlView?.isHidden = !editable
        if editable{
            bottomSpace?.constant = 50
        }
        else{
            bottomSpace?.constant = 0
        }
    }
    
    func setupUI(){
        edgesForExtendedLayout = .top
        title = ""
        usernameTF.placeholder = "Username"
        usernameTF.layer.borderColor = UIColor.gray().cgColor
        contentView.touchToHideKeyboard()
        scroll.delegate = self
        view.backgroundColor = lightGray
        controlView!.backgroundColor = themeColor
        profileImg.board(radius: 50, width: 3, color: .white())
        _ = profileImg.sd_layout().topSpaceToView(wallImg, -70)?.heightIs(100)?.widthIs(100)
        table.delegate = self
        table.dataSource = self
        table.register(UINib(nibName: "ProfileCell", bundle: nil), forCellReuseIdentifier: "ProfileCell")
        table.allowsSelection = false
        moneyImg.setIcon(img: #imageLiteral(resourceName: "money"), color: pinkColor)
        editBtn.backgroundColor = themeColor
        editBtn.tintColor = .white()
        editBtn.setImage(#imageLiteral(resourceName: "edit_row-32").withRenderingMode(.alwaysTemplate), for: [])
        controlView!.addSubview(editBtn)
        editBtn.addTarget(self, action: #selector(editAction), for: [.touchUpInside])
        _ = editBtn.sd_layout()
            .topSpaceToView(controlView, 0)?
            .bottomSpaceToView(controlView, 0)?
            .leftSpaceToView(controlView, 0)?
            .rightSpaceToView(controlView, 0)
        navigationController?.navigationBar.tintColor = .white()
        resizeTableView()
    }
    
    func resizeTableView() {
        table.reloadData()
        scrollHeight!.constant = UIScreen.main().bounds.width * 0.4 + 110 + table.contentSize.height
    }
    
    // Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfile()
        setupUI()
        setEditable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell") as! ProfileCell
        cell.setVC(vc: self)
        cell.textField.placeholder = attributeArr[indexPath.row]
        cell.textField.text = contentArr[indexPath.row]
        cell.setEdit(editMode: editMode)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if editable{
//            navigationController?.transparentBar()
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        }
        else{
            navigationController?.navigationBar.lt_reset()
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !editable{
            navigationController?.navigationBar.lt_reset()
        }
    }
}
