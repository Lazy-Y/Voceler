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
import MJRefresh
import SCLAlertView

class QuestionVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // FieldVars
    var handler:GrowingTextViewHandler!
    var cellHeights = [CGFloat]()
    let kCloseCellHeight: CGFloat = 55 // equal or greater foregroundView height
    let kOpenCellHeight: CGFloat = 305 // equal or greater containerView height
    var liked = false
    var cellContent = ["Swift", "Python", "C++", "Java", "PHP", "JavaScript", "Nodejs", "HTML", "Bash", "Assembly"]
    var asker:UserModel?{
        didSet{
            if let asker = asker{
                if let img = asker.profileImg {
                    askerProfile.setImage(img, for: [])
                }
                else{
                    asker.loadProfileImg(name: "finishAskerProfile")
                    NotificationCenter.default().addObserver(self, selector: #selector(setAskerImg), name: NSNotification.Name("finishAskerProfile"), object: nil)
                }
            }
        }
    }
    
    // UIVars
    @IBOutlet weak var titleBarView: UIVisualEffectView!
    @IBOutlet weak var likeBtn: UIButton?
    @IBOutlet weak var detailTV: UITextView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var askerProfile: UIButton!
    @IBOutlet weak var askerLbl: UILabel!
    @IBOutlet weak var optTbv: UITableView!
    @IBOutlet weak var scrollHeight: NSLayoutConstraint!
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    var pullUpMask = UILabel()
    var pullDownMask = UILabel()
    
    // Actions
    @IBAction func askerInfo(_ sender: AnyObject) {
        showAskerInfo()
    }
    
    @IBAction func showAskVC(_ sender: AnyObject) {
        let vc = VC(name: "Ask Question", isCenter: false) as! UINavigationController
        show(vc, sender: self)
    }
    
    @IBAction func likeAction(_ sender: AnyObject) {
        liked = !liked
        if liked {
            likeBtn?.setImage(#imageLiteral(resourceName: "star").withRenderingMode(.alwaysTemplate), for: [])
        }
        else{
            likeBtn?.setImage(#imageLiteral(resourceName: "star_filled").withRenderingMode(.alwaysTemplate), for: [])
        }
    }
    
    func concludeAction(){
        print("Conclude")
    }
    
    // Functions
    func setAskerImg(){
        if let img = asker?.profileImg{
            askerProfile.setImage(img, for: [])
        }
    }
    
    func setQuestion(question:QuestionModel){
        if question.qAnonymous {
            asker = nil
        }
        else{
            asker = UserModel.getUser(uid: question.qAskerID, getProfile: true)
        }
        detailTV.text = question.qDescrption
        cellContent = question.qOptions
        cellHeights = [CGFloat](repeatElement(kCloseCellHeight, count: cellContent.count))
        if cellContent.count == 0 {
            pullUpMask.isHidden = false
            pullDownMask.isHidden = false
        }
        else {
            pullUpMask.isHidden = true
            pullDownMask.isHidden = true
        }
        optTbv.reloadData()
    }
    
    func showAskerInfo(){
        if let asker = asker{
            let vc = VC(name: "Profile", isNav: false, isCenter: false, isNew: true) as! ProfileVC
            vc.thisUser = asker
            navigationController?.pushViewController(vc, animated: true)
        }
        else{
            _ = SCLAlertView().showWarning("Sorry", subTitle: "Anonymous asker")
        }
    }
    
    func setupUI() {
        asker = currUser
        
        setupProfile()
        _ = titleBarView.addBorder(edges: .bottom, colour: UIColor.gray(), thickness: 1.5)
        handler = GrowingTextViewHandler(textView: self.detailTV, withHeightConstraint: self.heightConstraint)
        handler.updateMinimumNumber(ofLines: 1, andMaximumNumberOfLine: 5)
        detailTV.isEditable = false
        askerProfile.board(radius: 20, width: 3, color: UIColor.white())
        likeBtn?.setImage(#imageLiteral(resourceName: "star").withRenderingMode(.alwaysTemplate), for: [])
        likeBtn?.tintColor = darkRed
        scrollView.showsVerticalScrollIndicator = false
        initTable()
        navigationBar.setColor(color: themeColor)
        edgesForExtendedLayout = []
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ask").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(showAskVC(_:)))
        
        pullUpMask.text = "Pull up to add an option"
        pullUpMask.textAlignment = .center
        pullUpMask.isHidden = true
        pullUpMask.textColor = .gray()
        scrollView.addSubview(pullUpMask)
        _ = pullUpMask.sd_layout().topSpaceToView(detailTV, 10)?.leftSpaceToView(scrollView, 0)?.rightSpaceToView(scrollView, 0)?.heightIs(30)
        pullDownMask.text = "Pull down to skip"
        pullDownMask.textAlignment = .center
        pullDownMask.isHidden = true
        pullDownMask.textColor = .gray()
        scrollView.addSubview(pullDownMask)
        _ = pullDownMask.sd_layout().topSpaceToView(pullUpMask, 10)?.leftSpaceToView(scrollView, 0)?.rightSpaceToView(scrollView, 0)?.heightIs(30)
    }
    
    func addOption(text:String){
        cellContent.append(text)
        cellHeights.append(kCloseCellHeight)
        optTbv.reloadData()
        resizeScrollView()
        pullDownMask.isHidden = true
        pullUpMask.isHidden = true
    }
    
    func initTable() {
        optTbv.register(UINib(nibName: "OptCell", bundle: nil), forCellReuseIdentifier: "OptCell")
        optTbv.delegate = self
        optTbv.dataSource = self
        for _ in 0..<cellContent.count {
            cellHeights.append(kCloseCellHeight)
        }
        optTbv.separatorStyle = .none
        optTbv.showsVerticalScrollIndicator = false
        optTbv.isScrollEnabled = false
        
        if navigationController?.childViewControllers.first == self{
            let header = MJRefreshNormalHeader(refreshingBlock: {
                print("refresh")
                let q = QuestionModel.getQuestion(qid: "abcdefg")
                q.qAnonymous = true
                self.setQuestion(question: q)
                self.scrollView.mj_header.endRefreshing()
            })!
            header.lastUpdatedTimeLabel.isHidden = true
            header.setTitle("Next question", for: .pulling)
            header.setTitle("Pull down to skip", for: .idle)
            scrollView.mj_header = header
            
            let footer = MJRefreshBackNormalFooter(refreshingBlock: {
                let alert = SCLAlertView()
                let optionText = alert.addTextView()
                _ = alert.addButton("Add", action: {
                    if optionText.text == ""{
                        _ = SCLAlertView().showError("Sorry", subTitle: "Option text cannot be empty.")
                    }
                    else{
                        self.addOption(text: optionText.text)
                    }
                })
                _ = alert.showEdit("Another Option", subTitle: "", closeButtonTitle: "Cancel")
                self.scrollView.mj_footer.endRefreshing()
            })!
            footer.setTitle("Pull to add an option", for: .idle)
            footer.setTitle("Add an option", for: .pulling)
            scrollView.mj_footer = footer
        }
    }
    
    func setDescription(description:String) {
        detailTV.isSelectable = true
        handler.setText(description, withAnimation: true)
        detailTV.isSelectable = false
        resizeScrollView()
    }
    
    func resizeScrollView() {
        let height = heightConstraint.constant + optTbv.contentSize.height - 30
        scrollHeight.constant = height
        contentViewHeight.constant = height
        scrollView.contentSize.height = height
    }
    
    private var isCollection:Bool?
    private var isLiked:Bool?
    func collectionSetup(collection:Bool){
        isCollection = collection
        collectionSetup()
    }
    
    func collectionSetup(){
        if let isCollection = isCollection, likeBtn = likeBtn where isCollection{
            likeBtn.isHidden = false
            navigationItem.rightBarButtonItem = nil
        }
        else{
            likeBtn?.isHidden = true
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
        setDescription(description: "Which language is the best in the world?")
        resizeScrollView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return cellContent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptCell") as! OptCell
        cell.setUp(parent: self,tbv: optTbv, row: indexPath, color: UIColor.darkGray(), foreViewText: cellContent[indexPath.row], num: 200 - indexPath.row * 10, contentViewText: "As Sergey and I wrote in the original founders letter 11 years ago, “Google is not a conventional company. We do not intend to become one.”", isInCollection: isCollection != nil)
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
            duration = 0.8
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
            }
            else {
                foldingCell.selectedAnimation(true, animated: false, completion: nil)
            }
        }
    }
    
    override func hasCustomNavigationBar() -> Bool {
        return true
    }
}
