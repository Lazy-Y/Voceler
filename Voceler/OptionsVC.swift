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

class OptionsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // UIVars
    var addBtn:BFPaperButton!
    var table:UITableView!
    
    // FieldVars
    var optArr = [String]()
    
    // Actions
    func addAction(){
        let board = UIStoryboard(name: "Main", bundle: nil)
        let vc = board.instantiateViewController(withIdentifier: "Ask Question") as! AskProblemVC
        let nav = UINavigationController(rootViewController: vc)
        vc.navigationItem.title = "Option"
        nav.navigationBar.setColor(color: themeColor)
        vc.parentVC = self
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
    
    func addOpt(text:String) {
        optArr.append(text)
        table.insertRows(at: [IndexPath(item: optArr.count-1, section: 0)], with: .automatic)
    }
    
    func nextAction(){
        let vc = VC(name: "Tags", isNav: false, isCenter: false)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // Functions
    func setupUI() {
        // Setup Nav
        edgesForExtendedLayout = []
        navigationItem.title = "Options"
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
        table.delegate = self
        table.dataSource = self
        table.register(UINib(nibName: "AddOptCell", bundle: nil), forCellReuseIdentifier: "AddOptCell")
        optArr = ["The University of Southern California requires all students have comprehensive health insurance.  All students enrolled in 6 or more units are automatically enrolled into the USC Student Health Insurance plan.  Students taking courses through the Health Sciences Campus and all international students are automatically enrolled as well.  This will help cover the cost of care that cannot be obtained at the health center on campus, especially in emergency situations where hospitalization may be required.", "Please note that at any time during the semester, if the number of units you are registered in drops below 6 units, you will need to contact the health insurance office, or you may be automatically dropped from insurance coverage.", "The Engemann Student Health Center will serve as your health care center on campus. Your mandatory payment of the health center fee each semester ($295 for fall and separate from the insurance premium), covers most primary care services. We have many available resources to keep you healthy during your academic years. Our integration with both the Division of Student Affairs and the USC health care community helps support USC’s mission of providing you with high quality, cost-effective, student-focused services.", "Fusion 360 is 3D CAD reinvented. Get industrial and mechanical design, simulation, collaboration, and machining in a single package. Fusion 360 connects your entire product development process and works on both Mac and PC."]
        navigationBar.setColor(color: themeColor)
        table.tableFooterView = UIView()
    }
    
    // Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
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
