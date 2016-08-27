//
//  CometNode.swift
//  From All Sides
//
//  Created by Cormac Chester on 8/27/16.
//  Copyright © 2016 Cormac Chester. All rights reserved.
//

import Foundation
import SpriteKit

class CometNode: SKSpriteNode {
    class func comet() -> CometNode {
        
        let comet = CometNode(imageNamed: "comet")
        comet.name = "comet"
        
        comet.xScale = 0.5
        comet.yScale = 0.5
        
        comet.zPosition = 2
        
        comet.physicsBody = SKPhysicsBody(texture: comet.texture!, alphaThreshold: 0.8, size: comet.size)
        if let physics = comet.physicsBody {
            
            physics.dynamic = true
            physics.affectedByGravity = false
            physics.allowsRotation = false
            physics.categoryBitMask = PhysicsCategory.Comet //What category the projectile belongs to
            physics.contactTestBitMask = PhysicsCategory.Player //What category it interacts with
            physics.collisionBitMask = PhysicsCategory.Projectile | PhysicsCategory.Comet//What category bounces off of it
            physics.fieldBitMask = PhysicsCategory.PlayerGravity //What category of fields it interacts with
            physics.usesPreciseCollisionDetection = true
            physics.restitution = 0.7 //bounciness of projectile
            physics.linearDamping = 0
            physics.angularDamping = 0
            physics.mass = 1.3
        }
        return comet
    }
}