//
//  SettingsScene.swift
//  From All Sides
//
//  Created by Cormac Chester on 8/22/16.
//  Copyright © 2016 Cormac Chester. All rights reserved.
//

import SpriteKit
import UIKit

class SettingScene: SKScene {
    
    var starENode = StarEmitterNode()
    
    var defaults = NSUserDefaults.standardUserDefaults()
    
    var playerSpeed = Float()
    
    let rawLandscapeLeft = UIInterfaceOrientation.LandscapeLeft.rawValue
    let rawLandscapeRight = UIInterfaceOrientation.LandscapeRight.rawValue
    
    let settingsLabel = SKLabelNode(fontNamed: "Verdana-Bold")
    let senseLabel = SKLabelNode(fontNamed: "Verdana-Bold")
    let decreaseSenseLabel = SKLabelNode(fontNamed: "Verdana-Bold")
    let increaseSenseLabel = SKLabelNode(fontNamed: "Verdana-Bold")
    let backLabel = SKLabelNode(fontNamed: "Verdana-Bold")
    
    override func didMoveToView(view: SKView) {
        
        backgroundColor = SKColor.blackColor()//sets background to black like the night sky
        createStars()
        
        playerSpeed = defaults.floatForKey("playerSpeed")
        
        //Settings Label
        settingsLabel.text = "Settings"
        settingsLabel.fontColor = SKColor.orangeColor()
        settingsLabel.fontSize = 80
        settingsLabel.position = CGPoint(x:size.width/2, y:(3/4)*size.height)
        
        //Sensitivity Label
        senseLabel.text = "Tilt Sensitivity: " + String(playerSpeed)
        senseLabel.fontColor = SKColor.orangeColor()
        senseLabel.fontSize = 55
        senseLabel.position = CGPoint(x:(1/2)*size.width, y: (4/7)*size.height)

        //Decrease Sensitivity Label
        decreaseSenseLabel.name = "decSense"
        decreaseSenseLabel.fontColor = SKColor.orangeColor()
        decreaseSenseLabel.text = "<—" //is actually an em dash
        decreaseSenseLabel.fontSize = 50
        decreaseSenseLabel.position = CGPoint(x:(1/3)*size.width, y: size.height/2)
        
        //Increase Sensitivity Label
        increaseSenseLabel.name = "incSense"
        increaseSenseLabel.fontColor = SKColor.orangeColor()
        increaseSenseLabel.text = "—>" //is actually an em dash
        increaseSenseLabel.fontSize = 50
        increaseSenseLabel.position = CGPoint(x:(2/3)*size.width, y: size.height/2)
        
        //Back to menu Label
        backLabel.name = "backLabel"
        backLabel.fontColor = SKColor.orangeColor()
        backLabel.text = "Back"
        backLabel.fontSize = 55
        backLabel.position = CGPoint(x:size.width/2, y:(1/5)*size.height)
        
        self.addChild(settingsLabel)
        self.addChild(senseLabel)
        self.addChild(decreaseSenseLabel)
        self.addChild(increaseSenseLabel)
        self.addChild(backLabel)
    
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let touchedNode = self.nodeAtPoint(location)
            
            if let name = touchedNode.name {
                if name == "backLabel" { //if play label is tapped
                    print("Tapped Back")
                    
                    let transition = SKTransition.fadeWithDuration(1.0)
                    let nextScene = MenuScene(size: scene!.size)
                    nextScene.scaleMode = .AspectFill
                    
                    scene?.view?.presentScene(nextScene, transition: transition) //transitions to menuscene
                    
                }
                else if name == "decSense" { //decrease sensitivity label is tapped
                    playerSpeed -= 2
                    defaults.setFloat(playerSpeed, forKey: "playerSpeed")
                    senseLabel.text = "Tilt Sensitivity: " + String(playerSpeed)
                    print(playerSpeed)
                }
                else if name == "incSense" { //increase sensitivity label is tapped
                    playerSpeed += 2
                    defaults.setFloat(playerSpeed, forKey: "playerSpeed")
                    senseLabel.text = "Tilt Sensitivity: " + String(playerSpeed)
                    print(playerSpeed)
                }
            }
        }
    }
}
