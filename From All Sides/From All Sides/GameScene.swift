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
    static let Player : UInt32 = 0b1
    static let Projectile: UInt32 = 0b10
    static let PlayerGravity: UInt32 = 0b11
}

class GameScene: SKScene, SKPhysicsContactDelegate {
   
    //Initialize MotionManager
    let motionManager: CMMotionManager = CMMotionManager()
    
    //NSUserDefaults to store data like high score
    let defaults = NSUserDefaults.standardUserDefaults()
    
    //Initialize Player
    var player = SKSpriteNode()
    var playerSpeed:CGFloat = 30
    
    //Player Radial Gravity Field
    var playerGravityField = SKFieldNode()
    
    var difficulty = 0.5 //The smaller the value, the more often a projectile is spawned
    var difficCounter = 0 //Counter for difficulty method
    var minProjSpeed:CGFloat = 3.5 //maximum time in seconds for projectile to travel across the screen
    
    //Device Attitude Vars
    var attitudeX:CGFloat = CGFloat()
    var attitudeY:CGFloat = CGFloat()

    //Incremental variable for indicating what side a projectile will spawned
    var whatSide = 0
    
    //Projectile Locations
    var beginX = CGFloat()
    var beginY = CGFloat()
    var impulseX = CGFloat()
    var impulseY = CGFloat()
    
    //Star Locations
    var starX = CGFloat()
    var starY = CGFloat()
    
    //Number of Stars
    let numOfStars = 20
    
    //Score
    var score = 0 //Counter that is incremented
    var scoreLabel: SKLabelNode!
    
    //Pause Button
    var pauseButton: SKSpriteNode!
    
    override func didMoveToView(view: SKView) {
        
        playerSpeed = CGFloat(defaults.floatForKey("playerSpeed"))
        
        //Physics World
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        self.physicsBody?.friction = 0
        
        
        makeBackground()//Make the Background
        setupScoreLabel()//Score Label Setup
        setupPauseButton()//Pause Button Setup
        setupPlayer()//Player setup
        print("player setup")
        //getDeviceAttitude()//Gets attitude of device and moves player
        NSTimer.scheduledTimerWithTimeInterval(0.8, target: self, selector: #selector(getDeviceAttitude), userInfo: nil, repeats: false) //Delays player movement so scene has enough time to load
        
        
        //Add Projectiles
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(projectileFlightCalc), SKAction.waitForDuration(difficulty)])), withKey: "projectileAction")
        
        setupPlayerGravityField() //Setup the gravity field of the player
    }
    
    //Make background black with stars
    func makeBackground(){
        
        func addStars() {
            
            let star = SKSpriteNode(imageNamed: "star")
            star.xScale = 0.5
            star.yScale = 0.5
            let starSize = star.size.height
            starX = random(starSize, max: size.width - starSize)
            starY = random(starSize, max: size.height - starSize)
            
            star.position = CGPoint(x: starX, y: starY)
            star.zPosition = -1.0
            
            self.addChild(star)
        }
        
        backgroundColor = SKColor.blackColor()//sets background to black like the night sky
        
        runAction(SKAction.repeatAction(SKAction.runBlock(addStars), count: numOfStars), withKey: "addStars")
    }
    
    
    //Setup Player
    func setupPlayer() {
        player = SKSpriteNode(imageNamed: "earth")
        player.position = CGPoint(x: size.width/2, y: size.height/2)
        player.xScale = 2
        player.yScale = 2
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height/2)
        player.physicsBody?.dynamic = true
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.mass = 200000
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player //What category the projectile belongs to
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile //What category it interacts with
        player.physicsBody?.collisionBitMask = PhysicsCategory.None //What category bounces off of it
        player.physicsBody?.fieldBitMask = PhysicsCategory.None
        
        self.addChild(player)
    }
    
    func setupPlayerGravityField () {
        playerGravityField = SKFieldNode.radialGravityField()
        playerGravityField.enabled = true
        playerGravityField.position = player.position
        playerGravityField.strength = 5
        playerGravityField.falloff = 1.0
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
                print("Attitude X: " + String(self.attitudeX))
                
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
        scoreLabel = SKLabelNode(fontNamed:"ArialMT")
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: size.width/10, y: (3/4)*size.height)
        scoreLabel.fontSize = 60
        scoreLabel.color = SKColor.whiteColor()
        self.addChild(scoreLabel)
    }

    //Pause Button Setup
    func setupPauseButton() {
        pauseButton = SKSpriteNode(imageNamed: "pausebutton")
        pauseButton.position = CGPoint(x:size.width/2, y:(4/5)*size.height)
        pauseButton.zPosition = -0.5
        pauseButton.name = "pauseButton"
        self.addChild(pauseButton)
    }
    
    //Pause Scene
    func pauseScene(){
        
        if scene!.view!.paused { //if the scene is paused
            scene!.view!.paused = false
            
            getDeviceAttitude() //Restart getting device attitutde
            
            
            print("Scene is resumed")
        }
        else { //if the scene isn't paused
            scene!.view!.paused = true
            
            motionManager.stopDeviceMotionUpdates()
            NSOperationQueue.currentQueue()!.cancelAllOperations() //May or may not need
            
            /*if let action = projectile.actionForKey("projectileAction") {
                
                action.speed = 0
            }*/
            
            print("Scene is paused")
        }
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
        
        projectile.position = CGPoint (x: size.width - projSize, y: (1/2)*size.height)
        
        projectile.physicsBody?.friction = 0
        
        addChild(projectile)
        
        //projectile.physicsBody?.applyImpulse(CGVectorMake(-500, 0))
        
        //Initialize projectile
        //let projectileSpeed = NSTimeInterval(random(2.0, max: minProjSpeed)) //Chooses speed of projectile from 1
        
        //Chooses side projectile is launched from randomly
        whatSide = Int(random(0, max: 2))
    
        switch whatSide {
        case 0: //Right
            beginY = random(projSize, max: size.height - projSize)
            projectile.position = CGPoint(x: size.width + projSize, y: beginY)
            impulseX = random(-50, max: -500)
            impulseY = random(-100, max: 100)
            break
        case 1: //Top
            beginX = random(projSize, max: size.width - projSize)
            
            projectile.position = CGPoint(x: beginX, y: size.height + projSize)
            impulseX = random(-100, max: 100)
            impulseY = random(-50, max: -500)
            //actionMove = SKAction.moveTo(CGPoint(x: endX, y: -projSize), duration: projectileSpeed)
            break
        case 2: //Left
            beginY = random(projSize, max: size.height - projSize)
            
            projectile.position = CGPoint(x: -projSize, y: beginY)
            impulseX = random(50, max: 500)
            impulseY = random(-100, max: 100)
            break
        case 3: //Bottom
            beginX = random(projSize, max: size.width - projSize)
            
            projectile.position = CGPoint(x: beginX, y: -projSize)
            impulseX = random(-100, max: 100)
            impulseY = random(50, max: 500)
            break
        default:
            print("There was an error in projectile selection - restart the game")
        }

        projectile.physicsBody?.applyImpulse(CGVectorMake(impulseX, impulseY))
        
        //Add back when figuring out collision physics
        /*projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.height/2)
        projectile.physicsBody?.dynamic = true
        projectile.physicsBody?.affectedByGravity = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile //What category the projectile belongs to
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Player //What category it interacts with
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.Projectile //What category bounces off of it
        projectile.physicsBody?.fieldBitMask = PhysicsCategory.PlayerGravity //What category of fields it interacts with
        projectile.physicsBody?.usesPreciseCollisionDetection = false
        projectile.physicsBody?.restitution = 0.7 //bounciness of projectile
        projectile.physicsBody?.mass = 15*/
        
        
        /*let actionMoveDone = SKAction.removeFromParent()
        projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]), completion: {
            self.incrementScoreDiff() //Increment the score - score only increases once the projectile has passed by the entire screen
        })*/
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
        if ((firstBody.categoryBitMask & PhysicsCategory.Player != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
            playerHitByProjectile(firstBody.node as! SKSpriteNode, character: secondBody.node as! SKSpriteNode)
        }
        
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
        
        defaults.setInteger(score, forKey: "score") //Save the score
        if score > defaults.integerForKey("highScore") { //Saving new high score
            defaults.setInteger(score, forKey: "highScore")
        }
        
        
        NSTimer.scheduledTimerWithTimeInterval(1.25, target: self, selector: #selector(goToGameOver), userInfo: nil, repeats: false)

    }
    
    //Transition back to main menu
    func goToGameOver() {
        let transition = SKTransition.fadeWithDuration(0.25)
        let nextScene = GameOverScene(size: scene!.size)
        nextScene.scaleMode = .AspectFill
        scene?.view?.presentScene(nextScene, transition: transition) //transitions to menuscene
        print("Went to GameOverScene")
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let touchedNode = self.nodeAtPoint(location)
            
            if let name = touchedNode.name {
                if name == "pauseButton" { //if pause button is tapped
                    pauseScene()
                }
            }
        }
    }

}
