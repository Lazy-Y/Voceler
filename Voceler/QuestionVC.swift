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
import SFFocusViewLayout
import LTNavigationBar

class QuestionVC: UIViewController{
    
    // FieldVars
    let repository = Repository()
    let renderer = Renderer()

    var handler:GrowingTextViewHandler!
    
    var liked = false
    var cellContent = ["Swift", "Python", "C++", "Java", "PHP", "JavaScript", "Nodejs", "HTML", "Bash", "Assembly"]
    var asker:UserModel?{
        didSet{
            if let asker = asker{
                if let img = asker.profileImg {
                    askerProfile.setImage(img, for: [])
                    askerProfile.imageView?.contentMode = .scaleAspectFill
                }
                else{
                    asker.loadProfileImg(name: "finishAskerProfile")
                    NotificationCenter.default.addObserver(self, selector: #selector(setAskerImg), name: NSNotification.Name("finishAskerProfile"), object: nil)
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
    //    @IBOutlet weak var optTbv: UITableView!
    var collectionView:UICollectionView!
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
        handler.setText(question.qDescrption, withAnimation: true)
        cellContent = question.qOptions
        if cellContent.count == 0 {
            pullUpMask.isHidden = false
            pullDownMask.isHidden = false
        }
        else {
            pullUpMask.isHidden = true
            pullDownMask.isHidden = true
        }
        collectionView.reloadData()
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
        askerProfile.contentMode = .scaleAspectFill
        asker = currUser
        
        setupProfile()
        _ = titleBarView.addBorder(edges: .bottom, colour: UIColor.gray, thickness: 1.5)
        handler = GrowingTextViewHandler(textView: self.detailTV, withHeightConstraint: self.heightConstraint)
        handler.updateMinimumNumber(ofLines: 1, andMaximumNumberOfLine: 5)
        detailTV.isEditable = false
        askerProfile.board(radius: 20, width: 3, color: UIColor.white)
        likeBtn?.setImage(#imageLiteral(resourceName: "star").withRenderingMode(.alwaysTemplate), for: [])
        likeBtn?.tintColor = darkRed
        initTable()
        navigationBar.setColor(color: themeColor)
        edgesForExtendedLayout = []
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ask").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(showAskVC(_:)))
        
        pullUpMask.text = "Pull up to add an option"
        pullUpMask.textAlignment = .center
        pullUpMask.isHidden = true
        pullUpMask.textColor = .gray
        collectionView.addSubview(pullUpMask)
        _ = pullUpMask.sd_layout().topSpaceToView(detailTV, 10)?.leftSpaceToView(collectionView, 0)?.rightSpaceToView(collectionView, 0)?.heightIs(30)
        pullDownMask.text = "Pull down to skip"
        pullDownMask.textAlignment = .center
        pullDownMask.isHidden = true
        pullDownMask.textColor = .gray
        collectionView.addSubview(pullDownMask)
        _ = pullDownMask.sd_layout().topSpaceToView(pullUpMask, 10)?.leftSpaceToView(collectionView, 0)?.rightSpaceToView(collectionView, 0)?.heightIs(30)
    }
    
    func addOption(text:String){
        cellContent.append(text)
        collectionView.reloadData()
        pullDownMask.isHidden = true
        pullUpMask.isHidden = true
    }
    
    func initTable() {
        // Do any additional setup after loading the view.
        let layout = SFFocusViewLayout()
        layout.standardHeight = 50
        layout.focusedHeight = 200
        layout.dragOffset = 100
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 100, height: 110), collectionViewLayout: layout)
        view.addSubview(collectionView)
        _ = collectionView.sd_layout()
            .topSpaceToView(detailTV, 0)?
            .bottomSpaceToView(view, 0)?
            .leftSpaceToView(view, 0)?
            .rightSpaceToView(view, 0)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(CollectionViewCell.self)
        
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        collectionView.backgroundColor = .white
        
        if navigationController?.childViewControllers.first == self{
            let header = MJRefreshNormalHeader(refreshingBlock: {
                print("refresh")
                let q = QuestionModel.getQuestion(qid: "abcdefg")
                q.qAnonymous = true
                self.setQuestion(question: q)
                self.collectionView.mj_header.endRefreshing()
            })!
            header.lastUpdatedTimeLabel.isHidden = true
            header.setTitle("Next question", for: .pulling)
            header.setTitle("Pull down to skip", for: .idle)
            collectionView.mj_header = header
            
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
                self.collectionView.mj_footer.endRefreshing()
            })!
            footer.setTitle("Pull to add an option", for: .idle)
            footer.setTitle("Add an option", for: .pulling)
            collectionView.mj_footer = footer
        }
    }
    
    func setDescription(description:String) {
        detailTV.isSelectable = true
        handler.setText(description, withAnimation: true)
        detailTV.isSelectable = false
    }
    
    private var isCollection:Bool?
    private var isLiked:Bool?
    func collectionSetup(collection:Bool){
        isCollection = collection
        collectionSetup()
    }
    
    func collectionSetup(){
        if let isCollection = isCollection, let likeBtn = likeBtn , isCollection{
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
        ()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func hasCustomNavigationBar() -> Bool {
        return true
    }
}



extension QuestionVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(collectionView)
        return repository.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as CollectionViewCell
        renderer.presentModel(model: repository[indexPath.item], inView: cell)
        return cell
    }
    
    @objc(collectionView:willDisplayCell:forItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        
        guard let cell = cell as? CollectionViewCellRender else {
            fatalError("error with registred cell")
        }
        
        renderer.presentModel(model: repository[indexPath.item], inView: cell)
    }
}

extension QuestionVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let focusViewLayout = collectionView.collectionViewLayout as? SFFocusViewLayout else {
            fatalError("error casting focus layout from collection view")
        }
        
        let offset = focusViewLayout.dragOffset * CGFloat(indexPath.item)
        if collectionView.contentOffset.y != offset {
            collectionView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
        }
        
    }
    
}
