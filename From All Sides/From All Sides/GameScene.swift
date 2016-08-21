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
    
    //The smaller the value, the more often a projectile is spawned
    var difficulty = 0.5

    //Incremental variable for indicating what side a projectile will spawned
    var whatSide = 0
    
    //Projectile Locations
    var beginX = CGFloat()
    var beginY = CGFloat()
    var endX = CGFloat()
    var endY = CGFloat()
    
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
        
        //Add Projectiles
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(projectileFlightCalc), SKAction.waitForDuration(difficulty)])), withKey: "projectileAction")
    }
    
    
    //Gets attitude (angle of rotation) of the phone
    func getAttitudeData(attitude:CMAttitude) {
        attitudeX = CGFloat(attitude.pitch)
        attitudeY = CGFloat(attitude.roll)
    }
    

    //Add Projectiles
    func projectileFlightCalc() {
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.xScale = 0.5
        projectile.yScale = 0.5
        
        let projectileSpeed = NSTimeInterval(random(1.5, max: 4)) //Chooses speed of projectile from 1
        
        //Value for half of size of projectile
        let projHSize = projectile.size.height/2
        
        //Move Projectile Action
        var actionMove = SKAction()
        
        if whatSide == 0{ //Right
            beginY = random(projHSize, max: size.height - projHSize)
            endY = random(projHSize, max: size.height - projHSize)
            
            projectile.position = CGPoint(x: size.width + projHSize, y: beginY)
            actionMove = SKAction.moveTo(CGPoint(x: -projHSize, y: endY), duration: projectileSpeed)
        }
        else if whatSide == 1{ //Top
            beginX = random(projHSize, max: size.width - projHSize)
            endX = random(projHSize, max: size.width - projHSize)
            
            projectile.position = CGPoint(x: beginX, y: size.height + projHSize)
            actionMove = SKAction.moveTo(CGPoint(x: endX, y: -projHSize), duration: projectileSpeed)
        }
        else if whatSide == 2{ //Left
            beginY = random(projHSize, max: size.height - projHSize)
            endY = random(projHSize, max: size.height - projHSize)
            
            projectile.position = CGPoint(x: -projHSize, y: beginY)
            actionMove = SKAction.moveTo(CGPoint(x: size.width + projHSize, y: endY), duration: projectileSpeed)
        }
        else if whatSide == 3{ //Bottom
            beginX = random(projHSize, max: size.width - projHSize)
            endX = random(projHSize, max: size.width - projHSize)
            
            projectile.position = CGPoint(x: beginX, y: -projHSize)
            actionMove = SKAction.moveTo(CGPoint(x: endX, y: size.height + projHSize), duration: projectileSpeed)

        }
        
        //Adds projectile to the scene
        addChild(projectile)
        
        //Incremental variable to change what side the projectile spawns
        if (whatSide < 3) {
            whatSide += 1
        }
        else {
            whatSide = 0 //Reset whatSide counter
        }
        
        
        
        
        //Add back when figuring out collision physics
        /*projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.height/2)
        projectile.physicsBody?.dynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile //What category the projectile belongs to
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Character //What category it interacts with
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None //What category bounces off of it
        projectile.physicsBody?.usesPreciseCollisionDetection = true*/
        
        //let actionMove = SKAction.moveTo(CGPoint(x: -projectile.size.width/2, y: endY), duration: projectileSpeed)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
        
        
        /*let lowerX = Int(projectile.size.width)
        let upperX = Int(size.width)
        let randX = CGFloat(randRange(lowerX, upper: upperX))
        
        let lowerY = Int(projectile.size.height)
        let upperY = Int(size.height)
        let randY = CGFloat(randRange(lowerY, upper: upperY))
        
        
        let whichSide = Int(arc4random_uniform(UInt32(4)))
        print("Which side: " + String(whichSide))
        
        //Top
        if whichSide == 0 {
            
            //Starting Coordinates
            startX = randX
            startY = size.height + projectile.size.height
            
            //Ending Coordinates
            endX = randX //will change later so flight path is diagonal
            endY = -projectile.size.height
            print("top")
        }
            //Right
        else if whichSide == 1 {
            
            startX = size.width + projectile.size.width
            startY = randY
            
            endX = -projectile.size.width
            endY = randY //will change later so flight path is diagonal
            print("right")
        }
            //Bottom
        else if whichSide == 2 {
            
            startX = randX
            startY = -projectile.size.height
            
            endX = randX //will change later so flight path is diagonal
            endY = size.height + projectile.size.height
            print("bottom")
        }
            //Left
        else if whichSide == 3 {
            
            startX = -projectile.size.width
            startY = randY
            
            endX = size.width + projectile.size.width
            endY = randY //will change later so flight path is diagonal
            print("left")
        }
        
        print("endx1")
        print(endX)
        
        projectile.position = CGPointMake(startX, startY)
        print("Start position:")
        print(projectile.position)*/
        
    }
    
    func randNum() -> CGFloat {
        return CGFloat(Float(arc4random())/0xFFFFFFFF)
    }
    
    
    //Create random range
    func random(min: CGFloat , max: CGFloat) -> CGFloat {
        return randNum()*(max-min)+min
        //return CGFloat(arc4random_uniform(UInt32(max))) + min
        //return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
    
}
