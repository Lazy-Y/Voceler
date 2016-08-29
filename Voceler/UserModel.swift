//
//  User.swift
//  Voceler
//
//  Created by 钟镇阳 on 8/22/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseStorage

class UserModel: NSObject {
    var uid:String!
    var email = ""
    var username:String?
    var ref:FIRDatabaseReference!
    var storageRef:FIRStorageReference!
    var qInProgress = Array<String>() // Question in progress (contains QID)
    var qAsked = Array<String>() // Asked Question
    var qCollection = Array<String>() // Collected Question
    var infoDic = Dictionary<String,String>() // Basic info array
    var profileVC:ProfileVC?
    
    private init(uid:String){
        self.uid = uid
    }
    
    static func getUser(uid:String)->UserModel{
        let user = UserModel(uid: uid)
        let ref = FIRDatabase.database().reference().child("Users").child(uid)
        user.storageRef = FIRStorage.storage().reference().child("Users").child(uid)
        user.setup(ref: ref)
        return user
    }
    
    func setup(ref:FIRDatabaseReference){
        self.ref = ref
        ref.observe(FIRDataEventType.value, with:{ (snapshot) in
            print(snapshot)
            if let userInfo = snapshot.value as? Dictionary<String,String>{
                self.email = userInfo["email"]!
                self.username = userInfo["username"]
                self.infoDic = userInfo
                if let profileVC = self.profileVC{
                    profileVC.loadUserInfo()
                }
            }
        })
    }
}