//
//  GameMenu.swift
//  Bar Fight 1863
//
//  Created by Matthew Mohandiss on 10/26/14.
//  Copyright (c) 2014 Matthew Mohandiss. All rights reserved.
//

import SpriteKit
import GameKit

class GameMenu: SKScene {
    var playButton = Button(_text: "Play")
    var menuGameKitHelper = GameKitHelper()
    var text = SKLabelNode(text: "")
    override func didMoveToView(view: SKView) {
        let background = SKSpriteNode(imageNamed: "Title")
        background.anchorPoint = CGPointZero
        background.size = self.size
        background.position = CGPointZero
        
        
        playButton.position = CGPointMake(self.frame.midX, self.frame.midY)
        self.addChild(background)
        text.position = CGPointMake(self.frame.midX, self.frame.minY + 50)
        self.addChild(text)
        typeText()
        self.addChild(menuGameKitHelper)
        menuGameKitHelper.authenticateLocalPlayer()
        self.addChild(playButton)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            if self.containsPoint(location){
                let authProbs = menuGameKitHelper.authenticateLocalPlayer()
                if (menuGameKitHelper.localPlayer.authenticated) {
                    menuGameKitHelper.findMatch()
                } else {
                    println("Game Center is not enabled. Cannot Proceed, Goddamnit! Reason: \(authProbs)")
                }
            }
        }
    }
    
    func startGame(playerNumber: Int) {
        var scene = GameScene(size: self.size, playerNumber: playerNumber,networkingController: menuGameKitHelper)
        let skView = self.view!
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        scene.size = skView.bounds.size
        skView.presentScene(scene, transition: SKTransition.fadeWithDuration(0.5))
    }
    
    func typeText() {
        let waitTime:NSTimeInterval = 0.2
        self.text.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Center
        text.fontSize += 15
        self.runAction(SKAction.waitForDuration(waitTime), completion: {self.text.text = "B"})
        self.runAction(SKAction.waitForDuration(waitTime*2), completion: {self.text.text += "A"})
        self.runAction(SKAction.waitForDuration(waitTime*3), completion: {self.text.text += "R"})
        self.runAction(SKAction.waitForDuration(waitTime*4), completion: {self.text.text += " "})
        self.runAction(SKAction.waitForDuration(waitTime*5), completion: {self.text.text += "F"})
        self.runAction(SKAction.waitForDuration(waitTime*6), completion: {self.text.text += "I"})
        self.runAction(SKAction.waitForDuration(waitTime*7), completion: {self.text.text += "G"})
        self.runAction(SKAction.waitForDuration(waitTime*8), completion: {self.text.text += "H"})
        self.runAction(SKAction.waitForDuration(waitTime*9), completion: {self.text.text += "T"})
        self.runAction(SKAction.waitForDuration(waitTime*10), completion: {self.text.text += " "})
        self.runAction(SKAction.waitForDuration(waitTime*11), completion: {self.text.text += "1"})
        self.runAction(SKAction.waitForDuration(waitTime*12), completion: {self.text.text += "8"})
        self.runAction(SKAction.waitForDuration(waitTime*13), completion: {self.text.text += "6"})
        self.runAction(SKAction.waitForDuration(waitTime*14), completion: {self.text.text += "3"})
        
    }
}