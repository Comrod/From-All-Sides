//
//  ProjectileNode.swift
//  From All Sides
//
//  Created by Cormac Chester on 8/24/16.
//  Copyright © 2016 Cormac Chester. All rights reserved.
//

import Foundation
import SpriteKit

class ProjectileNode: SKSpriteNode {
    
    
    class func projectile() -> ProjectileNode {

        let projectile = ProjectileNode(imageNamed: "asteroid")
        projectile.name = "projectile"
        projectile.xScale = 0.5
        projectile.yScale = 0.5
        
        //Value for size of projectile
        let projSize = projectile.size.height

        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projSize/2)
        if let physics = projectile.physicsBody {
            
            physics.dynamic = true
            physics.affectedByGravity = false
            physics.categoryBitMask = PhysicsCategory.Projectile //What category the projectile belongs to
            physics.contactTestBitMask = PhysicsCategory.Player //What category it interacts with
            physics.collisionBitMask = PhysicsCategory.Projectile | PhysicsCategory.IrregularAsteroid //What category bounces off of it
            physics.fieldBitMask = PhysicsCategory.PlayerGravity //What category of fields it interacts with
            physics.usesPreciseCollisionDetection = true
            physics.restitution = 0.7 //bounciness of projectile
            physics.mass = 1.3
        }
        
        return projectile
    }
    
}