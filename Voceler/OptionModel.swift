//
//  OptionModel.swift
//  Voceler
//
//  Created by 钟镇阳 on 8/23/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import Foundation

class OptionModel: NSObject {
    var OID:String!
    var oDescription:String!
    var numOfLike:Int!
    var oProvider:String! // UID of option provider
    var oLikers = Array<String>() // UID of users who liked this option
    private init(oid:String, description:String, numOfLike:Int!, provider:String){
        OID = oid
        oDescription = description
        self.numOfLike = numOfLike
        oProvider = provider
    }
}
