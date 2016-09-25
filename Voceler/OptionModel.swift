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
        if let d = description.removingPercentEncoding{
            oDescription = d
        }
        else {
            oDescription = description
        }
        print(oDescription)
        oOfferBy = offerBy
        oVal = val
    }
    init(dict:Dictionary<String,Any>){
        oDescription = dict["description"] as! String
        if let offerBy = dict["offerBy"] as? String{
            oOfferBy = offerBy
        }
        oVal = dict["val"] as! Int
    }
}
