//
//  GameScene.swift
//  From All Sides
//
//  Created by Cormac Chester on 8/20/16.
//  Copyright © 2016 Cormac Chester. All rights reserved.
//



import SpriteKit
import CoreMotion
import UIKit
import AVFoundation

struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Player : UInt32 = 0b1
    static let Projectile: UInt32 = 0b10
    static let Comet: UInt32 = 0b11
    static let PlayerGravity: UInt32 = 0b101
}

class GameScene: SKScene, SKPhysicsContactDelegate {
   
    //Initialize MotionManager
    let motionManager: CMMotionManager = CMMotionManager()
    
    //NSUserDefaults to store data like high score
    let defaults = NSUserDefaults.standardUserDefaults()
    
    //Initialize Player
    var player = SKSpriteNode()
    var playerSpeed:CGFloat = 30
    
    var starENode = StarEmitterNode()

    //Player Radial Gravity Field
    var playerGravityField = SKFieldNode()
    var playerGravityFieldStrength: Float!
    
    var projSpawnRate: Double = 1 //The smaller the value, the more often a projectile is spawned
    var cometSpawnRate: Double = 10.0
    var difficCounter = 0 //Counter for difficulty method
    var minProjSpeed:CGFloat = 3.5 //maximum time in seconds for projectile to travel across the screen
    
    //Device Attitude Vars
    var attitudeX:CGFloat = CGFloat()
    var attitudeY:CGFloat = CGFloat()

    //Incremental variable for indicating what side a projectile will spawned
    var whatSide:UInt32 = 0
    
    //Projectile Data
    var beginX = CGFloat()
    var beginY = CGFloat()
    var impulseX = CGFloat()
    var impulseY = CGFloat()
    var angularImpulse = CGFloat()
    var mainProjImpulseMin = CGFloat()
    var mainProjImpulseMax = CGFloat()
    var projectileSpawnNode: SKNode!
    
    //Comet Stuff
    var cometSpawnNode: SKNode!
    var cometTuples: [(CometNode, SKEmitterNode)]!
    
    //Score
    var score = 0 //Counter that is incremented
    var scoreLabel: SKLabelNode!
    
    var hasBeenHit = Bool()
    
    override func didMoveToView(view: SKView) {
        
        //Prevent screen from dimming
        UIApplication.sharedApplication().idleTimerDisabled = true
        
        hasBeenHit = false
        
        //Updating player speed from settings
        playerSpeed = CGFloat(defaults.floatForKey("playerSpeed"))
        
        //Projectile Node
        projectileSpawnNode = SKNode()
        self.addChild(projectileSpawnNode)
        
        //Comet Node
        cometSpawnNode = SKNode()
        self.addChild(cometSpawnNode)
        
        
        //Physics World
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        self.physicsBody?.friction = 0
        
        backgroundColor = SKColor.blackColor()//sets background to black like the night sky
        createStars()
        
        setupScoreLabel()//Score Label Setup
        setupPlayer()//Player setup
        
        if defaults.stringForKey("easyOpt") == "easytapped" { //if easy has been selected, no gravity and pretty slow projectile speeds
            playerGravityFieldStrength = 0.0
            projSpawnRate = 1.25
            mainProjImpulseMin = 300
            mainProjImpulseMax = 500
            
        } else if defaults.stringForKey("medOpt") == "mediumtapped" { //if medium has been selected, gravity and regular projectile speeds
            projSpawnRate = 0.9
            playerGravityFieldStrength = 3.0
            setupPlayerGravityField()
            mainProjImpulseMin = 300
            mainProjImpulseMax = 600
        } else if defaults.stringForKey("hardOpt") == "lightspeedtapped" { //if lightspeed has been selected, gravity and high projectile speeds
            projSpawnRate = 0.6
            playerGravityFieldStrength = 6.0
            setupPlayerGravityField()
            mainProjImpulseMin = 600
            mainProjImpulseMax = 800
        }
        
        cometTuples = []
        
        print("player setup")
        NSTimer.scheduledTimerWithTimeInterval(0.8, target: self, selector: #selector(getDeviceAttitude), userInfo: nil, repeats: false) //Delays player movement so scene has enough time to load
        
        //Add Projectiles
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(projectileFlightCalc), SKAction.waitForDuration(projSpawnRate)])), withKey: "projectileAction")
        
        //Add Comets
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(cometFlightCalc), SKAction.waitForDuration(cometSpawnRate)])), withKey: "cometAction")
        
        
    }
    
    func createStars() {
        // Add Starfield with 3 emitterNodes for a parallax effect
        // – Stars in top layer: light, fast, big
        // – …sss
        // – Stars in back layer: dark, slow, small
        
        var starEmitterNode = starENode.makeStarfield(SKColor.lightGrayColor(), starSpeedY: 50, starsPerSecond: 0.25, starScaleFactor: 0.75, frameHeight: frame.size.height, frameWidth: frame.size.width, screenScale: UIScreen.mainScreen().scale)
        starEmitterNode.zPosition = -10
        self.addChild(starEmitterNode)
        
        starEmitterNode = starENode.makeStarfield(SKColor.grayColor(), starSpeedY: 30, starsPerSecond: 0.75, starScaleFactor: 0.5, frameHeight: frame.size.height, frameWidth: frame.size.width, screenScale: UIScreen.mainScreen().scale)
        starEmitterNode.zPosition = -11
        self.addChild(starEmitterNode)
        
        starEmitterNode = starENode.makeStarfield(SKColor.darkGrayColor(), starSpeedY: 15, starsPerSecond: 1.25, starScaleFactor: 0.25, frameHeight: frame.size.height, frameWidth: frame.size.width, screenScale: UIScreen.mainScreen().scale)
        starEmitterNode.zPosition = -12
        self.addChild(starEmitterNode)
    }
    
    
    //Setup Player
    func setupPlayer() {
        player = SKSpriteNode(imageNamed: "earth")
        player.name = "player"
        player.position = CGPoint(x: size.width/2, y: size.height/2)
        player.xScale = 2
        player.yScale = 2
        player.zPosition = 1.0
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height/2)
        player.physicsBody?.dynamic = true
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.mass = 200000
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player //What category the projectile belongs to
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile | PhysicsCategory.Comet//What category it interacts with
        player.physicsBody?.collisionBitMask = PhysicsCategory.None //What category bounces off of it
        player.physicsBody?.fieldBitMask = PhysicsCategory.None
        player.physicsBody?.linearDamping = 0
        
        self.addChild(player)
    }
    
    //Setup the Gravity Field that surrounds the player
    func setupPlayerGravityField() {
        playerGravityField = SKFieldNode.radialGravityField()
        playerGravityField.enabled = true
        playerGravityField.position = player.position
        playerGravityField.strength = playerGravityFieldStrength
        playerGravityField.falloff = 2.0
        playerGravityField.region = SKRegion(size: size) //gravity affects the entire scene
        playerGravityField.categoryBitMask = PhysicsCategory.PlayerGravity
        addChild(playerGravityField)
    }
    
    
    //Gets attitude of device
    func getDeviceAttitude() {
        if motionManager.deviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.02
            //motionManager.deviceMotionUpdateInterval = 0.014
            motionManager.startDeviceMotionUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: { (deviceMotionData, error) in
                if (error != nil) {
                    print("\(error)")
                }
                self.attitudeX = CGFloat(self.motionManager.deviceMotion!.attitude.pitch)
                self.attitudeY = CGFloat(self.motionManager.deviceMotion!.attitude.roll)
                //print("Attitude X: " + String(self.attitudeX))
                
                self.movePlayer()
            })
        }
    }
    
    //Player Motion
    func movePlayer() {
        let movePlayerAction = SKAction.moveBy(CGVectorMake(self.attitudeX*playerSpeed, self.attitudeY*playerSpeed), duration: 0.1)
        player.runAction(movePlayerAction)
        playerGravityField.position = player.position
    }
    
    
    //Setup Score Label
    func setupScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed:"Verdana-Bold")
        scoreLabel.fontColor = SKColor.orangeColor()
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: size.width/2, y: (3/4)*size.height)
        scoreLabel.fontSize = 60
        scoreLabel.color = SKColor.whiteColor()
        self.addChild(scoreLabel)
    }
    
    //Create random number
    func randNum() -> CGFloat {
        return CGFloat(Float(arc4random())/0xFFFFFFFF)
    }
    
    
    //Create random range
    func random(min: CGFloat , max: CGFloat) -> CGFloat {
        return randNum()*(max-min)+min
    }
    
    //Add Projectiles - method run for every projectile spawned
    func projectileFlightCalc() {
        
        let projectile = ProjectileNode.projectile()
        
        //Value for size of projectile
        let projSize = projectile.size.height
        
        projectile.physicsBody?.friction = 0
        
        projectileSpawnNode.addChild(projectile)
        
        //Chooses side projectile is launched from randomly
        whatSide = arc4random_uniform(4)
    
        switch whatSide {
        case 0: //Right
            beginY = random(projSize, max: size.height - projSize)
            projectile.position = CGPoint(x: size.width + projSize, y: beginY)
            impulseX = random(-mainProjImpulseMin, max: -mainProjImpulseMax)
            impulseY = random(-100, max: 100)
            break
        case 1: //Top
            beginX = random(projSize, max: size.width - projSize)
            projectile.position = CGPoint(x: beginX, y: size.height + projSize)
            impulseX = random(-100, max: 100)
            impulseY = random(-mainProjImpulseMin, max: -mainProjImpulseMax)
            break
        case 2: //Left
            beginY = random(projSize, max: size.height - projSize)
            projectile.position = CGPoint(x: -projSize, y: beginY)
            impulseX = random(mainProjImpulseMin, max: mainProjImpulseMax)
            impulseY = random(-100, max: 100)
            break
        case 3: //Bottom
            beginX = random(projSize, max: size.width - projSize)
            projectile.position = CGPoint(x: beginX, y: -projSize)
            impulseX = random(-100, max: 100)
            impulseY = random(mainProjImpulseMin, max: mainProjImpulseMax)
            break
        default:
            print("There was an error in projectile selection - restart the game")
        }

        //Makes the projectile rotate in a random direction
        angularImpulse = random(-0.05, max: 0.05)
        projectile.physicsBody?.applyAngularImpulse(angularImpulse)
        projectile.physicsBody?.applyImpulse(CGVectorMake(impulseX, impulseY))
    }
    
    //Add Projectiles - method run for every projectile spawned
    func cometFlightCalc() {
        
        print("launch comet")
        
        let comet = CometNode.comet()
        
        //Link CometTrail.sks to cometTrail
        let cometTrailPath = NSBundle.mainBundle().pathForResource("CometTrail", ofType: "sks")
        let cometTrail = NSKeyedUnarchiver.unarchiveObjectWithFile(cometTrailPath!) as! SKEmitterNode
        cometTrail.targetNode = self
        
        //Value for size of projectile
        let cometSize = comet.size.height
        
        comet.physicsBody?.friction = 0
        
        cometSpawnNode.addChild(comet)
        cometSpawnNode.addChild(cometTrail)
        
        //Chooses side projectile is launched from randomly
        whatSide = arc4random_uniform(4)
        
        
        switch whatSide {
        case 0: //Right
            beginY = random(2*cometSize, max: size.height - 2*cometSize)
            comet.position = CGPoint(x: size.width + cometSize, y: beginY)
            impulseX = random(-mainProjImpulseMin, max: -mainProjImpulseMax)
            impulseY = random(-100, max: 100)
            break
        case 1: //Top
            beginX = random(2*cometSize, max: size.width - 2*cometSize)
            comet.position = CGPoint(x: beginX, y: size.height + cometSize)
            impulseX = random(-100, max: 100)
            impulseY = random(-mainProjImpulseMin, max: -mainProjImpulseMax)
            break
        case 2: //Left
            beginY = random(2*cometSize, max: size.height - 2*cometSize)
            comet.position = CGPoint(x: -cometSize, y: beginY)
            impulseX = random(mainProjImpulseMin, max: mainProjImpulseMax)
            impulseY = random(-100, max: 100)
            break
        case 3: //Bottom
            beginX = random(2*cometSize, max: size.width - 2*cometSize)
            comet.position = CGPoint(x: beginX, y: -cometSize)
            impulseX = random(-100, max: 100)
            impulseY = random(mainProjImpulseMin, max: mainProjImpulseMax)
            break
        default:
            print("There was an error in comet selection - restart the game")
        }
        
        let cometTuple = (comet, cometTrail)
        cometTuples.append(cometTuple)
        
        //Makes the projectile rotate in a random direction
        //angularImpulse = random(-0.1, max: 0.1)
        //comet.physicsBody?.applyAngularImpulse(angularImpulse)
        comet.physicsBody?.applyImpulse(CGVectorMake(impulseX, impulseY))
    }
    
    
    //Called when two physics bodies contact eachother
    func didBeginContact(contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask { //assigns player to firstBody and projectile to secondBody
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        //Checks to see if 2 physics bodies collided
        if ((firstBody.categoryBitMask & PhysicsCategory.Player != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile | PhysicsCategory.Comet != 0)) {
            
            if hasBeenHit { //Prevents an explosion from happening twice if two projectiles/comets hit in quick succession
                
            }
            else {
                print("Hit")
                hasBeenHit = true
                
                killScene()
                explosion(player.position) //Explosion from the collision of the asteroid and the player
            }
        }
        
    }
    
    //Explosion for when player and projectile hit each other
    func explosion(position: CGPoint) {
        let explosionNode = SKEmitterNode(fileNamed: "ExplosionParticle.sks")
        explosionNode?.position = position
        self.addChild(explosionNode!)
        
        self.runAction(SKAction.waitForDuration(2.4), completion: { explosionNode!.removeFromParent() })
        self.runAction(SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)) //https://www.freesoundeffects.com/free-sounds/explosion-10070/ - explosion 3
    }
    
    //Score Counter
    func incrementScoreDiff() {

        score += 1 //Increase score
        scoreLabel.text = String(score) //Set score label to the newly increased score
        
        difficCounter += 1
        
        //Increase difficulty by decreasing the time inbetween each projectile spawn every time the score increases by 20
        if projSpawnRate > 0.1 { //Maxes out the difficulty so that it can't be decreased to zero
            if difficCounter > 20 {
                difficCounter = 0 //Reset counter
                projSpawnRate -= 0.1 //Decrease difficulty
                print("Difficulty decreased")
                
                if minProjSpeed > 1.5 {
                    minProjSpeed -= 0.1 //decrease maximum time in seconds for projectile to travel across the screen
                }
            }
        }
    }

    func killScene() {
        projectileSpawnNode.removeAllChildren() //deletes all projectiles from scene
        cometSpawnNode.removeAllChildren() //deletes everything associated with comets from scene
        //self.removeAllChildren() //deletes all children from the scene (projectiles, player, scorelabel)
        self.removeAllActions()
        motionManager.stopDeviceMotionUpdates()
        NSOperationQueue.currentQueue()!.cancelAllOperations() //May or may not need
        
        defaults.setInteger(score, forKey: "score") //Save the score
        if score > defaults.integerForKey("highScore") { //Saving new high score
            defaults.setInteger(score, forKey: "highScore")
        }
        NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: #selector(goToGameOver), userInfo: nil, repeats: false)
    }
    
    //Transition back to main menu
    func goToGameOver() {
        UIApplication.sharedApplication().idleTimerDisabled = false //Allow screen to dim when not in gamescene
        let transition = SKTransition.fadeWithDuration(0.25)
        let nextScene = GameOverScene(size: scene!.size)
        nextScene.scaleMode = .AspectFill
        scene?.view?.presentScene(nextScene, transition: transition) //transitions to menuscene
        print("Went to GameOverScene")
    }
    
    override func update(currentTime: NSTimeInterval) {
        // Loop over all nodes in the scene
        
        //Sets position of comet trail to comet
        for (comet, cometTrail) in cometTuples {
            cometTrail.position = comet.position
        }
        
        
        self.enumerateChildNodesWithName("*") {
            node, stop in
            if (node is SKSpriteNode) {
                let sprite = node as! SKSpriteNode
                // Check if the node is not in the scene
                if (sprite.position.x < (-1.5)*sprite.size.width || sprite.position.x > self.size.width + (1.5)*sprite.size.width
                    || sprite.position.y < (-1.5)*sprite.size.height || sprite.position.y > self.size.height + (1.5)*sprite.size.height) {
                    sprite.removeFromParent()
                    
                    print ("player gone off screen")
                    
                    if sprite.name == "player" { //player dies when he/she goes offscreen
                        self.killScene()
                    }
                }
            }
        }
        
        projectileSpawnNode.enumerateChildNodesWithName("*") {
            node, stop in
            if (node is SKSpriteNode) {
                let sprite = node as! SKSpriteNode
                // Check if the node is not in the scene
                if (sprite.position.x < (-1.5)*sprite.size.width || sprite.position.x > self.size.width + (1.5)*sprite.size.width
                    || sprite.position.y < (-1.5)*sprite.size.height || sprite.position.y > self.size.height + (1.5)*sprite.size.height) {
                    sprite.removeFromParent()
                    
                    
                    if sprite.name == "projectile"{
                        self.incrementScoreDiff() //increment the score and the difficulty
                    }
                }
            }
        }
        
        cometSpawnNode.enumerateChildNodesWithName("*") {
            node, stop in
            if (node is SKSpriteNode) {
                let sprite = node as! SKSpriteNode
                // Check if the node is not in the scene
                if (sprite.position.x < (-1.1)*sprite.size.width || sprite.position.x > self.size.width + (1.1)*sprite.size.width
                    || sprite.position.y < (-1.1)*sprite.size.height || sprite.position.y > self.size.height + (1.1)*sprite.size.height) {
                    sprite.removeFromParent()
                    
                    
                    if sprite.name == "comet"{
                        self.incrementScoreDiff() //increment the score and the difficulty
                    }
                }
            }
        }
        
    }

}
