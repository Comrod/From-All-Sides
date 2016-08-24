//
//  IrregularAsteroidNode.swift
//  From All Sides
//
//  Created by Cormac Chester on 8/24/16.
//  Copyright © 2016 Cormac Chester. All rights reserved.
//

import Foundation
import SpriteKit

class IrregularAsteroidNode: SKSpriteNode {
    
    
    
    class func irregularAsteroid() -> IrregularAsteroidNode {
        
        let irregularAsteroid = IrregularAsteroidNode(imageNamed: "irregularasteroid")
        irregularAsteroid.name = "irregularAsteroid"
        irregularAsteroid.xScale = 0.5
        irregularAsteroid.yScale = 0.5
        
        //Value for size of projectile
        //let projSize = irregularAsteroid.size.height
        /*let iAPath = UIBezierPath()
        
        iAPath.moveToPoint(CGPointMake(0, 36))
        iAPath.addLineToPoint(CGPointMake(0, 12))
        iAPath.addLineToPoint(CGPointMake(1, 9))
        iAPath.addLineToPoint(CGPointMake(2, 7))
        iAPath.addLineToPoint(CGPointMake(3, 6))
        iAPath.addLineToPoint(CGPointMake(5, 5))
        iAPath.addLineToPoint(CGPointMake(9, 1))
        iAPath.addLineToPoint(CGPointMake(11, 0))
        iAPath.addLineToPoint(CGPointMake(39, 0))
        iAPath.addLineToPoint(CGPointMake(43, 2))
        iAPath.addLineToPoint(CGPointMake(45, 3))
        iAPath.addLineToPoint(CGPointMake(50, 7))
        iAPath.addLineToPoint(CGPointMake(52, 8))
        iAPath.addLineToPoint(CGPointMake(55, 12))
        iAPath.addLineToPoint(CGPointMake(57, 17))
        iAPath.addLineToPoint(CGPointMake(64, 25))
        iAPath.addLineToPoint(CGPointMake(67, 32))
        iAPath.addLineToPoint(CGPointMake(68, 36))
        iAPath.addLineToPoint(CGPointMake(68, 46))
        iAPath.addLineToPoint(CGPointMake(69, 48))
        iAPath.addLineToPoint(CGPointMake(69, 58))
        iAPath.addLineToPoint(CGPointMake(70, 59))
        iAPath.addLineToPoint(CGPointMake(70, 79))
        iAPath.addLineToPoint(CGPointMake(66, 82))
        iAPath.addLineToPoint(CGPointMake(58, 82))
        iAPath.addLineToPoint(CGPointMake(45, 76))
        iAPath.addLineToPoint(CGPointMake(42, 75))
        iAPath.addLineToPoint(CGPointMake(32, 70))
        iAPath.addLineToPoint(CGPointMake(24, 66))
        iAPath.addLineToPoint(CGPointMake(6, 50))
        iAPath.addLineToPoint(CGPointMake(2, 43))
        iAPath.addLineToPoint(CGPointMake(1, 40))
        //iAPath.addLineToPoint(CGPointMake(0, 36))
        iAPath.closePath()*/
        
        
        //Note - there is a stupid fuckin bug where if the player contacts on the bottom triangular edge of the irregular asteroid, the game crashes
        irregularAsteroid.physicsBody = SKPhysicsBody(texture: irregularAsteroid.texture!, alphaThreshold: 0.8, size: irregularAsteroid.size)
        

        if let physics = irregularAsteroid.physicsBody {
            
            physics.dynamic = true
            physics.affectedByGravity = false
            physics.categoryBitMask = PhysicsCategory.IrregularAsteroid //What category the irregular asteroid belongs to
            physics.contactTestBitMask = PhysicsCategory.Player //What category it interacts with
            physics.collisionBitMask = PhysicsCategory.IrregularAsteroid | PhysicsCategory.Projectile //What category bounces off of it
            physics.fieldBitMask = PhysicsCategory.PlayerGravity //What category of fields it interacts with
            physics.usesPreciseCollisionDetection = true
            physics.restitution = 0.7 //bounciness of irregular asteroid
            physics.mass = 1
        }
        
        return irregularAsteroid
    }
    
}