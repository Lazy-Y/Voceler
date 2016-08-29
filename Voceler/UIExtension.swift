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
import LTNavigationBar

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
        if let btn = navigationItem.leftBarButtonItem?.customView as? UIButton{
            btn.addTarget(self, action: #selector(showMore), for: .touchUpInside)
        }
    }
}

extension UINavigationBar{
    func setColor(color:UIColor){
        barTintColor = color
        backgroundColor = color
        tintColor = .white()
        isTranslucent = true
        titleTextAttributes = [NSFontAttributeName: UIFont(name: "Helvetica Neue", size: 20)!, NSForegroundColorAttributeName: UIColor.white()]
        if color == UIColor.clear(){
            setBackgroundImage(UIImage(), for: .default)
        }
    }
}

extension UIImageView{
    func setup(radius:CGFloat){
        layer.masksToBounds = true
        layer.cornerRadius = radius
    }
    
    func setIcon(img:UIImage, color:UIColor) {
        image = img.withRenderingMode(.alwaysTemplate)
        tintColor = color
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

extension UIColor {
    func rgb() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            return (fRed, fGreen, fBlue, fAlpha)
        } else {
            return (0, 0, 0, 0)
        }
    }
}

extension UIView{
    func blury() {
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.backgroundColor = UIColor.clear()
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.addSubview(blurEffectView) //if you have more UIViews, use an insertSubview API to place it where needed
        } else {
            self.backgroundColor = UIColor.black()
        }
    }
    func hideKeyboard(){
        endEditing(true)
    }
    func touchToHideKeyboard(){
        let tab = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tab.isEnabled = true
        addGestureRecognizer(tab)
    }
    func board(radius:CGFloat, width:CGFloat, color:UIColor) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
    func addBorder(edges: UIRectEdge, colour: UIColor = UIColor.white(), thickness: CGFloat = 1) -> [UIView] {
        
        var borders = [UIView]()
        
        func border() -> UIView {
            let border = UIView(frame: CGRect.zero)
            border.backgroundColor = colour
            border.translatesAutoresizingMaskIntoConstraints = false
            return border
        }
        
        if edges.contains(.top) || edges.contains(.all) {
            let top = border()
            addSubview(top)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[top(==thickness)]",
                                                               options: [],
                                                               metrics: ["thickness": thickness],
                                                               views: ["top": top]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[top]-(0)-|",
                                                               options: [],
                                                               metrics: nil,
                                                               views: ["top": top]))
            borders.append(top)
        }
        
        if edges.contains(.left) || edges.contains(.all) {
            let left = border()
            addSubview(left)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[left(==thickness)]",
                                                               options: [],
                                                               metrics: ["thickness": thickness],
                                                               views: ["left": left]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[left]-(0)-|",
                                                               options: [],
                                                               metrics: nil,
                                                               views: ["left": left]))
            borders.append(left)
        }
        
        if edges.contains(.right) || edges.contains(.all) {
            let right = border()
            addSubview(right)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:[right(==thickness)]-(0)-|",
                                                               options: [],
                                                               metrics: ["thickness": thickness],
                                                               views: ["right": right]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[right]-(0)-|",
                                                               options: [],
                                                               metrics: nil,
                                                               views: ["right": right]))
            borders.append(right)
        }
        
        if edges.contains(.bottom) || edges.contains(.all) {
            let bottom = border()
            addSubview(bottom)
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "V:[bottom(==thickness)]-(0)-|",
                                                               options: [],
                                                               metrics: ["thickness": thickness],
                                                               views: ["bottom": bottom]))
            addConstraints(
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[bottom]-(0)-|",
                                                               options: [],
                                                               metrics: nil,
                                                               views: ["bottom": bottom]))
            borders.append(bottom)
        }
        
        return borders
    }
}

extension UIImage {
    var uncompressedPNGData: NSData! { return UIImagePNGRepresentation(self)! }
    var highestQualityJPEGNSData: NSData! { return UIImageJPEGRepresentation(self, 1.0)! }
    var highQualityJPEGNSData: NSData! { return UIImageJPEGRepresentation(self, 0.75)! }
    var mediumQualityJPEGNSData: NSData! { return UIImageJPEGRepresentation(self, 0.5)! }
    var lowQualityJPEGNSData: NSData! { return UIImageJPEGRepresentation(self, 0.25)! }
    var lowestQualityJPEGNSData:NSData! { return UIImageJPEGRepresentation(self, 0.0)! }
    func dataAtMost(bytes:Int)->Data{
        if uncompressedPNGData.length <= bytes{
            return uncompressedPNGData as Data
        }
        else if highestQualityJPEGNSData.length <= bytes{
            return highestQualityJPEGNSData as Data
        }
        else if mediumQualityJPEGNSData.length <= bytes{
            return mediumQualityJPEGNSData as Data
        }
        else if lowQualityJPEGNSData.length <= bytes{
            return lowQualityJPEGNSData as Data
        }
        else{
            return lowestQualityJPEGNSData as Data
        }
    }
}
