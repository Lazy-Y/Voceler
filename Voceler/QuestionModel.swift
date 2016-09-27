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
    var qTime:Date!
    var qOptions = [OptionModel]() // Question options (option id: OID)
    var qTags = [String]()
    var qViews = 0
    var qPriority:Double = 0.0
    var qRef:FIRDatabaseReference!{
        return FIRDatabase.database().reference().child("Questions").child(QID)
    }
    
    init(qid:String, descrpt:String, askerID:String, anonymous:Bool=false, options:[OptionModel]) {
        super.init()
        QID = qid
        qDescrption = descrpt
        qAskerID = askerID
        qAnonymous = anonymous
        qOptions = options
    }
    
    override init(){
        super.init()
    }
    
    func postQuestion(){
        // Set up question
        let ref = FIRDatabase.database().reference().child("Questions").childByAutoId()
        QID = ref.key
        let contentRef = ref.child("content")
        ref.setPriority(qPriority)
        contentRef.child("description").setValue(qDescrption)
        contentRef.child("askerID").setValue(qAskerID)
        contentRef.child("anonymous").setValue(qAnonymous)
        contentRef.child("time").setValue(qTime.timeIntervalSince1970)
        ref.child("priority").setValue(qPriority)
        for opt in qOptions{
            let optRef = contentRef.child("options").childByAutoId()
            optRef.child("description").setValue(opt.oDescription)
            optRef.child("offerBy").setValue(qAskerID)
            optRef.child("val").setValue(0)
        }
        
        // Set up tags
//        ref.child("tags").setValue(qTags)
        let tagRef = FIRDatabase.database().reference().child("Tags")
        let allTagRef = tagRef.child("all").child(QID)
        allTagRef.setPriority(qPriority)
        allTagRef.setValue("1")
//        for tag in qTags{
//            let ref = tagRef.child(tag).child(QID)
//            ref.setValue("0")
//            ref.setPriority(qPriority)
//        }
        
        // Add question to user
        choose(val: "owner")
    }
    
    func addOption(opt:OptionModel){
        let optRef = qRef.child("content").child("options").childByAutoId()
        optRef.child("description").setValue(opt.oDescription)
        optRef.child("offerBy").setValue(opt.oOfferBy)
        optRef.child("val").setValue(opt.oVal)
        opt.oRef = optRef
    }
    
    func choose(val:String = "skipped"){
        qRef.child("Users").child(currUser!.uid).setValue(val)
    }
}
