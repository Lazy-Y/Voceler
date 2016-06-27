//
//  QuestionVC.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/26/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import GrowingTextViewHandler

class QuestionVC: UIViewController, UITextViewDelegate  {
    // UIVars
    var handler:GrowingTextViewHandler!
    
    // FieldVars
    @IBOutlet weak var detailTV: UITextView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var askerProfile: UIButton!
    @IBOutlet weak var askerLbl: UILabel!
    
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
        askerProfile.layer.cornerRadius = 20
        askerProfile.layer.masksToBounds = true
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
}
