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
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        //Make Background
        makeBackground()
        
        let titleLabel = SKLabelNode(fontNamed:"AlNile-Bold")
        titleLabel.text = "Avoid The Asteroids!"
        titleLabel.fontSize = 60
        titleLabel.position = CGPoint(x:size.width/2, y:(3/4)*size.height)
        
        let playLabel = SKLabelNode(fontNamed: "AlNile-Bold")
        playLabel.name = "playLabel"
        playLabel.text = "Play"
        playLabel.fontSize = 45
        playLabel.position = CGPoint(x:size.width/2, y:size.height/2)
        
        self.addChild(titleLabel)
        self.addChild(playLabel)
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
                if name == "playLabel" { //if play label is tapped
                    print("Tapped Play")
                    
                    let transition = SKTransition.fadeWithDuration(1.0)
                    let nextScene = GameScene(size: scene!.size)
                    nextScene.scaleMode = .AspectFill
                    
                    
                    
                    scene?.view?.presentScene(nextScene, transition: transition) //transitions to gamescene
                    
                    
                }
            }

        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
