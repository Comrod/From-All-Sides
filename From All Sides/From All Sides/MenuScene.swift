//
//  MenuScene.swift
//  From All Sides
//
//  Created by Cormac Chester on 8/20/16.
//  Copyright (c) 2016 Cormac Chester. All rights reserved.
//

import SpriteKit

class MenuScene: SKScene {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let titleLabel = SKLabelNode(fontNamed:"Chalkduster")
        titleLabel.text = "From All Sides"
        titleLabel.fontSize = 55
        titleLabel.position = CGPoint(x:size.width/2, y:(3/4)*size.height)
        
        let playLabel = SKLabelNode(fontNamed: "Chalkduster")
        playLabel.text = "Play"
        playLabel.fontSize = 40
        playLabel.position = CGPoint(x:size.width/2, y:size.height/2)
        
        self.addChild(titleLabel)
        self.addChild(playLabel)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
