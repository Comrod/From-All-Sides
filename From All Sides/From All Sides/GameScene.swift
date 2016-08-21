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
    static let Character : UInt32 = 0b1
    static let Projectile: UInt32 = 0b10
}

class GameScene: SKScene, SKPhysicsContactDelegate {
   
    //Initialize MotionManager
    var motionManager = CMMotionManager()
    
    //Initialize Player
    var player = SKSpriteNode()
    
    var difficulty = 0.5 //The smaller the value, the more often a projectile is spawned
    var difficCounter = 0 //Counter for difficulty method
    var minProjSpeed:CGFloat = 3.0 //maximum time in seconds for projectile to travel across the screen
    
    //Device Attitude Vars
    var attitudeX:CGFloat = 0.0
    var attitudeY:CGFloat = 0.0

    //Incremental variable for indicating what side a projectile will spawned
    var whatSide = 0
    
    //Projectile Locations
    var beginX = CGFloat()
    var beginY = CGFloat()
    var endX = CGFloat()
    var endY = CGFloat()
    
    //Score counter
    var score = 0
    
    
    
    override func didMoveToView(view: SKView) {
        
        //Player Setup
        setupPlayer()
        
        //Physics World
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        
        //Player Motion
        NSTimer.scheduledTimerWithTimeInterval(0.8, target: self, selector: #selector(movePlayer), userInfo: nil, repeats: false) //Delays player movement so scene has enough time to load
        
        //Add Projectiles
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(projectileFlightCalc), SKAction.waitForDuration(difficulty)])), withKey: "projectileAction")
    }
    
    //Setup Player
    func setupPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: self.frame.size.width/4, y: self.frame.size.height/2)
        player.xScale = 1
        player.yScale = 1
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height/2)
        player.physicsBody?.dynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.Character //What category the projectile belongs to
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile //What category it interacts with
        player.physicsBody?.collisionBitMask = PhysicsCategory.None //What category bounces off of it
        
        self.addChild(player)
    }
    
    //Player Motion
    func movePlayer() {
        if motionManager.deviceMotionAvailable {
            motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: { (deviceMotionData, error) in
                if (error != nil) {
                    print("\(error)")
                }
                
                self.getAttitudeData(self.motionManager.deviceMotion!.attitude)
                let moveCharacter = SKAction.moveBy(CGVectorMake(-self.attitudeX*20, -self.attitudeY*20), duration: 0.1)
                self.player.runAction(moveCharacter)
            })
        }
    }
    
    //Gets attitude (angle of rotation) of the phone
    func getAttitudeData(attitude:CMAttitude) {
        attitudeX = CGFloat(attitude.pitch)
        attitudeY = CGFloat(attitude.roll)
    }
    

    //Add Projectiles - method run for every projectile spawned
    func projectileFlightCalc() {
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.xScale = 0.5
        projectile.yScale = 0.5
        
        let projectileSpeed = NSTimeInterval(random(1.0, max: minProjSpeed)) //Chooses speed of projectile from 1
        
        //Value for size of projectile
        let projSize = projectile.size.height
        
        //Move Projectile Action
        var actionMove = SKAction()
        
        //Chooses side projectile is launched from randomly
        whatSide = Int(random(0, max: 4))
        
        if whatSide == 0{ //Right
            beginY = random(projSize, max: size.height - projSize)
            endY = random(projSize, max: size.height - projSize)
            
            projectile.position = CGPoint(x: size.width + projSize, y: beginY)
            actionMove = SKAction.moveTo(CGPoint(x: -projSize, y: endY), duration: projectileSpeed)
        }
        else if whatSide == 1{ //Top
            beginX = random(projSize, max: size.width - projSize)
            endX = random(projSize, max: size.width - projSize)
            
            projectile.position = CGPoint(x: beginX, y: size.height + projSize)
            actionMove = SKAction.moveTo(CGPoint(x: endX, y: -projSize), duration: projectileSpeed)
        }
        else if whatSide == 2{ //Left
            beginY = random(projSize, max: size.height - projSize)
            endY = random(projSize, max: size.height - projSize)
            
            projectile.position = CGPoint(x: -projSize, y: beginY)
            actionMove = SKAction.moveTo(CGPoint(x: size.width + projSize, y: endY), duration: projectileSpeed)
        }
        else if whatSide == 3{ //Bottom
            beginX = random(projSize, max: size.width - projSize)
            endX = random(projSize, max: size.width - projSize)
            
            projectile.position = CGPoint(x: beginX, y: -projSize)
            actionMove = SKAction.moveTo(CGPoint(x: endX, y: size.height + projSize), duration: projectileSpeed)

        }
        
        //Adds projectile to the scene
        addChild(projectile)
        
        //Add back when figuring out collision physics
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.height/2)
        projectile.physicsBody?.dynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile //What category the projectile belongs to
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Character //What category it interacts with
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None //What category bounces off of it
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        //let actionMove = SKAction.moveTo(CGPoint(x: -projectile.size.width/2, y: endY), duration: projectileSpeed)
        let actionMoveDone = SKAction.removeFromParent()
        //projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]), completion: {
            self.incrementScoreDiff() //Increment the score - score only increases once the projectile has passed by the entire screen
        })
        
        
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
    
    //Create random number
    func randNum() -> CGFloat {
        return CGFloat(Float(arc4random())/0xFFFFFFFF)
    }
    
    
    //Create random range
    func random(min: CGFloat , max: CGFloat) -> CGFloat {
        return randNum()*(max-min)+min
        //return CGFloat(arc4random_uniform(UInt32(max))) + min
        //return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
    }
    
    //Score Counter
    func incrementScoreDiff() {
        score += 1
        difficCounter += 1
        
        //Increase difficulty by decreasing the time inbetween each projectile spawn every time the score increases by 20
        if difficulty > 0.1 { //Maxes out the difficulty so that it can't be decreased to zero
            if difficCounter > 20 {
                difficCounter = 0 //Reset counter
                difficulty -= 0.1 //Decrease difficulty
                print("Difficulty decreased")
                
                if minProjSpeed > 1.5 {
                    minProjSpeed -= 0.1 //decrease maximum time in seconds for projectile to travel across the screen
                }
            }
        }
        
        print("Score: " + String(score))
    }
    
    //Called when the player is hit by a projectile
    func playerHitByProjectile(projectile:SKSpriteNode, character:SKSpriteNode) {
        print("Hit")
        projectile.removeFromParent()
        character.removeFromParent()
        self.removeAllChildren()
        self.removeActionForKey("projectileAction")
    }
    
    //Called when two physics bodies contact eachother
    func didBeginContact(contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        //Checks to see if 2 physics bodies collided
        if ((firstBody.categoryBitMask & PhysicsCategory.Character != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
            playerHitByProjectile(firstBody.node as! SKSpriteNode, character: secondBody.node as! SKSpriteNode)
        }
        
    }
    
    
}
