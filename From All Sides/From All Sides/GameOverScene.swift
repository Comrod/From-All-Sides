//
//  GameOverScene.swift
//  From All Sides
//
//  Created by Cormac Chester on 8/22/16.
//  Copyright © 2016 Cormac Chester. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
    
    var starENode = StarEmitterNode()
    
    //NSUserDefaults to store data like high score
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var recentScore = String()
    
    let scoreLabel = SKLabelNode(fontNamed:"ArialMT")
    let playAgainLabel = SKLabelNode(fontNamed: "ArialMT")
    let didYouKnowLabel = SKLabelNode(fontNamed: "ArialMT")
    let spaceFactLabel = SKLabelNode(fontNamed: "ArialMT")
    let menuLabel = SKLabelNode(fontNamed: "ArialMT")
    
    override func didMoveToView(view: SKView) {
        
        backgroundColor = SKColor.blackColor()
        createStars()
        
        recentScore = String(defaults.integerForKey("score"))
        
        //Score Label
        
        scoreLabel.text = "Final Score — " + recentScore //do not be mistaken, the dash is actually an em dash
        scoreLabel.fontSize = 75
        scoreLabel.position = CGPoint(x: size.width/2, y: (3/4)*size.height)
       
        //Play Again Label
        
        playAgainLabel.name = "playAgainLabel"
        playAgainLabel.text = "Play Again"
        playAgainLabel.fontSize = 55
        playAgainLabel.position = CGPoint(x: size.width/2, y: (5/9)*size.height)
        
        //Did You Know Label
        didYouKnowLabel.text = "Did You Know"
        didYouKnowLabel.fontSize = 35
        didYouKnowLabel.position = CGPoint(x: size.width/2, y: (7/18)*size.height)
        
        
        //Random Space Fact Label
        addSpaceFact()
        spaceFactLabel.fontSize = 30
        spaceFactLabel.position = CGPoint(x: size.width/2, y: (1/3)*size.height)
        
        //Menu Label
        
        menuLabel.name = "menuLabel"
        menuLabel.text = "Main Menu"
        menuLabel.fontSize = 55
        menuLabel.position = CGPoint(x: size.width/2, y: (1/5)*size.height)
        
        self.addChild(scoreLabel)
        self.addChild(playAgainLabel)
        self.addChild(didYouKnowLabel)
        self.addChild(spaceFactLabel)
        self.addChild(menuLabel)
        
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
    
    func addSpaceFact() {
        
        let spaceFacts = ["99.86% of the Solar System’s mass is found in the Sun", "Earth's rotation is gradually slowing", "Earth is the only planet not named after a god", "Some asteroids have moons of their own", "Asteroids are also referred to as minor planets or planetoids", "Asteroids are rich in precious metals and other metals, as well as water", "The Milky Way contains the mass of about 4.3 million Suns", "At its centre the Sun reaches temperatures of 15 million °C", "The Sun is 4.6 billion years old", "The Sun is 109 times wider than the Earth and 330,000 times as massive", "One million Earths could fit inside the Sun", "The Oort Cloud is an extended shell of icy objects that exist in the outermost reaches of the solar system", "Europa is the smallest of Jupiter’s Galilean moons", "Mars is home to the tallest mountain in the solar system (21 km high)", "Mars has the largest dust storms in the solar system", "Mars takes its name from the Roman god of war", "Pieces of Mars have fallen to Earth", "On Mars the Sun appears about half the size as it does on Earth"]
        let whichFact = Int(arc4random_uniform(UInt32(spaceFacts.count)))
        spaceFactLabel.text = spaceFacts[whichFact]
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) { //when the touch has began
        /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let touchedNode = self.nodeAtPoint(location)
            
            if let name = touchedNode.name {
                if name == "playAgainLabel" { //if play label is tapped
                }
                else if name == "menuLabel" {

                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) { //when the touch has ended
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