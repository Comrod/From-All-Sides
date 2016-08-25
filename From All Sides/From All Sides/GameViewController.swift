//
//  GameViewController.swift
//  From All Sides
//
//  Created by Cormac Chester on 8/20/16.
//  Copyright (c) 2016 Cormac Chester. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    var diffSegControl: UISegmentedControl!
    
    var menuScene: MenuScene!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        diffSegControl = UISegmentedControl(items: ["Easy","Medium", "Lightspeed"])
        
        let diffSegX = (1/2)*self.view.frame.size.width - 200
        let diffSegY = (1/4)*self.view.frame.size.height
        
        diffSegControl.frame = CGRectMake(diffSegX, diffSegY, 400, 30)
        diffSegControl.selectedSegmentIndex = 1 //the middle one is selected (medium)
        diffSegControl.tintColor = UIColor.redColor()
        diffSegControl.addTarget(self, action: #selector(segmentedValueChanged), forControlEvents: .ValueChanged)

        //self.view.addSubview(diffSegControl)
        
        
        if let scene = MenuScene(fileNamed:"MenuScene") {
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            skView.backgroundColor = SKColor.blackColor()
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
            
            menuScene = scene
            scene.gameVC = self
        }
    }
    
    func segmentedValueChanged(sender:UISegmentedControl!)
    {
        print("It Works, Value is \(sender.selectedSegmentIndex)")
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
