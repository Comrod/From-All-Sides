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
    let motionManager: CMMotionManager = CMMotionManager()
    
    //Initialize Player
    var player = SKSpriteNode()
    var playerSpeed:CGFloat = 30
    
    var difficulty = 0.5 //The smaller the value, the more often a projectile is spawned
    var difficCounter = 0 //Counter for difficulty method
    var minProjSpeed:CGFloat = 3.0 //maximum time in seconds for projectile to travel across the screen
    
    
    //Device Attitude Vars
    var attitudeX:CGFloat = CGFloat()
    var attitudeY:CGFloat = CGFloat()

    //Incremental variable for indicating what side a projectile will spawned
    var whatSide = 0
    
    //Projectile Locations
    var beginX = CGFloat()
    var beginY = CGFloat()
    var endX = CGFloat()
    var endY = CGFloat()
    
    //Score
    var score = 0 //Counter that is incremented
    var scoreLabel: SKLabelNode!
    
    
    override func didMoveToView(view: SKView) {

        
        //Physics World
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        
        setupScoreLabel()//Score Label Setup
        setupPlayer()//Player setup
        print("player setup")
        getDeviceAttitude()//Gets attitude of device and moves player
        //NSTimer.scheduledTimerWithTimeInterval(0.8, target: self, selector: #selector(getDeviceAttitude), userInfo: nil, repeats: false) //Delays player movement so scene has enough time to load
        
        
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
    
    //Gets attitude of device
    func getDeviceAttitude() {
        if motionManager.deviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.014
            motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: { (deviceMotionData, error) in
                if (error != nil) {
                    print("\(error)")
                }
                self.attitudeX = CGFloat(self.motionManager.deviceMotion!.attitude.pitch)
                self.attitudeY = CGFloat(self.motionManager.deviceMotion!.attitude.roll)
                print("Attitude X: " + String(self.attitudeX))
                
                self.movePlayer()
                
            })
        }
    }
    
    //Player Motion
    func movePlayer() {
        let movePlayerAction = SKAction.moveBy(CGVectorMake(self.attitudeX*playerSpeed, self.attitudeY*playerSpeed), duration: 0.1)
        player.runAction(movePlayerAction)
    }
    
    //Score Label
    func setupScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed:"ArialMT")
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: self.frame.size.width/10, y: (3/4)*self.frame.size.height)
        scoreLabel.fontSize = 60
        scoreLabel.color = SKColor.whiteColor()
        self.addChild(scoreLabel)
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
        
        let actionMoveDone = SKAction.removeFromParent()
        projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]), completion: {
            self.incrementScoreDiff() //Increment the score - score only increases once the projectile has passed by the entire screen
        })
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
        
        score += 1 //Increase score
        scoreLabel.text = String(score) //Set score label to the newly increased score
        
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
    }
    
    //Called when the player is hit by a projectile
    func playerHitByProjectile(projectile:SKSpriteNode, character:SKSpriteNode) {
        print("Hit")
        self.removeAllChildren() //deletes all children from the scene (projectiles, player, scorelabel)
        self.removeAllActions()
        motionManager.stopDeviceMotionUpdates()
        NSOperationQueue.currentQueue()!.cancelAllOperations() //May or may not need
        print(motionManager.deviceMotionActive)
        
        NSTimer.scheduledTimerWithTimeInterval(1.25, target: self, selector: #selector(goToMenu), userInfo: nil, repeats: false)

    }
    
    func goToMenu() {
        //Transition back to main menu
        let transition = SKTransition.fadeWithDuration(0.25)
        let nextScene = MenuScene(size: scene!.size)
        nextScene.scaleMode = .AspectFill
        scene?.view?.presentScene(nextScene, transition: transition) //transitions to menuscene
        print("Went back to MenuScene")
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
