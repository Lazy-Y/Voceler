//
//  QuestionVC.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/26/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import GrowingTextViewHandler
import FoldingCell

class QuestionVC: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    // UIVars
    var handler:GrowingTextViewHandler!
    var cellHeights = [CGFloat]()
    let kCloseCellHeight: CGFloat = 75 // equal or greater foregroundView height
    let kOpenCellHeight: CGFloat = 300 // equal or greater containerView height
    
    // FieldVars
    @IBOutlet weak var detailTV: UITextView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var askerProfile: UIButton!
    @IBOutlet weak var askerLbl: UILabel!
    @IBOutlet weak var optTbv: UITableView!
    
    // Actions
    @IBAction func showAskVC(_ sender: AnyObject) {
        
    }
    
    // Functions
    func setupUI() {
        setupProfile()
        edgesForExtendedLayout = []
        detailTV.delegate = self
        handler = GrowingTextViewHandler(textView: self.detailTV, withHeightConstraint: self.heightConstraint)
        handler.updateMinimumNumber(ofLines: 1, andMaximumNumberOfLine: 8)
        detailTV.isSelectable = false
        askerProfile.layer.cornerRadius = 20
        askerProfile.layer.masksToBounds = true
        initTable()
    }
    
    func initTable() {
        optTbv.register(UINib(nibName: "OptCell", bundle: nil), forCellReuseIdentifier: "OptCell") 
        optTbv.delegate = self
        optTbv.dataSource = self
        for _ in 0...9 {
            cellHeights.append(kCloseCellHeight)
        }
        optTbv.separatorStyle = .none
    }
    
    // Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidChange(_ textView: UITextView) {
        handler.resizeTextView(withAnimation: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        handler.resizeTextView(withAnimation: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptCell") as! OptCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FoldingCell
        
        var duration = 0.0
        if cellHeights[indexPath.row] == kCloseCellHeight { // open cell
            cellHeights[indexPath.row] = kOpenCellHeight
            cell.selectedAnimation(true, animated: true, completion: nil)
            duration = 0.5
        } else {// close cell
            cellHeights[indexPath.row] = kCloseCellHeight
            cell.selectedAnimation(false, animated: true, completion: nil)
            duration = 1.1
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
            }, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if cell is FoldingCell {
            let foldingCell = cell as! FoldingCell
            
            if cellHeights[indexPath.row] == kCloseCellHeight {
                foldingCell.selectedAnimation(false, animated: false, completion:nil)
            } else {
                foldingCell.selectedAnimation(true, animated: false, completion: nil)
            }
        }
    }
}
