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

        //Create random number
        func randNum() -> CGFloat {
            return CGFloat(Float(arc4random())/0xFFFFFFFF)
        }
        
        
        //Create random range
        func random(min: CGFloat , max: CGFloat) -> CGFloat {
            return randNum()*(max-min)+min
        }

        let whichProjectile = arc4random_uniform(4)
        var projectileImageStr = String()
        
        switch whichProjectile {
        case 0:
            projectileImageStr = "asteroid1"
        break
        case 1:
            projectileImageStr = "asteroid2"
        break
        case 2:
            projectileImageStr = "asteroid3"
        break
        case 3:
            projectileImageStr = "asteroid4"
        default:
            print("There was a problem with the image selection. The image will be the default projectile")
            projectileImageStr = "asteroid"
        }
        
        let projectile = ProjectileNode(imageNamed: projectileImageStr)
        projectile.name = "projectile"
        
        let projXScale = random(0.2, max: 0.8)
        let projYScale = random(0.2, max: 0.8)
        
        projectile.xScale = projXScale
        projectile.yScale = projYScale
        
        projectile.zPosition = 1.5
        
        projectile.physicsBody = SKPhysicsBody(texture: projectile.texture!, alphaThreshold: 0.8, size: projectile.size)
        if let physics = projectile.physicsBody {
            
            physics.dynamic = true
            physics.affectedByGravity = false
            physics.categoryBitMask = PhysicsCategory.Projectile //What category the projectile belongs to
            physics.contactTestBitMask = PhysicsCategory.Player //What category it interacts with
            physics.collisionBitMask = PhysicsCategory.Projectile //What category bounces off of it
            physics.fieldBitMask = PhysicsCategory.PlayerGravity //What category of fields it interacts with
            physics.usesPreciseCollisionDetection = true
            physics.restitution = 0.7 //bounciness of projectile
            physics.linearDamping = 0
            physics.angularDamping = 0
            physics.mass = 1.3
        }
        
        return projectile
    }
    
    
}