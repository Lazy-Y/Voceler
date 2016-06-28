//
//  OptCell.swift
//  Voceler
//
//  Created by Zhenyang Zhong on 6/27/16.
//  Copyright © 2016 Zhenyang Zhong. All rights reserved.
//

import UIKit
import FoldingCell

class OptCell: FoldingCell {
    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {
        return (itemIndex < 1) ? 0.33 : 0.26
    }
}
