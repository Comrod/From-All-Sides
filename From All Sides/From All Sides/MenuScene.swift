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
        let titleLabel = SKLabelNode(fontNamed:"AlNile-Bold")
        titleLabel.text = "From All Sides"
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let touchedNode = self.nodeAtPoint(location)
            
            if let name = touchedNode.name {
                if name == "playLabel" { //if play label is tapped
                    
                    let transition = SKTransition.fadeWithDuration(1.0)
                    let nextScene = GameScene(size: scene!.size)
                    nextScene.scaleMode = .AspectFill
                    
                    scene?.view?.presentScene(nextScene, transition: transition) //transitions to gamescene
                    
                    print("Tapped Play")
                }
            }

        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
