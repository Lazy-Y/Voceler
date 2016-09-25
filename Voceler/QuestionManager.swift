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
    var collection = [QuestionModel]()
    private var ref:FIRDatabaseReference!
    private var tagsRef:FIRDatabaseReference!
    private var isLoading = false
//    private var loadingSet = NSSet()
    
    override init() {
        super.init()
        ref = FIRDatabase.database().reference().child("Questions")
        tagsRef = FIRDatabase.database().reference().child("Tags")
        self.refreshCollection()
    }
    private func refreshCollection() {
        if !isLoading{
            isLoading = true
            tagsRef.child("all").queryOrderedByPriority().queryLimited(toLast: size).observeSingleEvent(of: .value, with: { (snapshot) in
                if let value = snapshot.value as? Dictionary<String, Any>{
                    for (key, _) in value{
                        QuestionModel.loadQuestion(qid: key)
                    }
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
    
    func clean(){
        isLoading = false
        collection.removeAll()
        imageStorage.removeAll()
    }
}
