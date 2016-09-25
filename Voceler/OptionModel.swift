//
//  OptionModel.swift
//  Voceler
//
//  Created by 钟镇阳 on 9/23/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit

class OptionModel: NSObject {
    var oDescription = ""
    var oOfferBy:String?
    var oVal = 0
    init(description:String, offerBy:String? = nil, val:Int = 0) {
        oDescription = description
        oOfferBy = offerBy
        oVal = val
    }
    init(description:String, dict:Dictionary<String,Any>){
        oDescription = description
        if let offerBy = dict["offerBy"] as? String{
            oOfferBy = offerBy
        }
        oVal = dict["val"] as! Int
    }
}
