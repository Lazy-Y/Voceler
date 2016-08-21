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
    var text:String?
    var parentVC:OptionsVC?
    var indexPath:IndexPath?
    
    // Actions
    func textChange(noti:Notification) {
        handler.resizeTextView(withAnimation: true)
    }
    
    func nextAction(){
        if let parentVC = parentVC{
            if let indexPath = indexPath{
                dismiss(animated: true, completion: {
                    parentVC.textReset(indexPath: indexPath, text: self.textView.text)
                })
            }
            else {
                dismiss(animated: true, completion: { 
                    parentVC.addOpt(text: self.textView.text)
                })
            }
        }
        else {
            navigationController?.pushViewController(VC(name: "Options", isNav: false, isCenter: false), animated: true)
        }
    }
    
    func cancelAction() {
        dismiss(animated: true, completion: nil)
    }
    
    // Functions
    func setupUI() {
        let notiCenter = NotificationCenter.default()
        notiCenter.addObserver(self, selector: #selector(textChange(noti:)), name: Notification.Name.UITextViewTextDidChange, object: textView)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextAction))
        edgesForExtendedLayout = []
        textView.text = ""
        textView.becomeFirstResponder()
        handler = GrowingTextViewHandler(textView: textView, withHeightConstraint: heightTV)
        handler.updateMinimumNumber(ofLines: 1, andMaximumNumberOfLine: 10)
        scroll.delegate = self
    }
    
    // Override functions    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        textView.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let text = text {
            handler.setText(text, withAnimation: true)
        }
    }
}
