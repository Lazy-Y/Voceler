//
//  UIExtension.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/22/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import BFPaperButton
import MMDrawerController

extension UIViewController{
    func initView(){
        touchToHideKeyboard()
        edgesForExtendedLayout = []
    }
    
    func touchToHideKeyboard(){
        let tab = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tab.isEnabled = true
        view.addGestureRecognizer(tab)
    }
    
    func hideKeyboard(){
        view.endEditing(true)
    }
    
    func showMore() {
        drawer.toggle(.left, animated: true, completion: nil)
    }
    
    func setupProfile(){
        let btn = (navigationItem.leftBarButtonItem?.customView as! UIButton)
        btn.addTarget(self, action: #selector(showMore), for: .touchUpInside)
    }
}

extension UIImageView{
    func setup(radius:CGFloat){
        layer.masksToBounds = true
        layer.cornerRadius = radius
    }
}

extension UITextField{
    func setup(radius:CGFloat){
        layer.cornerRadius = radius
    }
}

extension BFPaperButton{
    func setup(radius:CGFloat){
        isRaised = false
        cornerRadius = radius
    }
}

extension UIImage{
    func resize(newWidth: CGFloat) -> UIImage {
        //    let scale = newWidth / image.size.width
        //    let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newWidth))
        draw(in: CGRect(x:0, y:0, width:newWidth, height:newWidth))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}