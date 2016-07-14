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
    let kCloseCellHeight: CGFloat = 55 // equal or greater foregroundView height
    let kOpenCellHeight: CGFloat = 305 // equal or greater containerView height
    var liked = false
    let cellContent = ["Swift", "Python", "C++", "Java", "PHP", "JavaScript", "Nodejs", "HTML", "Bash", "Assembly"]
    
    // UIVars
    @IBOutlet weak var titleBarView: UIVisualEffectView!
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
    
    @IBAction func askerInfo(_ sender: AnyObject) {
        let vc = VC(name: "ProfileOther", isNav: false, isCenter: false) as! ProfileVC
        vc.setBackItem()
        vc.editable = false
        vc.setEditable()
        navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func showAskVC(_ sender: AnyObject) {
        let vc = VC(name: "Ask Question", isCenter: false) as! UINavigationController
        show(vc, sender: self)
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
    
    func concludeAction(){
        print("Conclude")
    }
    
    // Functions
    func setupUI() {
        setupProfile()
        _ = titleBarView.addBorder(edges: .bottom, colour: UIColor.gray(), thickness: 1.5)
        handler = GrowingTextViewHandler(textView: self.detailTV, withHeightConstraint: self.heightConstraint)
        handler.updateMinimumNumber(ofLines: 1, andMaximumNumberOfLine: 5)
        detailTV.isEditable = false
        askerProfile.board(radius: 20, width: 3, color: UIColor.white())
        likeBtn.setImage(#imageLiteral(resourceName: "star").withRenderingMode(.alwaysTemplate), for: [])
        likeBtn.tintColor = darkRed
        scrollView.showsVerticalScrollIndicator = false
        initTable()
        navigationController?.transparentBar()
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
        let height = heightConstraint.constant + 210 + optTbv.contentSize.height
        scrollHeight.constant = height
        contentViewHeight.constant = height
        scrollView.contentSize.height = height
    }
    
    private var isCollection:Bool?
    private var isLiked:Bool?
    func collectionSetup(collection:Bool){
        isCollection = collection
    }
    
    func collectionSetup(){
        if let isCollection = isCollection where isCollection{
            likeBtn.isHidden = false
            navigationItem.rightBarButtonItem = nil
        }
        else{
            likeBtn.isHidden = true
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Conclude", style: .done, target: self, action: #selector(concludeAction))
        }
    }
    
    // Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if isCollection != nil{
            collectionSetup()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setDescription(description: "Which language is the best in the world?")
        resizeScrollView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptCell") as! OptCell
        cell.setUp(tbv: optTbv, row: indexPath, color: UIColor.darkGray(), foreViewText: cellContent[indexPath.row], num: 200 - indexPath.row * 10, contentViewText: "As Sergey and I wrote in the original founders letter 11 years ago, “Google is not a conventional company. We do not intend to become one.”", isInCollection: isCollection != nil)
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
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { 
            tableView.beginUpdates()
            tableView.endUpdates()
            }) { (success) in
                self.resizeScrollView()
        }
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
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.lt_setBackgroundColor(themeColor)
    }
}
