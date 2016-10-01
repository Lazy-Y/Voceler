//
//  CollectionVC.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/26/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit

class CollectionVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // UIVars
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var table: UITableView!
    
    // FieldVars
    var inProgArr = ["Foo", "Bar"]
    var collectionArr = ["Hello world", "FIFA", "Real Madrid", "Cristiano Ronaldo won Euro Champion!"]
    var qInProgressArr = Array<QuestionModel>()
    var qCollectionArr = Array<QuestionModel>()
    
    // Actions
    func detailAction(indexPath:IndexPath){
        
    }
    // Functions
    func loadCollections(){
        currUser?.loadCollectionDetail()
        _ = NotificationCenter.default.addObserver(forName: NSNotification.Name("qInProgressLoaded"), object: nil, queue: nil, using:{ (noti) in
            if let dict = noti.object as? Dictionary<String, Any>{
                let qid = dict["qid"] as! String
                if currUser!.qInProgress.contains(qid){
                    let question = questionManager.getQuestion(qid: qid, question: dict)!
                    self.qInProgressArr.append(question)
//                    let indexPath = IndexPath(row: self.qInProgressArr.count-1, section: 0)
//                    self.table.reloadRows(at: [indexPath], with: .automatic)
                    self.table.reloadData()
                }
            }
        })
        _ = NotificationCenter.default.addObserver(forName: NSNotification.Name("qCollectionLoaded"), object: nil, queue: nil, using: { (noti) in
            if let dict = noti.object as? Dictionary<String, Any>{
                let qid = dict["qid"] as! String
                if currUser!.qCollection.contains(qid){
                    let question = questionManager.getQuestion(qid: qid, question: dict)!
                    self.qCollectionArr.append(question)
//                    let indexPath = IndexPath(row: self.qCollectionArr.count-1, section: 1)
//                    self.table.reloadRows(at: [indexPath], with: .automatic)
                    self.table.reloadData()
                }
            }
        })
    }
    
    // Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupProfile()
        navigationBar.setColor(color: themeColor)
        table.delegate = self
        table.dataSource = self
        table.register(UINib(nibName: "CollectionCell", bundle: nil), forCellReuseIdentifier: "CollectionCell")
        loadCollections()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return qInProgressArr.count
        }
        else{
            return qCollectionArr.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "In progress"
        }
        else {
            return "Collection"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionCell") as! CollectionCell
        cell.textLabel?.text = indexPath.section == 0 ? qInProgressArr[indexPath.row].qDescrption : qCollectionArr[indexPath.row].qDescrption
        if indexPath.section == 0{
            cell.starBtn.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table.cellForRow(at: indexPath)?.isSelected = false
        let vc = VC(name: "CollectionQuestion") as! QuestionVC
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        print("Hello")
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            if indexPath.section == 0{
                self.inProgArr.remove(at: indexPath.row)
            }
            else {
                self.collectionArr.remove(at: indexPath.row)
            }
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
        return [deleteAction]
    }
    
    override func hasCustomNavigationBar() -> Bool {
        return true
    }
}
