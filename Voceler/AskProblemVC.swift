//
//  AskProblemVC.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/30/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import GrowingTextViewHandler
import BFPaperButton

class AskProblemVC: UIViewController, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate{
    // UIVars
    @IBOutlet weak var heightTV: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var scroll: UIScrollView!
    var addBtn:BFPaperButton!
    var table:UITableView!
    
    // FieldVars
    var optArr = [String]()
    var handler:GrowingTextViewHandler!
    var text:String?
    var parentVC:AskProblemVC?
    var indexPath:IndexPath?
    var isOption = false
    
    // Actions
    func textChange(noti:Notification) {
        handler.resizeTextView(withAnimation: true)
    }
    
    func cancelAction() {
        dismiss(animated: true, completion: nil)
    }
    
    func addAction(){
        let board = UIStoryboard(name: "Main", bundle: nil)
        let vc = board.instantiateViewController(withIdentifier: "Ask Question") as! AskProblemVC
        let nav = UINavigationController(rootViewController: vc)
        vc.navigationItem.title = "Option"
        nav.navigationBar.setColor(color: themeColor)
        vc.parentVC = self
        vc.isOption = true
        show(nav, sender: self)
    }
    
    func editAction(indexPath:IndexPath){
        let board = UIStoryboard(name: "Main", bundle: nil)
        let vc = board.instantiateViewController(withIdentifier: "Ask Question") as! AskProblemVC
        let nav = UINavigationController(rootViewController: vc)
        vc.navigationItem.title = "Option"
        nav.navigationBar.setColor(color: themeColor)
        vc.text = optArr[indexPath.row]
        vc.parentVC = self
        vc.indexPath = indexPath
        show(nav, sender: self)
    }
    
    func textReset(indexPath:IndexPath, text:String){
        optArr[indexPath.row] = text
        table.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func addOpt() {
        parentVC!.optArr.append(textView.text)
        parentVC!.table.insertRows(at: [IndexPath(item: parentVC!.optArr.count-1, section: 0)], with: .automatic)
        dismiss(animated: true, completion: nil)
    }
    
    func nextAction(){
        let vc = VC(name: "Tags", isNav: false, isCenter: false)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // Functions
    func setupUI() {
        let notiCenter = NotificationCenter.default
        notiCenter.addObserver(self, selector: #selector(textChange(noti:)), name: Notification.Name.UITextViewTextDidChange, object: textView)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(addOpt))
        edgesForExtendedLayout = []
        textView.text = ""
        textView.becomeFirstResponder()
        handler = GrowingTextViewHandler(textView: textView, withHeightConstraint: heightTV)
        handler.updateMinimumNumber(ofLines: 1, andMaximumNumberOfLine: 10)
        scroll.delegate = self
        
        if !isOption {
            let rightBtn = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextAction))
            navigationItem.rightBarButtonItem = rightBtn
            
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
            addBtn.tintColor = UIColor.white
            addBtn.addTarget(self, action: #selector(addAction), for: .touchUpInside)
            
            // Setup Table
            table = UITableView()
            view.addSubview(table)
            _ = table.sd_layout()
                .topSpaceToView(textView, 10)!
                .leftSpaceToView(view, 0)!
                .rightSpaceToView(view, 0)!
                .bottomSpaceToView(addBtn, 0)!
            table.backgroundColor = lightGray
            table.delegate = self
            table.dataSource = self
            table.register(UINib(nibName: "AddOptCell", bundle: nil), forCellReuseIdentifier: "AddOptCell")
            navigationBar.setColor(color: themeColor)
            table.tableFooterView = UIView()
        }
    }
    
    // Override functions    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        textView.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let text = text {
            handler.setText(text, withAnimation: true)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return optArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddOptCell") as! AddOptCell
        cell.textLbl.text = optArr[indexPath.row]
        cell.parentTB = table
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
        editAction(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            self.optArr.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            tableView.setEditing(false, animated: true)
            self.editAction(indexPath: indexPath)
        }
        return [deleteAction, editAction]
    }
}
