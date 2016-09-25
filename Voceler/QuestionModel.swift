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
    var qOptions = [OptionModel]() // Question options (option id: OID)
    var qTags = [String]()
    var qViews = 0
    var qPriority:Double = 0.0
    var qRef:FIRDatabaseReference!{
        return FIRDatabase.database().reference().child("Questions").child(QID)
    }
    static func loadQuestion(qid:String){
        _ = FIRDatabase.database().reference().child("Questions").child(qid).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.value)
            questionManager.collection.append(QuestionModel.getQuestion(qid: qid, question: snapshot.value as? Dictionary<String, Any>)!)
            if questionManager.collection.count < 2{
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "QuestionLoaded")))
            }
        })
    }
    private init(qid:String, descrpt:String, askerID:String, anonymous:Bool=false, options:[OptionModel]) {
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
    static func getQuestion(qid: String?, question:Dictionary<String, Any>?)->QuestionModel?{
        if let qid = qid, let question = question{
            var optArr = [OptionModel]()
            if let opts = question["options"] as? Dictionary<String, Any>{
                for (key, dict) in opts {
                    optArr.append(OptionModel(dict: dict as! Dictionary<String, Any>))
                }
            }
            return QuestionModel(qid: qid, descrpt: question["description"] as! String, askerID: question["askerID"] as! String, anonymous: question["anonymous"] as! Bool, options: optArr)
        }
        else{
            return nil
        }
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
            let optRef = ref.child("options").childByAutoId()
            optRef.child("description").setValue(opt.oDescription)
            optRef.child("offerBy").setValue(qAskerID)
            optRef.child("val").setValue(0)
        }
//        ref.child("tags").setValue(qTags)
        let tagRef = FIRDatabase.database().reference().child("Tags")
        let allTagRef = tagRef.child("all").child(QID)
        allTagRef.setValue("0")
        allTagRef.setPriority(qPriority)
//        for tag in qTags{
//            let ref = tagRef.child(tag).child(QID)
//            ref.setValue("0")
//            ref.setPriority(qPriority)
//        }
    }
    
    func addOption(opt:OptionModel){
        let optRef = qRef.child("options").childByAutoId()
        optRef.child("description").setValue(opt.oDescription)
        optRef.child("offerBy").setValue(opt.oOfferBy)
        optRef.child("val").setValue(opt.oVal)
    }
}
