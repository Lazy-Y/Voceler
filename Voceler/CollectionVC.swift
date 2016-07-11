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
    
    // Actions
    func detailAction(indexPath:IndexPath){
        
    }
    // Functions
    
    // Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupProfile()
        navigationController?.navigationBar.tintColor = UIColor.white()
        table.delegate = self
        table.dataSource = self
        table.register(UINib(nibName: "CollectionCell", bundle: nil), forCellReuseIdentifier: "CollectionCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return inProgArr.count
        }
        else{
            return collectionArr.count
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
        cell.textLabel?.text = indexPath.section == 0 ? inProgArr[indexPath.row] : collectionArr[indexPath.row]
        if indexPath.section == 0{
            cell.starBtn.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        table.cellForRow(at: indexPath)?.isSelected = false
        let vc = VC(name: "CollectionQuestion") as! QuestionVC
        vc.collectionSetup(collection: indexPath.section == 1)
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
}
