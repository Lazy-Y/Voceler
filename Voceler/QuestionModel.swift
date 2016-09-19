//
//  QuestionModel.swift
//  Voceler
//
//  Created by 钟镇阳 on 8/23/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import Foundation
import FirebaseDatabase

class QuestionModel: NSObject {
    var QID:String!
    var qDescrption:String! // Question Description
    var qAskerID:String! // UID
    var qAnonymous = false // Don't show the asker to public
    var qIsOpen = true
    var qTime:Date!
    var qOptions = Array<String>() // Question options (option id: OID)
    var qTags = Array<String>()
    var qViews = 0
    var qPriority:Double!
    private init(qid:String, descrpt:String, askerID:String, anonymous:Bool=false) {
        QID = qid
        qDescrption = descrpt
        qAskerID = askerID
        qAnonymous = anonymous
    }
    override init(){
        super.init()
    }
    static func getQuestion(qid: String)->QuestionModel{
        return QuestionModel(qid: qid, descrpt:"2016-09-15 22:01:01.551154 Voceler[942:341432] 0refresh2016-09-15 22:01:04.644524 Voceler[942:341432] 0" , askerID: "abc")
    }
    func postQuestion(){
        let ref = FIRDatabase.database().reference().child("Questions").childByAutoId()
        QID = ref.key
        ref.setPriority(qPriority)
        ref.child("description").setValue(qDescrption)
        ref.child("askerID").setValue(qAskerID)
        ref.child("anonymous").setValue(qAnonymous)
        ref.child("isOpen").setValue(qIsOpen)
        ref.child("time").setValue(qTime.timeIntervalSince1970)
        ref.child("priority").setValue(qPriority)
        for opt in qOptions{
            ref.child("options").child(opt).child("offerBy").setValue(qAskerID)
            ref.child("options").child(opt).child("val").setValue(0)
        }
        ref.child("tags").setValue(qTags)
        let tagRef = FIRDatabase.database().reference().child("Tags")
        for tag in qTags{
            let ref = tagRef.child(tag).child(QID)
            ref.setValue("0")
            ref.setPriority(qPriority)
        }
    }
}
