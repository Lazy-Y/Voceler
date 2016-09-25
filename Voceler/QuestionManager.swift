//
//  QuestionManager.swift
//  Voceler
//
//  Created by 钟镇阳 on 9/23/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import Foundation
import FirebaseDatabase

class QuestionManager: NSObject {
    private let size:UInt = 10
    private var collection = [QuestionModel]()
    private var ref:FIRDatabaseReference!
    private var isLoading = false
    
    override init() {
        super.init()
        ref = FIRDatabase.database().reference().child("Questions")
        self.refreshCollection()
    }
    private func refreshCollection() {
        if !isLoading{
            isLoading = true
            ref.queryOrderedByPriority().queryLimited(toFirst: size).observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
                if let value = snapshot.value as? Dictionary<String, Any>{
                    for (key, val) in value{
                        self.collection.append(QuestionModel.getQuestion(qid: key, question: val as? Dictionary<String, Any>)!)
                    }
                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "QuestionLoaded")))
                }
                self.isLoading = false
            })
        }
    }
    
    func getQuestion() -> QuestionModel?{
        if collection.count < 3{
            refreshCollection()
        }
        return collection.popLast()
    }
}
