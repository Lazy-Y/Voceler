//
//  Globle.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/25/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import MMDrawerController
let themeColor = UIColor(colorLiteralRed: 0.334777, green: 0.694178, blue: 0.785027, alpha: 1)

func getVC(name:String) -> UIViewController {
    let board = UIStoryboard(name: "Main", bundle: nil)
    return board.instantiateViewController(withIdentifier: name)
}

func getNav(name:String) -> UINavigationController {
    let vc = getVC(name: name)
    let nav = UINavigationController(rootViewController: vc)
    nav.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Helvetica Neue", size: 20)!, NSForegroundColorAttributeName: UIColor.white()]
    vc.title = name
    nav.navigationBar.barTintColor = themeColor
    vc.navigationItem.leftBarButtonItem = profileItem()
    return nav
}

func profileItem() -> UIBarButtonItem {
    let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
    let img = UIImage(named: "logo")!.resize(newWidth: 40)
    btn.setImage(img, for: [])
    btn.layer.cornerRadius = 20
    btn.layer.masksToBounds = true
    //    btn.addTarget(btn, action: #selector(vc.showMore(_:)), for: .touchUpInside)
    return UIBarButtonItem(customView: btn)
}

internal var drawerVC:MMDrawerController?
var drawer:MMDrawerController{
    if let vc = drawerVC{
        return vc
    }
    else {
        let left = getVC(name: "CtrlVC")
        let vc = MMDrawerController(center: VC(name: "Question"), leftDrawerViewController: left)!
        vc.openDrawerGestureModeMask = .panningCenterView
        vc.closeDrawerGestureModeMask = .panningCenterView
        drawerVC = vc
        return vc
    }
}

internal var myVC = [String:UINavigationController]()
func VC(name:String) -> UINavigationController{
    if let vc = myVC[name]{
        return vc
    }
    else {
        myVC[name] = getNav(name: name)
        return myVC[name]!
    }
}

func randFloat()->CGFloat{
    return CGFloat(Float(arc4random()) / Float(UINT32_MAX))/2 + 0.5
}

func getRandomColorImage()->UIImage{
    return getImageWithColor(color: UIColor(red: randFloat(), green: randFloat(), blue: randFloat(), alpha: 1), size: CGSize(width: 100, height: 100))
}

func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
    let rect = CGRect(x:0, y:0, width:size.width, height:size.height)
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    color.setFill()
    UIRectFill(rect)
    let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return image
}
