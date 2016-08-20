//
//  CtrlVC.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/25/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import SDAutoLayout
import BSGridCollectionViewLayout
import BFPaperButton
import FirebaseAuth

class CtrlVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    // UIVars
    @IBOutlet weak var profileBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var moneyImg: UIImageView!
    @IBOutlet weak var wuImg: UIImageView!
    @IBOutlet weak var wuLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    
    
    // FieldVars
    let viewsArr = ["Question", "Collection", "Settings", "Log out"]
    
    // Actions
    @IBAction func showProfile(_ sender: AnyObject) {
        let profile = VC(name: "Profile")
        (profile.childViewControllers.first as! ProfileVC).uid = FIRAuth.auth()?.currentUser?.uid
        drawer.centerViewController = profile
        drawer.toggle(.left, animated: true, completion: nil)
    }
    
    // Functions
    func setupUI() {
        profileBtn.board(radius: 32, width: 3, color: themeColor)
        moneyImg.setIcon(img: #imageLiteral(resourceName: "money"), color: themeColor)
        collectionView.register(UINib(nibName: "CtrlCell", bundle: nil), forCellWithReuseIdentifier: "CtrlCell")
        let layout = GridCollectionViewLayout()
        layout.itemsPerRow = 2
        layout.itemHeightRatio = 1
        layout.itemSpacing = 20
        collectionView.collectionViewLayout = layout
        collectionView.clearAutoMarginFlowItemsSettings()
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        wuImg.setIcon(img: #imageLiteral(resourceName: "lol-32"), color: themeColor)
        wuLbl.text = "I'll regrade your ass ignment!"
        wuLbl.textColor = themeColor
        nameLbl.textColor = themeColor
        amountLbl.textColor = themeColor
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: nil)
    }
    
    // Override functions

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return viewsArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CtrlCell", for: indexPath) as! CtrlCell
        cell.title.text = viewsArr[indexPath.row]
        cell.title.textColor = themeColor
        cell.imageView.setIcon(img: UIImage(named: viewsArr[indexPath.row])!, color: themeColor)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == viewsArr.count - 1 {
            try! FIRAuth.auth()?.signOut()
            dismiss(animated: true, completion: nil)
        }
        else {
            drawer.centerViewController = VC(name: viewsArr[indexPath.row])
            drawer.toggle(.left, animated: true, completion: nil)
        }
    }
}
