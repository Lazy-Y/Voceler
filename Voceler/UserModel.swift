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
    var profileImg:UIImage?
    var wallImg:UIImage?
    
    private init(uid:String){
        self.uid = uid
    }
    
    func loadProfileImg(){
        if let img = imageStorage[uid + "profile"]{
            profileImg = img
        }
        else{
            storageRef.child("profileImg.jpeg").data(withMaxSize: 1024*1024) { (data, error) in
                if let data = data{
                    self.profileImg = UIImage(data: data)
                }
                else {
                    self.profileImg = #imageLiteral(resourceName: "logo")
                }
                imageStorage[self.uid + "profile"] = self.profileImg
                NotificationCenter.default.post(name: NSNotification.Name(self.uid + "profile"), object: nil)
            }
        }
    }
    
    func loadWallImg(){
        if let img = imageStorage[uid + "wall"]{
            wallImg = img
        }
        else {
            storageRef.child("wallImg.jpeg").data(withMaxSize: 1024*1024) { (data, error) in
                if let data = data{
                    self.wallImg = UIImage(data: data)
                }
                else {
                    self.wallImg = #imageLiteral(resourceName: "WallBG")
                }
                imageStorage[self.uid + "wall"] = self.wallImg
                NotificationCenter.default.post(name: NSNotification.Name(self.uid + "wall"), object: nil)
            }
        }
    }
    
    static func getUser(uid:String, getWall:Bool = false, getProfile:Bool = false)->UserModel{
        let user = UserModel(uid: uid)
        let ref = FIRDatabase.database().reference().child("Users").child(uid)
        user.storageRef = FIRStorage.storage().reference().child("Users").child(uid)
        user.setup(ref: ref)
        if getProfile {
            user.loadProfileImg()
        }
        if getWall{
            user.loadWallImg()
        }
        return user
    }
    
    func setup(ref:FIRDatabaseReference){
        self.ref = ref
        ref.observe(FIRDataEventType.value, with:{ (snapshot) in
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
