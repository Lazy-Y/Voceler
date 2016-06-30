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

class QuestionVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // FieldVars
    var handler:GrowingTextViewHandler!
    var cellHeights = [CGFloat]()
    let kCloseCellHeight: CGFloat = 70 // equal or greater foregroundView height
    let kOpenCellHeight: CGFloat = 310 // equal or greater containerView height
    var liked = false
    let cellContent = ["Swift", "Python", "C++", "Java", "PHP", "JavaScript", "Nodejs", "HTML", "Bash", "Assembly"]
    
    // UIVars
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var detailTV: UITextView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var askerProfile: UIButton!
    @IBOutlet weak var askerLbl: UILabel!
    @IBOutlet weak var optTbv: UITableView!
    @IBOutlet weak var scrollHeight: NSLayoutConstraint!
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // Actions
    @IBAction func showAskVC(_ sender: AnyObject) {
        
    }
    
    @IBAction func likeAction(_ sender: AnyObject) {
        liked = !liked
        if liked {
            likeBtn.setImage(#imageLiteral(resourceName: "star").withRenderingMode(.alwaysTemplate), for: [])
        }
        else{
            likeBtn.setImage(#imageLiteral(resourceName: "star_filled").withRenderingMode(.alwaysTemplate), for: [])
        }
    }
    
    // Functions
    func setupUI() {
        setupProfile()
        edgesForExtendedLayout = []
//        detailTV.board(radius: 16, width: 3, color: themeColor)
        handler = GrowingTextViewHandler(textView: self.detailTV, withHeightConstraint: self.heightConstraint)
        handler.updateMinimumNumber(ofLines: 1, andMaximumNumberOfLine: 5)
        detailTV.isEditable = false
        askerProfile.board(radius: 20, width: 3, color: UIColor.white())
        let img = UIImage(named: "star")?.withRenderingMode(.alwaysTemplate)
        likeBtn.setImage(img, for: [])
        likeBtn.tintColor = darkRed
        scrollView.showsVerticalScrollIndicator = false
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
        optTbv.showsVerticalScrollIndicator = false
        optTbv.isScrollEnabled = false
    }
    
    func setDescription(description:String) {
        detailTV.isSelectable = true
        handler.setText(description, withAnimation: true)
        detailTV.isSelectable = false
        resizeScrollView()
    }
    
    func resizeScrollView() {
        let height = heightConstraint.constant + 16 + optTbv.contentSize.height
        scrollHeight.constant = height
        contentViewHeight.constant = height
        scrollView.contentSize.height = height
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
    
    override func viewDidAppear(_ animated: Bool) {
        setDescription(description: "Which language is the best in the world?")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptCell") as! OptCell
        cell.setUp(tbv: optTbv, row: indexPath, color: UIColor.darkGray(), foreViewText: cellContent[indexPath.row], num: 200 - indexPath.row * 10, contentViewText: "As Sergey and I wrote in the original founders letter 11 years ago, “Google is not a conventional company. We do not intend to become one.”")
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
        } else {
            cellHeights[indexPath.row] = kCloseCellHeight
            cell.selectedAnimation(false, animated: true, completion: nil)
            duration = 1.1
        }
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            tableView.beginUpdates()
            tableView.endUpdates()
            }, completion: nil)
        Timer.scheduledTimer(timeInterval: duration + 0.01, target: self, selector: #selector(resizeScrollView), userInfo: nil, repeats: false)
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
