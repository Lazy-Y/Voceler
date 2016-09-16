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
    
    @IBOutlet weak var contentView: UIView!
    
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
        optArr.append("")
        table.reloadData()
        let cell = table.cellForRow(at: IndexPath(row: optArr.count-1, section: 0)) as! AddOptCell
        cell.textView.becomeFirstResponder()
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
            
           
            
            // Setup Table
            table = UITableView()
            contentView.addSubview(table)
            _ = table.sd_layout()
                .topSpaceToView(textView, 2)!
                .leftSpaceToView(contentView, 0)!
                .rightSpaceToView(contentView, 0)!
                .bottomSpaceToView(contentView, 0)!
            _ = table.addBorder(edges: .top, colour: .black, thickness: 2)
            _ = textView.addBorder(edges: .bottom, colour: .black)
            table.backgroundColor = lightGray
            table.delegate = self
            table.dataSource = self
            table.register(UINib(nibName: "AddOptCell", bundle: nil), forCellReuseIdentifier: "AddOptCell")
            navigationBar.setColor(color: themeColor)
            table.tableFooterView = UIView()
        }
        
        textView.becomeFirstResponder()
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
        return optArr.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if indexPath.row == optArr.count{
            let cell = UITableViewCell()
            cell.textLabel?.text = "Add an Option"
            cell.textLabel?.textColor = .gray
            cell.backgroundColor = .lightGray
            cell.textLabel?.textAlignment = .center
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddOptCell") as! AddOptCell
            cell.textView.text = optArr[indexPath.row]
            cell.parent = self
            cell.index = indexPath.row
            return cell
        }
    }
    
    override func cellHeight(for indexPath: IndexPath!, cellContentViewWidth width: CGFloat, tableView: UITableView!) -> CGFloat {
        if let cell = tableView.cellForRow(at: indexPath) as? AddOptCell{
            return cell.textViewHeight.constant + 16
        }
        else {
            return tableView.cellForRow(at: indexPath)!.height
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
        if indexPath.row == optArr.count{
            addOpt()
        }
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
