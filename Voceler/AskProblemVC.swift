//
//  AskProblemVC.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/30/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import GrowingTextViewHandler

class AskProblemVC: UIViewController, UIScrollViewDelegate{
    // UIVars
    @IBOutlet weak var heightTV: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var scroll: UIScrollView!
    
    // FieldVars
    var handler:GrowingTextViewHandler!
    
    // Actions
    
    // Functions
    func setupUI() {
        let notiCenter = NotificationCenter.default()
        notiCenter.addObserver(self, selector: #selector(textChange(noti:)), name: Notification.Name.UITextViewTextDidChange, object: textView)
        
        navigationController?.navigationBar.tintColor = UIColor.white()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(nextAction))
        edgesForExtendedLayout = []
        textView.text = ""
        textView.becomeFirstResponder()
        handler = GrowingTextViewHandler(textView: textView, withHeightConstraint: heightTV)
        handler.updateMinimumNumber(ofLines: 1, andMaximumNumberOfLine: 10)
        scroll.delegate = self
    }
    
    func textChange(noti:Notification) {
        handler.resizeTextView(withAnimation: true)
    }
    
    func nextAction(){
        navigationController?.pushViewController(VC(name: "Options", isNav: false, isCenter: false), animated: true)
    }
    
    func cancelAction() {
        dismiss(animated: true, completion: nil)
    }
    
    // Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        textView.endEditing(true)
    }
}
