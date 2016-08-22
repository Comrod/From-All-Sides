//
//  MenuScene.swift
//  From All Sides
//
//  Created by Cormac Chester on 8/20/16.
//  Copyright (c) 2016 Cormac Chester. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    
    var starX = CGFloat()
    var starY = CGFloat()
    let numOfStars = 20
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        //Make Background
        makeBackground()
        
        let titleLabel = SKLabelNode(fontNamed:"ArialMT")
        titleLabel.text = "Avoid The Asteroids"
        titleLabel.fontSize = 80
        
        titleLabel.position = CGPoint(x:size.width/2, y:(3/4)*size.height)
        
        let playLabel = SKLabelNode(fontNamed: "ArialMT")
        playLabel.name = "playLabel"
        playLabel.text = "Play"
        playLabel.fontSize = 55
        playLabel.position = CGPoint(x:size.width/2, y:(3/5)*size.height)
        
        let settingsLabel = SKLabelNode(fontNamed: "ArialMT")
        settingsLabel.name = "settingsLabel"
        settingsLabel.text = "Settings"
        settingsLabel.fontSize = 55
        settingsLabel.position = CGPoint(x:size.width/2, y:(2/5)*size.height)
        
        let highScoreLabel = SKLabelNode(fontNamed: "ArialMT")
        highScoreLabel.text = "High Score - " + String(defaults.integerForKey("highScore")) //That dash is an em dash
        highScoreLabel.fontSize = 35
        highScoreLabel.position = CGPoint(x: size.width/2, y: (1/5)*size.height)
        
        
        self.addChild(titleLabel)
        self.addChild(playLabel)
        self.addChild(settingsLabel)
        self.addChild(highScoreLabel)
    }
    
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
    
    //Add stars to the background


    //Create random number
    func randNum() -> CGFloat {
        return CGFloat(Float(arc4random())/0xFFFFFFFF)
    }
    
    
    //Create random range
    func random(min: CGFloat , max: CGFloat) -> CGFloat {
        return randNum()*(max-min)+min
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let touchedNode = self.nodeAtPoint(location)
            
            if let name = touchedNode.name {
                if name == "playLabel" { //if play label is tapped
                    print("Tapped Play")
                    
                    let transition = SKTransition.fadeWithDuration(1.0)
                    let nextScene = GameScene(size: scene!.size)
                    nextScene.scaleMode = .AspectFill
       
                    scene?.view?.presentScene(nextScene, transition: transition) //transitions to gamescene
                }
                else if name == "settingsLabel" {
                    print("Tapped Settings")
                    
                    let transition = SKTransition.fadeWithDuration(1.0)
                    let nextScene = SettingScene(size: scene!.size)
                    nextScene.scaleMode = .AspectFill
                    
                    scene?.view?.presentScene(nextScene, transition: transition) //transitions to settingsscene
                }
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
