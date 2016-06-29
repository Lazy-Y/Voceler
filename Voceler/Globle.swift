//
//  Globle.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/25/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import MMDrawerController
let themeColor = UIColor(red: 0, green: 191/256, blue: 1, alpha: 1)//UIColor(red: 0.434777, green: 0.794178, blue: 0.885027, alpha: 1)
let buttomColor = UIColor(red: 0.694986, green: 0.813917, blue: 0.213036, alpha: 1)
let pinkColor = UIColor(red: 1, green: 0.3, blue: 0.3, alpha: 1.0)
let darkRed = UIColor(red: 0.8824, green: 0.0039, blue: 0.2353, alpha: 1.0)

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
    btn.board(radius: 20, width: 3, color: UIColor.white())
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

func changingColor(firstColor:UIColor, secondeColor:UIColor, fraction:CGFloat) -> CGColor {
    let (red1, green1, blue1, alpha1) = firstColor.rgb()
    let (red2, green2, blue2, alpha2) = secondeColor.rgb()
    let red = red2 * fraction + red1 * (1 - fraction)
    let green = green2 * fraction + green1 * (1 - fraction)
    let blue = blue2 * fraction + blue1 * (1 - fraction)
    let alpha = alpha2 * fraction + alpha1 * (1 - fraction)
    return UIColor(red: red, green: green, blue: blue, alpha: alpha).cgColor
}
