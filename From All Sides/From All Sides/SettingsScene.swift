//
//  SettingsScene.swift
//  From All Sides
//
//  Created by Cormac Chester on 8/22/16.
//  Copyright © 2016 Cormac Chester. All rights reserved.
//

import SpriteKit


class SettingScene: SKScene {
    
    var starX = CGFloat()
    var starY = CGFloat()
    let numOfStars = 20
    
    var defaults = NSUserDefaults.standardUserDefaults()
    
    var playerSpeed = Float()
    
    let settingsLabel = SKLabelNode(fontNamed: "ArialMT")
    let senseLabel = SKLabelNode(fontNamed: "ArialMT")
    let decreaseSenseLabel = SKLabelNode(fontNamed: "ArialMT")
    let increaseSenseLabel = SKLabelNode(fontNamed: "ArialMT")
    let backLabel = SKLabelNode(fontNamed: "ArialMT")
    
    weak var gameVC = GameViewController()
    
    override func didMoveToView(view: SKView) {
        
        //Make background
        makeBackground()
        
        playerSpeed = defaults.floatForKey("playerSpeed")
        
        //Settings Label
        settingsLabel.text = "Settings"
        settingsLabel.fontSize = 80
        settingsLabel.position = CGPoint(x:size.width/2, y:(4/5)*size.height)
        
        //Sensitivity Label
        senseLabel.text = "Tilt Sensitivity: " + String(playerSpeed)
        senseLabel.fontSize = 55
        senseLabel.position = CGPoint(x:(1/2)*size.width, y: (4/7)*size.height)

        //Decrease Sensitivity Label
        decreaseSenseLabel.name = "decSense"
        decreaseSenseLabel.text = "<—" //is actually an em dash
        decreaseSenseLabel.fontSize = 50
        decreaseSenseLabel.position = CGPoint(x:(1/3)*size.width, y: size.height/2)
        
        //Increase Sensitivity Label
        increaseSenseLabel.name = "incSense"
        increaseSenseLabel.text = "—>" //is actually an em dash
        increaseSenseLabel.fontSize = 50
        increaseSenseLabel.position = CGPoint(x:(2/3)*size.width, y: size.height/2)
        
        //Back to menu Label
        backLabel.name = "backLabel"
        backLabel.text = "Back"
        backLabel.fontSize = 55
        backLabel.position = CGPoint(x:size.width/2, y:(1/5)*size.height)
        
        self.addChild(settingsLabel)
        self.addChild(senseLabel)
        self.addChild(decreaseSenseLabel)
        self.addChild(increaseSenseLabel)
        self.addChild(backLabel)
        
        view.addSubview((gameVC?.tiltSenseSlider)!)
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
