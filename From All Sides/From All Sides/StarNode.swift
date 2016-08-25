//
//  StarNode.swift
//  From All Sides
//
//  Created by Cormac Chester on 8/25/16.
//  Copyright © 2016 Cormac Chester. All rights reserved.
//

import Foundation
import SpriteKit

class StarNode: SKSpriteNode {
    
    class func star() -> StarNode {
        
        let star = StarNode(imageNamed: "star")
        star.name = "star"
        star.xScale = 0.5
        star.yScale = 0.5
        star.zPosition = -1.0
        
        return star
    }
}