//
//  GameScene.swift
//  From All Sides
//
//  Created by Cormac Chester on 8/20/16.
//  Copyright © 2016 Cormac Chester. All rights reserved.
//

import SpriteKit
import CoreMotion

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Character : UInt32 = 0b1       // 1
    static let Projectile: UInt32 = 0b10      // 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
   
    //Initialize Player
    var player = SKSpriteNode()
    
    //Initialize MotionManager
    var motionManager = CMMotionManager()
    
    //Device Attitude Vars
    var attitudeX:CGFloat = 0.0
    var attitudeY: CGFloat = 0.0
    
    
    override func didMoveToView(view: SKView) {
        
        //Player Setup
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPointMake(CGRectGetMidX(self.frame)/2, CGRectGetMidY(self.frame))
        player.xScale = 1
        player.yScale = 1
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height/2)
        player.physicsBody?.dynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.Character //What category the projectile belongs to
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile //What category it interacts with
        player.physicsBody?.collisionBitMask = PhysicsCategory.None //What category bounces off of it
        
        self.addChild(player)

        //Physics World
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        //Character Motion
        if motionManager.deviceMotionAvailable {
            motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: { (deviceMotionData, error) in
                if (error != nil) {
                    print("\(error)")
                }
                
                self.getAttitudeData(self.motionManager.deviceMotion!.attitude)
                let moveCharacter = SKAction.moveBy(CGVectorMake(-self.attitudeX*10, -self.attitudeY*10), duration: 0.1)
                self.player.runAction(moveCharacter)
            })
        }
    }
    
    func getAttitudeData(attitude:CMAttitude) {
        attitudeX = CGFloat(attitude.pitch)
        attitudeY = CGFloat(attitude.roll)
    }
    
    
}
