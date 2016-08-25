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
    
    
    //Difficulty Options
    var easyOpt: SKSpriteNode!
    var medOpt: SKSpriteNode!
    var hardOpt: SKSpriteNode!
    
    
    //Difficulty Option Texture Strings
    var easyOptTxtStr: String!
    var medOptTxtStr: String!
    var hardOptTxtStr: String!
    
    
    weak var gameVC = GameViewController()
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        //Make Background
        makeBackground()
        
        let titleLabel = SKLabelNode(fontNamed:"ArialMT")
        titleLabel.text = "Avoid The Asteroids"
        titleLabel.fontSize = 80
        titleLabel.position = CGPoint(x:size.width/2, y:(3/4)*size.height)
        
        getDiffOptTxtStrs()
        
        print("Easy option: " + easyOptTxtStr)
        
        //Medium Option
        medOpt = SKSpriteNode(imageNamed: medOptTxtStr)
        medOpt.position = CGPoint(x:size.width/2, y: (2/3)*size.height)
        medOpt.name = "medOpt"
        medOpt.xScale = 0.25
        medOpt.yScale = 0.25
        
        //Easy Option
        easyOpt = SKSpriteNode(imageNamed: easyOptTxtStr)
        easyOpt.name = "easyOpt"
        easyOpt.position = CGPoint(x:size.width/2 - medOpt.size.width, y: (2/3)*size.height)
        easyOpt.xScale = 0.25
        easyOpt.yScale = 0.25

        //Hard Option
        hardOpt = SKSpriteNode(imageNamed: hardOptTxtStr)
        hardOpt.name = "hardOpt"
        hardOpt.position = CGPoint(x:size.width/2 + medOpt.size.width, y: (2/3)*size.height)
        hardOpt.xScale = 0.25
        hardOpt.yScale = 0.25
        
        
        let playLabel = SKLabelNode(fontNamed: "ArialMT")
        playLabel.name = "playLabel"
        playLabel.text = "Play"
        playLabel.fontSize = 55
        playLabel.position = CGPoint(x:size.width/2, y:(1/2)*size.height)
        
        let settingsLabel = SKLabelNode(fontNamed: "ArialMT")
        settingsLabel.name = "settingsLabel"
        settingsLabel.text = "Settings"
        settingsLabel.fontSize = 55
        settingsLabel.position = CGPoint(x:size.width/2, y:(1/3)*size.height)
        
        let highScoreLabel = SKLabelNode(fontNamed: "ArialMT")
        highScoreLabel.text = "High Score - " + String(defaults.integerForKey("highScore")) //That dash is an em dash
        highScoreLabel.fontSize = 35
        highScoreLabel.position = CGPoint(x: size.width/2, y: (1/5)*size.height)
        
        
        
        self.addChild(titleLabel)
        
        //Difficulty Options
        self.addChild(easyOpt)
        self.addChild(medOpt)
        self.addChild(hardOpt)
        
        self.addChild(playLabel)
        self.addChild(settingsLabel)
        self.addChild(highScoreLabel)
    }
    
    func makeBackground(){
        
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
        
        backgroundColor = SKColor.blackColor()//sets background to black like the night sky
        
        runAction(SKAction.repeatAction(SKAction.runBlock(addStars), count: numOfStars), withKey: "addStars")
    }
    
    
    func getDiffOptTxtStrs() {
        
        easyOptTxtStr = defaults.stringForKey("easyOptTxtStr")!
        medOptTxtStr = defaults.stringForKey("medOptTxtStr")!
        hardOptTxtStr = defaults.stringForKey("hardOptTxtStr")!
        //print("Easy opt" + easyOptTxtStr)
    }
    
    func setDiffOptTextures(easy: String, med: String, hard: String) {
        easyOpt.texture = SKTexture(imageNamed: easy)
        medOpt.texture = SKTexture(imageNamed: med)
        hardOpt.texture = SKTexture(imageNamed: hard)
        
        defaults.setObject(easy, forKey: "easyOptTxtStr")
        defaults.setObject(med, forKey: "medOptTxtStr")
        defaults.setObject(hard, forKey: "hardOptTxtStr")
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
                else if name == "settingsLabel" {
                    print("Tapped Settings")
                    
                    let transition = SKTransition.fadeWithDuration(1.0)
                    let nextScene = SettingScene(size: scene!.size)
                    nextScene.scaleMode = .AspectFill
                    
                    scene?.view?.presentScene(nextScene, transition: transition) //transitions to settingsscene
                }
                else if name == "easyOpt" {
                    
                    easyOptTxtStr = "easytapped"
                    medOptTxtStr = "mediumuntapped"
                    hardOptTxtStr = "lightspeeduntapped"
                    setDiffOptTextures(easyOptTxtStr, med: medOptTxtStr, hard: hardOptTxtStr)
                }
                else if name == "medOpt" {
                    easyOptTxtStr = "easyuntapped"
                    medOptTxtStr = "mediumtapped"
                    hardOptTxtStr = "lightspeeduntapped"
                    setDiffOptTextures(easyOptTxtStr, med: medOptTxtStr, hard: hardOptTxtStr)
                }
                else if name == "hardOpt" {
                    easyOptTxtStr = "easyuntapped"
                    medOptTxtStr = "mediumuntapped"
                    hardOptTxtStr = "lightspeedtapped"
                    setDiffOptTextures(easyOptTxtStr, med: medOptTxtStr, hard: hardOptTxtStr)
                    
                }
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
