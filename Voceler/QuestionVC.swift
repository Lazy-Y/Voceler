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
import SCLAlertView

class QuestionVC: UIViewController{
    
    // FieldVars
//    let repository = Repository()
//    let renderer = Renderer()
    @IBOutlet weak var titlebarHeight: NSLayoutConstraint!
    var handler:GrowingTextViewHandler!
    
    var liked = false{
        didSet{
            currUser?.qRef.child(currQuestion!.QID).setValue(liked ? "liked" : nil)
            likeBtn?.setImage(liked ? #imageLiteral(resourceName: "star_filled") : #imageLiteral(resourceName: "star").withRenderingMode(.alwaysTemplate), for: [])
        }
    }
    var asker:UserModel?{
        didSet{
            if let asker = asker{
                if let img = asker.profileImg {
                    askerProfile.setImage(img, for: [])
                    askerProfile.imageView?.contentMode = .scaleAspectFill
                }
                else{
                    asker.loadProfileImg()
                    setAskerImg()
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
    var currQuestion:QuestionModel?
    var collectionView:UICollectionView!
    var pullUpMask = UILabel()
//    var pullDownMask = UILabel()
    var optArr = [OptionModel]()
    var noQuestionMask = UILabel()
    var collectionFooter:MJRefreshBackNormalFooter!
    
    // Actions
    @IBAction func askerInfo(_ sender: AnyObject) {
        showUser(user: asker)
    }
    
    @IBAction func showAskVC(_ sender: AnyObject) {
        if currUser!.qInProgress.count >= currUser!.qInProgressLimit{
            _ = SCLAlertView().showError("Sorry", subTitle: "You are only allowed to have up to \(currUser!.qInProgressLimit) in progress questions. Please conclude a question.")
        }
        else{
            let vc = VC(name: "Ask Question", isCenter: false) as! UINavigationController
            show(vc, sender: self)
        }
    }
    
    @IBAction func likeAction(_ sender: AnyObject) {
        if !liked && currUser!.qCollection.count >= currUser!.qInCollectionLimit{
            _ = SCLAlertView().showError("Sorry", subTitle: "You are only allowed to have up to \(currUser!.qInCollectionLimit) in collection. Please conclude a question.")
        }
        else{
            liked = !liked
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
        else if let askerId = asker?.uid{
            NotificationCenter.default.addObserver(self, selector: #selector(setAskerImg), name: NSNotification.Name(askerId + "profile"), object: nil)
        }
    }
    
    func setQuestion(){
        currQuestion = questionManager.getQuestion()
        collectionView.isUserInteractionEnabled = true
        let noQuestion = (currQuestion == nil)
        titleBarView.isHidden = noQuestion
        detailTV.isHidden = noQuestion
        pullUpMask.isHidden = noQuestion
        noQuestionMask.isHidden = !noQuestion
        optArr.removeAll()
        collectionView.reloadData()
        if let question = currQuestion{
            collectionView.mj_footer = collectionFooter
            if question.qAnonymous {
                asker = nil
            }
            else{
                asker = UserModel.getUser(uid: question.qAskerID, getProfile: true)
            }
            handler.setText(question.qDescrption, withAnimation: true)
            optArr = question.qOptions
            if optArr.count == 0 {
                pullUpMask.isHidden = false
//                pullDownMask.isHidden = false
            }
            else {
                pullUpMask.isHidden = true
//                pullDownMask.isHidden = true
            }
            titlebarHeight.constant = 56
            collectionView.board(radius: 0, width: 1, color: .gray)
        }
        else{
            heightConstraint.constant = 0
            titlebarHeight.constant = 0
            collectionView.mj_footer = nil
            collectionView.board(radius: 0, width: 0, color: .gray)
        }
        collectionView.reloadData()
        if optArr.count > 0{
            collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: UICollectionViewScrollPosition.top, animated: false)
        }

    }
    
    func showUser(user:UserModel?){
        if let user = user{
            let vc = VC(name: "Profile", isNav: false, isCenter: false, isNew: true) as! ProfileVC
            vc.thisUser = user
            user.profileVC = vc
            navigationController?.pushViewController(vc, animated: true)
        }
        else{
            _ = SCLAlertView().showWarning("Sorry", subTitle: "Anonymous asker")
        }
    }
    
    func setupUI() {
        askerProfile.imageView?.contentMode = .scaleAspectFill
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
//        pullDownMask.text = "Pull down to get next question"
//        pullDownMask.textAlignment = .center
//        pullDownMask.isHidden = true
//        pullDownMask.textColor = .gray
//        collectionView.addSubview(pullDownMask)
//        _ = pullDownMask.sd_layout().topSpaceToView(pullUpMask, 10)?.leftSpaceToView(collectionView, 0)?.rightSpaceToView(collectionView, 0)?.heightIs(30)
        
        noQuestionMask.text = "No question available now."
        noQuestionMask.textAlignment = .center
        view.addSubview(noQuestionMask)
        _ = noQuestionMask.sd_layout().topSpaceToView(view, 0)?.bottomSpaceToView(view, 0)?.rightSpaceToView(view, 0)?.leftSpaceToView(view, 0)
    }
    
    func addOption(text:String){
        let opt = OptionModel(description: text, offerBy: (appSetting.isAnonymous) ? nil : currUser!.uid)
        currQuestion?.addOption(opt: opt)
        optArr.append(opt)
        collectionView.reloadData()
//        pullDownMask.isHidden = true
        pullUpMask.isHidden = true
        collectionView.scrollToItem(at: IndexPath(row: optArr.count-1, section: 0), at: UICollectionViewScrollPosition.top, animated: false)
        currQuestion?.choose(val: opt.oRef.key)
    }
    
    func nextQuestion(){
        if #available(iOS 10.0, *) {
            Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { (timer) in
                self.setQuestion()
            }
        } else {
            _ = Timer.scheduledTimer(timeInterval: 0.6, target: self, selector: #selector(setQuestion), userInfo: nil, repeats: false)
        }
    }
    
    func initTable() {
        // Do any additional setup after loading the view.
        let layout = SFFocusViewLayout()
        layout.standardHeight = 50
        layout.focusedHeight = 180
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
                self.currQuestion?.choose()
                self.nextQuestion()
                self.collectionView.mj_header.endRefreshing()
            })!
            header.lastUpdatedTimeLabel.isHidden = true
            header.setTitle("Next question", for: .pulling)
            header.setTitle("Pull down to get next question", for: .idle)
            collectionView.mj_header = header
            
            collectionFooter = MJRefreshBackNormalFooter(refreshingBlock: {
                let alert = SCLAlertView()
                let optionText = alert.addTextView()
                _ = alert.addButton("Add", action: {
                    if optionText.text == ""{
                        _ = SCLAlertView().showError("Sorry", subTitle: "Option text cannot be empty.")
                    }
                    else{
                        self.addOption(text: optionText.text)
                        self.nextQuestion()
                    }
                })
                _ = alert.showEdit("Another Option", subTitle: "", closeButtonTitle: "Cancel")
                self.collectionView.mj_footer.endRefreshing()
            })!
            collectionFooter.setTitle("Pull to add an option", for: .idle)
            collectionFooter.setTitle("Add an option", for: .pulling)
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
    
    func questionLoaded(){
        if noQuestionMask.isHidden == false{
            nextQuestion()
        }
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
        NotificationCenter.default.addObserver(self, selector: #selector(questionLoaded), name: NSNotification.Name("QuestionLoaded"), object: nil)
        nextQuestion()
        if isCollection != nil{
            collectionSetup()
        }
        setDescription(description: "")
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
//        return repository.count
        return optArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as CollectionViewCell
        cell.option = optArr[indexPath.row]
        cell.parent = self
        cell.likeBtn.setImage(img: #imageLiteral(resourceName: "like"), color: pinkColor)
        return cell
    }
    
    @objc(collectionView:willDisplayCell:forItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        (cell as! CollectionViewCell).option = optArr[indexPath.row]
//        guard let cell = cell as? CollectionViewCellRender else {
//            fatalError("error with registred cell")
//        }
//        
//        renderer.presentModel(model: repository[indexPath.item], inView: cell)
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
