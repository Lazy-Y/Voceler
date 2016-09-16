//
//  QuestionModel.swift
//  Voceler
//
//  Created by 钟镇阳 on 8/23/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import Foundation

enum QuestionStatus {
    case open
    case closed
}

enum QuestionType {
    case regular
    case urgent
    case professional
}

class QuestionModel: NSObject {
    var QID:String!
    var qDescrption:String! // Question Description
    var qAskerID:String! // UID
    var qAnonymous:Bool // Don't show the asker to public
    var qStatus:QuestionStatus!
    var qType:QuestionType!
    var qOptions = Array<String>() // Question options (option id: OID)
    private init(qid:String, descrpt:String, askerID:String, anonymous:Bool=false, status:QuestionStatus = .open, type:QuestionType = .regular) {
        QID = qid
        qDescrption = descrpt
        qAskerID = askerID
        qAnonymous = anonymous
        qStatus = status
        qType = type
    }
    static func getQuestion(qid: String)->QuestionModel{
        return QuestionModel(qid: qid, descrpt:"2016-09-15 22:01:01.551154 Voceler[942:341432] 0refresh2016-09-15 22:01:04.644524 Voceler[942:341432] 0" , askerID: "abc")
    }
}
