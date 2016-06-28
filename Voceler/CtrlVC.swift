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
    
    // FieldVars
    let viewsArr = ["Question", "Collection", "Settings", "Log out"]
    
    // Actions
    @IBAction func showProfile(_ sender: AnyObject) {
        drawer.centerViewController = VC(name: "Profile")
        drawer.toggle(.left, animated: true, completion: nil)
    }
    
    // Functions
    func initUI() {
        profileBtn.layer.masksToBounds = true
        profileBtn.layer.cornerRadius = 32
        profileBtn.layer.borderColor = UIColor.white().cgColor
        profileBtn.layer.borderWidth = 3
        moneyImg.image = UIImage(named: "money")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        moneyImg.tintColor = UIColor.white()
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
    }
    
    // Override functions

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initUI()
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
        cell.title.textColor = UIColor.white()
        cell.imageView.image = UIImage(named: viewsArr[indexPath.row])!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        cell.imageView.tintColor = UIColor.white()
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
