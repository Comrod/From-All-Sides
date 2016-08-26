//
//  StarEmitterNode.swift
//  From All Sides
//
//  Created by Cormac Chester on 8/26/16.
//  Copyright © 2016 Cormac Chester. All rights reserved.
//

import Foundation
import SpriteKit

class StarEmitterNode: SKEmitterNode {
    class func starEmitter() -> StarEmitterNode {
        
        let starEmitterNode = StarEmitterNode()
        starEmitterNode.particleTexture = SKTexture(imageNamed: "star")
        starEmitterNode.particleColor = SKColor.lightGrayColor()
        starEmitterNode.particleColorBlendFactor = 1
        
        return starEmitterNode
    }
    
    func makeStarfield(color: SKColor, starSpeedY: CGFloat, starsPerSecond: CGFloat, starScaleFactor: CGFloat, frameHeight: CGFloat, frameWidth: CGFloat, screenScale: CGFloat) -> SKEmitterNode {
        let lifetime =  frameHeight * screenScale / starSpeedY
        
        // Create the emitter node
        let starEmitterNode = StarEmitterNode.starEmitter()
        starEmitterNode.particleBirthRate = starsPerSecond
        starEmitterNode.particleSpeed = starSpeedY * -1
        starEmitterNode.particleScale = starScaleFactor
        starEmitterNode.particleLifetime = lifetime
        
        // Position in the middle at top of the screen
        starEmitterNode.position = CGPoint(x: frameWidth/2, y: frameHeight)
        starEmitterNode.particlePositionRange = CGVector(dx: frameWidth, dy: 0)
        
        // Fast forward the effect to start with a filled screen
        starEmitterNode.advanceSimulationTime(NSTimeInterval(lifetime))
        
        return starEmitterNode
    }
}