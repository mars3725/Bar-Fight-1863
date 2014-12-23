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
    var playerIndex = Int()
    var currentplayer = PlayerSprite?()
    var noteText = SKLabelNode()
    var gamekithelper = GameKitHelper()
    var GameOver = false
    let sendPositionFrequency = 0.05
    let punchButton = SKSpriteNode(imageNamed: "Button")
    let punchButton2 = SKSpriteNode(imageNamed: "Button")
    override public func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        let background = SKSpriteNode(imageNamed: "Town")
        background.anchorPoint = CGPointZero
        background.size = self.size
        background.position = CGPointZero
        
        punchButton.setScale(0.2)
        punchButton.anchorPoint = CGPointZero
        punchButton.position = CGPointMake(self.frame.minX + 10, self.frame.minY + 10)
        
        punchButton2.setScale(0.2)
        punchButton2.anchorPoint = CGPointMake(1, 0)
        punchButton2.position = CGPointMake(self.frame.maxX - 10, self.frame.minY + 10)
        
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsBody?.restitution = 0
        self.physicsBody?.categoryBitMask = 1
        self.physicsBody?.friction = 0.4
        self.physicsWorld.gravity = CGVectorMake(0, -8.5)
        
        noteText.fontName = "Futura-CondensedExtraBold"
        noteText.fontColor = SKColor.redColor()
        noteText.fontSize = 60
        noteText.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMaxY(self.frame)-50)
        
        self.addChild(background)
        placePlayers()
        self.addChild(noteText)
        self.addChild(gamekithelper)
        self.addChild(punchButton)
        self.addChild(punchButton2)
        
        self.flashText("FIGHT!")
        sendPlayerStats()
        
    }
    
    override public func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            if !punchButton.containsPoint(location) && !punchButton2.containsPoint(location) {
                let location = touch.locationInNode(self)
                if location.y > self.frame.height * 0.75 {
                    currentplayer!.move("up")
                } else {
                    if location.x < self.frame.width/2 {
                        
                        currentplayer!.move("left")
                    }
                    else if location.x > self.frame.width/2 {
                        currentplayer!.move("right")
                    }
                }
            } else {
                currentplayer!.punch()
            }
        }
    }
    
    override public func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
    }
    
    override public func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        currentplayer!.move("stop")
    }
    
    override public func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if  currentplayer!.physicsBody?.velocity.dy == 0 && currentplayer!.jumping {
            currentplayer!.jumping = false
        } else if !(currentplayer!.physicsBody?.velocity.dy == 0) && !currentplayer!.jumping {
            currentplayer!.jumping = true
        }
        
        let otherPlayer = getOtherPlayer()
        
        if currentplayer?.intersectsNode(otherPlayer) == true {
            attackCheck()
        }
    }
    
    func placePlayers() {
        player1.position = CGPoint(x:CGRectGetMidX(self.frame)-100, y:CGRectGetMidY(self.frame))
        player2.position = CGPoint(x:CGRectGetMidX(self.frame)+100, y:CGRectGetMidY(self.frame))
        player2.xScale = -player2.scale
        player1.name = "player 1"
        player2.name = "player 2"
        
        playerArray.addObject(player1)
        playerArray.addObject(player2)
        
        self.addChild(player1)
        self.addChild(player2)
        
        self.currentplayer = playerArray.objectAtIndex(playerIndex) as? PlayerSprite
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
            noteText.text = "\(name) Wins!"
            enemy.die(false, hitFromDirection: direction)
        } else if enemy.punching {
            noteText.alpha = 1
            let name = currentplayer!.name!
            noteText.text = "\(name) Wins!"
            self.currentplayer!.die(false, hitFromDirection: direction)
        } else if  currentplayer!.punching && enemy.punching {
            flashText("Block")
        }
    }
    
    func getOtherPlayer() -> PlayerSprite{
        if playerIndex == 0 {
            return playerArray.objectAtIndex(1) as PlayerSprite
        } else {
            return playerArray.objectAtIndex(0) as PlayerSprite
        }
    }
    
    func flashText(text: NSString) {
        noteText.alpha = 1
        noteText.text = text
        
        self.runAction(SKAction.waitForDuration(2), completion: {
            self.noteText.runAction(SKAction.fadeOutWithDuration(1))
        })
    }
    
    convenience init(size: CGSize, playerNumber: Int, networkingController: GameKitHelper) {
        self.init(size: size)
        self.playerIndex = playerNumber
        networkingController.removeFromParent()
        self.gamekithelper = networkingController
    }
    
    func sendPlayerStats() {
        
        gamekithelper.sendPosition()
        self.runAction(SKAction.waitForDuration(sendPositionFrequency), completion: {
            if !self.GameOver {
                self.sendPlayerStats()
            }
        })
    }
}
