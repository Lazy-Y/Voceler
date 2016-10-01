//
//  QuestionView.swift
//  Voceler
//
//  Created by 钟镇阳 on 10/1/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import GrowingTextViewHandler
import MJRefresh
import SFFocusViewLayout
import SCLAlertView
import SDAutoLayout

class QuestionView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {

    
    // FieldVars
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
    @IBOutlet weak var titleBarView: UIView!
    @IBOutlet weak var likeBtn: UIButton?
    @IBOutlet weak var detailTV: UITextView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var askerProfile: UIButton!
    @IBOutlet weak var askerLbl: UILabel!
    var currQuestion:QuestionModel!
    var collectionView:UICollectionView!
    var pullUpMask = UILabel()
    var optArr = [OptionModel]()
    var collectionFooter:MJRefreshBackNormalFooter!
    var parent:QuestionVC!
    
    // Actions
    @IBAction func askerInfo(_ sender: AnyObject) {
        showUser(user: asker)
    }
    
    @IBAction func likeAction(_ sender: AnyObject) {
        if !liked && currUser!.qCollection.count >= currUser!.qInCollectionLimit{
            _ = SCLAlertView().showError("Sorry", subTitle: "You are only allowed to have up to \(currUser!.qInCollectionLimit) in collection. Please conclude a question.")
        }
        else{
            liked = !liked
        }
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
    
    func setQuestion(question:QuestionModel){
        currQuestion = question
        collectionView.isUserInteractionEnabled = true
        optArr.removeAll()
        
        collectionView.mj_footer = collectionFooter
        asker = question.qAnonymous ? nil : UserModel.getUser(uid: question.qAskerID, getProfile: true)
        handler.setText(question.qDescrption, withAnimation: true)
        optArr = question.qOptions
        pullUpMask.isHidden = optArr.count > 0
        titlebarHeight.constant = 56
        collectionView.board(radius: 0, width: 1, color: .gray)
        
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
            parent.navigationController?.pushViewController(vc, animated: true)
        }
        else{
            _ = SCLAlertView().showWarning("Sorry", subTitle: "Anonymous asker")
        }
    }
    
    func setupUI() {
        askerProfile.imageView?.contentMode = .scaleAspectFill
        asker = currUser

        _ = titleBarView.addBorder(edges: .bottom, colour: UIColor.gray, thickness: 1.5)
        handler = GrowingTextViewHandler(textView: self.detailTV, withHeightConstraint: self.heightConstraint)
        handler.updateMinimumNumber(ofLines: 1, andMaximumNumberOfLine: 5)
        detailTV.isEditable = false
        askerProfile.board(radius: 20, width: 3, color: UIColor.white)
        likeBtn?.setImage(#imageLiteral(resourceName: "star").withRenderingMode(.alwaysTemplate), for: [])
        likeBtn?.tintColor = darkRed
        initTable()
        
        pullUpMask.text = "Pull up to add an option"
        pullUpMask.textAlignment = .center
        pullUpMask.isHidden = true
        pullUpMask.textColor = .gray
        collectionView.addSubview(pullUpMask)
        _ = pullUpMask.sd_layout().topSpaceToView(detailTV, 10)?.leftSpaceToView(collectionView, 0)?.rightSpaceToView(collectionView, 0)?.heightIs(30)
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
    
    func initTable() {
        // Do any additional setup after loading the view.
        let layout = SFFocusViewLayout()
        layout.standardHeight = 50
        layout.focusedHeight = 180
        layout.dragOffset = 100
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 100, height: 110), collectionViewLayout: layout)
        addSubview(collectionView)
        _ = collectionView.sd_layout()
            .topSpaceToView(detailTV, 0)?
            .bottomSpaceToView(self, 0)?
            .leftSpaceToView(self, 0)?
            .rightSpaceToView(self, 0)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(CollectionViewCell.self)
        
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        collectionView.backgroundColor = .white
        
        let header = MJRefreshNormalHeader(refreshingBlock: {
            print("refresh")
            self.currQuestion?.choose()
            self.parent.nextQuestion()
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
                    self.parent.nextQuestion()
                }
            })
            _ = alert.showEdit("Another Option", subTitle: "", closeButtonTitle: "Cancel")
            self.collectionView.mj_footer.endRefreshing()
        })!
        collectionFooter.setTitle("Pull to add an option", for: .idle)
        collectionFooter.setTitle("Add an option", for: .pulling)
    }
    
    func setDescription(description:String) {
        detailTV.isSelectable = true
        handler.setText(description, withAnimation: true)
        detailTV.isSelectable = false
    }
    
    // Override functions
    func setupView(superVC:QuestionVC, question:QuestionModel) {
        parent = superVC
        setupUI()
        setDescription(description: "")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(collectionView)
        return optArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(forIndexPath: indexPath) as CollectionViewCell
        cell.option = optArr[indexPath.row]
        cell.parent = self.parent
        cell.likeBtn.setImage(img: #imageLiteral(resourceName: "like"), color: pinkColor)
        return cell
    }
    
    @objc(collectionView:willDisplayCell:forItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        (cell as! CollectionViewCell).option = optArr[indexPath.row]
    }

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
