//
//  GameScene.swift
//  Bar Fight 1863
//
//  Created by Matthew Mohandiss on 10/5/14.
//  Copyright (c) 2014 Matthew Mohandiss. All rights reserved.
//

import SpriteKit

@objc(GameScene)
public class GameScene: SKScene {
    var player1 = PlayerSprite(type: PlayerSprite.playerType.Abe)
    var player2 = PlayerSprite(type: PlayerSprite.playerType.George)
    var playerArray = NSMutableArray(capacity: 2)
    var currentplayer = PlayerSprite?()
    var noteText = SKLabelNode()
    var GameOver = false
    let sendPositionFrequency = 0.05
    let punchButton = SKSpriteNode(imageNamed: "Button")
    let punchButton2 = SKSpriteNode(imageNamed: "Button")
    var myNameLabel = SKLabelNode()
    var enemyNameLabel = SKLabelNode()
    var crowd = SKSpriteNode(imageNamed: "Crowd1")
    
    override public func didMoveToView(view: SKView) {
        /* Setup your scene here */
        centralGameKitHelper.baseScene = self
        
        let background = SKSpriteNode(imageNamed: "Background")
        background.anchorPoint = CGPointZero
        background.size = self.size
        background.position = CGPointZero
        background.zPosition = -1
        
        let stage = SKSpriteNode(color: SKColor.brownColor(), size: CGSizeMake(400, 25))
        stage.colorBlendFactor = 1
        stage.position = CGPointMake(self.frame.midX, self.frame.minY + 30)
        stage.physicsBody = SKPhysicsBody(rectangleOfSize: stage.size)
        stage.physicsBody?.categoryBitMask = 1
        stage.physicsBody?.restitution = 0
        stage.physicsBody?.density = 1.5
        stage.physicsBody?.allowsRotation = false
        
        crowd.setScale(0.4)
        crowd.position = CGPointMake(self.frame.minX, self.frame.minY)
        crowd.anchorPoint = CGPointZero
        crowd.zPosition = 1
        
        punchButton.setScale(0.2)
        punchButton.anchorPoint = CGPointZero
        punchButton.position = CGPointMake(self.frame.minX + 10, self.frame.minY + 10)
        punchButton.zPosition = 2
        
        punchButton2.setScale(0.2)
        punchButton2.anchorPoint = CGPointMake(1, 0)
        punchButton2.position = CGPointMake(self.frame.maxX - 10, self.frame.minY + 10)
        punchButton2.zPosition = 2
        
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody?.restitution = 0
        self.physicsBody?.categoryBitMask = 1
        self.physicsBody?.friction = 0.4
        self.physicsWorld.gravity = CGVectorMake(0, -8.5)
        
        noteText.fontName = "Futura-CondensedExtraBold"
        noteText.fontColor = SKColor.redColor()
        noteText.fontSize = 60
        noteText.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMaxY(self.frame)-50)
        noteText.zPosition = 2
        
        self.addChild(background)
        self.addChild(stage)
        //self.addChild(crowd)
        placePlayers()
        self.addChild(noteText)
        self.addChild(punchButton)
        self.addChild(punchButton2)
        
        self.flashText("FIGHT!")
        sendPlayerStats()
        animateCrowd()
    }
    
    func animateCrowd() {
        let action = SKAction.customActionWithDuration(0.05, actionBlock: { (node: SKNode!, CGFloat) -> Void in
            if self.crowd.texture == SKTexture(imageNamed: "Crowd1") {
                self.crowd.texture = SKTexture(imageNamed: "Crowd2")
            } else {
                self.crowd.texture = SKTexture(imageNamed: "Crowd1")
            }
        })
        self.runAction(SKAction.waitForDuration(4, withRange: 2), completion: {
        action
        self.animateCrowd()})
    }
    
    override public func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            if !punchButton.containsPoint(location) && !punchButton2.containsPoint(location) {
                if location.y > self.frame.height * 0.6 {
                    currentplayer!.action(actions.up)
                } else {
                    if location.x < self.frame.width/2 {
                        currentplayer!.action(actions.left)
                    }
                    else if location.x > self.frame.width/2 {
                        currentplayer!.action(actions.right)
                    }
                }
            } else {
                centralGameKitHelper.sendPunchMessage()
                currentplayer!.action(actions.punch)
                
                crowd.texture = SKTexture(imageNamed: "CrowdCheer")
                self.runAction(SKAction.waitForDuration(1), completion: {
                    self.crowd.texture = SKTexture(imageNamed: "Crowd1")
                })
            }
        }
    }
    
    override public func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        currentplayer!.action(actions.stop)
    }
    
    override public func update(currentTime: CFTimeInterval) {
        
        if currentplayer?.intersectsNode(getOtherPlayer()) == true {
            attackCheck()
        }
        myNameLabel.position = CGPointMake(currentplayer!.position.x, currentplayer!.frame.maxY + 10)
        enemyNameLabel.position = CGPointMake(getOtherPlayer().position.x, getOtherPlayer().frame.maxY + 10)
    }
    
    func placePlayers() {
        player1.position = CGPoint(x:CGRectGetMidX(self.frame)-100, y:CGRectGetMidY(self.frame))
        player2.position = CGPoint(x:CGRectGetMidX(self.frame)+100, y:CGRectGetMidY(self.frame))
        player2.xScale = -player2.scale
        
        playerArray.addObject(player1)
        playerArray.addObject(player2)
        
        self.addChild(player1)
        self.addChild(player2)
        
        if centralGameKitHelper.player1 {
            self.currentplayer = (playerArray.objectAtIndex(0) as! PlayerSprite)
        } else {
            self.currentplayer = (playerArray.objectAtIndex(1) as! PlayerSprite)
        }
        
        myNameLabel.text = centralGameKitHelper.localPlayer.displayName
        myNameLabel.fontSize = 16
        enemyNameLabel.text = centralGameKitHelper.getOtherPlayerAlias()
        enemyNameLabel.fontSize = 16
        myNameLabel.position = CGPointMake(currentplayer!.position.x, currentplayer!.frame.maxY + 10)
        enemyNameLabel.position = CGPointMake(getOtherPlayer().position.x, getOtherPlayer().frame.maxY + 10)
        self.addChild(myNameLabel)
        self.addChild(enemyNameLabel)
        
        self.runAction(SKAction.waitForDuration(2), completion: {
            self.myNameLabel.runAction(SKAction.fadeAlphaTo(0, duration: 0.3), completion: {self.removeFromParent()})
            self.enemyNameLabel.runAction(SKAction.fadeAlphaTo(0, duration: 0.3), completion: {self.removeFromParent()})
        })
    }
    
    func attackCheck() {
        let enemy = getOtherPlayer()
        var direction = NSString()
        
        if (currentplayer!.position.x - enemy.position.x).isSignMinus {
            direction = "right"
        } else {
            direction = "left"
        }
        
        if currentplayer!.punching {
            noteText.alpha = 1
            let name = enemy.name!
            noteText.text = "\(myNameLabel) Wins!"
            enemy.die(false, hitFromDirection: direction)
        } else if enemy.punching {
            noteText.alpha = 1
            let name = currentplayer!.name!
            noteText.text = "\(enemyNameLabel) Wins!"
            self.currentplayer!.die(false, hitFromDirection: direction)
        } else if  currentplayer!.punching && enemy.punching {
            flashText("Block")
        }
    }
    
    func getOtherPlayer() -> PlayerSprite{
        if centralGameKitHelper.player1 {
            return playerArray.objectAtIndex(1) as! PlayerSprite
        } else {
            return playerArray.objectAtIndex(0) as! PlayerSprite
        }
    }
    
    func flashText(text: NSString) {
        noteText.alpha = 1
        noteText.text = text as String //maybe text should be a string?
        
        self.runAction(SKAction.waitForDuration(2.5), completion: {
            self.noteText.runAction(SKAction.fadeOutWithDuration(1))
        })
    }
    
    func sendPlayerStats() {
        if currentplayer!.physicsBody?.velocity.dx != 0 {
            centralGameKitHelper.sendPosition()
        }
        self.runAction(SKAction.waitForDuration(sendPositionFrequency), completion: {
            if !self.GameOver {
                self.sendPlayerStats()
            }
        })
    }
}
