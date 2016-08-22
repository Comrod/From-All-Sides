//
//  GameOverScene.swift
//  From All Sides
//
//  Created by Cormac Chester on 8/22/16.
//  Copyright © 2016 Cormac Chester. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
    
    var starX = CGFloat()
    var starY = CGFloat()
    let numOfStars = 20
    
    //NSUserDefaults to store data like high score
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var recentScore = String()
    
    override func didMoveToView(view: SKView) {
        
        //Make Background
        makeBackground()
     
        recentScore = String(defaults.integerForKey("score"))
        
        //Score Label
        let scoreLabel = SKLabelNode(fontNamed:"ArialMT")
        scoreLabel.text = "Final Score — " + recentScore //do not be mistaken, the dash is actually an em dash
        scoreLabel.fontSize = 70
        scoreLabel.position = CGPoint(x: size.width/2, y: (3/4)*size.height)
       
        //Play Again Label
        let playAgainLabel = SKLabelNode(fontNamed: "ArialMT")
        playAgainLabel.name = "playAgainLabel"
        playAgainLabel.text = "Play Again"
        playAgainLabel.fontSize = 50
        playAgainLabel.position = CGPoint(x: size.width/2, y: (1/2)*size.height)
        
        //Menu Label
        let menuLabel = SKLabelNode(fontNamed: "ArialMT")
        menuLabel.name = "menuLabel"
        menuLabel.text = "Main Menu"
        menuLabel.fontSize = 50
        menuLabel.position = CGPoint(x: size.width/2, y: (1/4)*size.height)
        
        self.addChild(scoreLabel)
        self.addChild(playAgainLabel)
        self.addChild(menuLabel)
        
    }
    
    //Make background black with stars
    func makeBackground(){
        backgroundColor = SKColor.blackColor()//sets background to black like the night sky
        
        runAction(SKAction.repeatAction(SKAction.runBlock(addStars), count: numOfStars), withKey: "addStars")
    }
    
    //Add stars to the background
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
                if name == "playAgainLabel" { //if play label is tapped
                    print("Tapped Play Again")
                    
                    let transition = SKTransition.fadeWithDuration(1.0)
                    let nextScene = GameScene(size: scene!.size)
                    nextScene.scaleMode = .AspectFill
 
                    scene?.view?.presentScene(nextScene, transition: transition) //transitions to gamescene
    
                }
                else if name == "menuLabel" {
                    
                    let transition = SKTransition.fadeWithDuration(1.0)
                    let nextScene = MenuScene(size: scene!.size)
                    nextScene.scaleMode = .AspectFill
                    
                    scene?.view?.presentScene(nextScene, transition: transition) //transition to menuscene
                }
            }
        }
    }
    
}