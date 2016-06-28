//
//  QuestionVC.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/26/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import GrowingTextViewHandler
import SCTableViewCell

class QuestionVC: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
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
        detailTV.isSelectable = false
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = SCTableViewCell(style: .default, reuseIdentifier: "reuseIdentifier", in: <#T##UITableView!#>)
    }
}
