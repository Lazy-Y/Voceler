//
//  NoContentView.swift
//  Voceler
//
//  Created by 钟镇阳 on 10/1/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import MJRefresh

class NoContentView: UIView {
    
    @IBOutlet weak var scroll: UIScrollView!
    var parent:QuestionVC!
    
    func setupView(parent:QuestionVC){
        self.parent = parent
        let header = MJRefreshNormalHeader(refreshingBlock: {
            parent.nextQuestion()
            parent.collectionView.mj_header.endRefreshing()
        })!
        header.lastUpdatedTimeLabel.isHidden = true
        header.setTitle("Next question", for: .pulling)
        header.setTitle("Pull down to get next question", for: .idle)
        scroll.mj_header = header
    }
}
