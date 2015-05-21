//
//  PlayerSprite.swift
//  Bar Fight 1863
//
//  Created by Matthew Mohandiss on 10/5/14.
//  Copyright (c) 2014 Matthew Mohandiss. All rights reserved.
//

import SpriteKit

enum actions: String {
    case left = "left", right = "right", up = "up", punch = "punch", stop = "stop", animate = "animate"}

class PlayerSprite: SKSpriteNode {
    
    enum playerType: String {
        case Abe = "Abe", George = "George" }
    let playerSpeed: CGFloat = 200
    var punchTexture = SKTexture()
    var run = SKAction()
    let scale:CGFloat = 0.5
    var jumping = false
    var punching = false
    var defaultTexture = SKTexture()
    var jumpTexture = SKTexture()
    
    convenience init(type: playerType) {
        var initTexture = SKTextureAtlas(named: "\(type.rawValue)").textureNamed("\(type.rawValue)Run3")
        self.init(texture: initTexture, color: UIColor(), size: initTexture.size())
        
        self.setScale(scale)
        self.name = "\(type.rawValue)"
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody?.restitution = 0
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = 2
        self.physicsBody?.collisionBitMask = 1
        self.physicsBody?.contactTestBitMask = 2
        self.physicsBody?.friction = 1
        self.physicsBody?.linearDamping = 1
        
        var runTextures = [SKTexture]()
        let Atlas = SKTextureAtlas(named: "\(type.rawValue)")
        runTextures = [Atlas.textureNamed("\(type.rawValue)Run1.png"), Atlas.textureNamed("\(type.rawValue)Run2.png"), Atlas.textureNamed("\(type.rawValue)Run1.png"), Atlas.textureNamed("\(type.rawValue)Run3.png")]
        punchTexture = Atlas.textureNamed("\(type.rawValue)Punch")
        defaultTexture = Atlas.textureNamed("\(type.rawValue)Run3")
        jumpTexture = Atlas.textureNamed("\(type.rawValue)Run2")
        
        run = SKAction.repeatActionForever(SKAction.animateWithTextures(runTextures, timePerFrame: 0.1))
    }
    
    func action(action: actions) {
        switch action {
        case .left:
            let moveleft = SKAction.customActionWithDuration(0.05, actionBlock: { (node: SKNode!, CGFloat) -> Void in
                let sprite = node as! SKSpriteNode
                sprite.physicsBody?.applyForce(CGVectorMake(-self.playerSpeed, 0))
            })
            if !self.xScale.isSignMinus {
                centralGameKitHelper.sendFlipMessage()
                self.xScale = -scale
            }
            self.runAction(SKAction.repeatActionForever(moveleft), withKey: action.rawValue)
            self.runAction(run, withKey: actions.animate.rawValue)
            break
            
        case .right:
            let moveright = SKAction.customActionWithDuration(0.05, actionBlock: { (node: SKNode!, CGFloat) -> Void in
                let sprite = node as! SKSpriteNode
                sprite.physicsBody?.applyForce(CGVectorMake(self.playerSpeed, 0))
            })
            if self.xScale.isSignMinus {
                centralGameKitHelper.sendFlipMessage()
                self.xScale = scale
            }
            self.runAction(SKAction.repeatActionForever(moveright), withKey: action.rawValue)
            self.runAction(run, withKey: actions.animate.rawValue)
            break
            
        case .up:
            if  abs(self.physicsBody!.velocity.dy) < 5 {
                let velocity: CGFloat = 300/0.5
                let impluse = CGVectorMake(0, self.physicsBody!.mass * velocity)
                self.physicsBody?.applyImpulse(impluse)
                if self.physicsBody?.velocity.dx != 0 {
                    self.texture = jumpTexture
                }
            } 
            break
            
        case .punch:
            punching = true
            self.removeActionForKey(actions.animate.rawValue)
            self.texture = punchTexture
            self.runAction(SKAction.waitForDuration(0.5), completion: {
            self.punching = false
            })
            break
            
        case .stop:
            if self.physicsBody!.velocity.dx.isSignMinus {
                self.physicsBody?.applyForce(CGVectorMake(playerSpeed * 0.75, 0))
            } else {
                self.physicsBody?.applyForce(CGVectorMake(-playerSpeed * 0.75, 0))
            }
            
            self.removeActionForKey(actions.left.rawValue)
            self.removeActionForKey(actions.right.rawValue)
            self.removeActionForKey(actions.animate.rawValue)
            self.texture = defaultTexture
            
            break
            
        default:
            break
        }
    }
    
    func die(draw: Bool, hitFromDirection direction: NSString) {
        let skView = self.scene?.view
        
        self.physicsBody?.allowsRotation = true
        self.removeAllActions()
        var angle = CGFloat()
        if direction == "right" {
            angle = CGFloat(-M_PI_2)
        } else {
            angle = CGFloat(M_PI_2)
        }
        self.runAction(SKAction.rotateToAngle(CGFloat(angle), duration: 0.2, shortestUnitArc: true), completion: {
            self.runAction(SKAction.waitForDuration(2), completion: {
                var scene = GameMenu(size: self.size)
                skView?.ignoresSiblingOrder = true
                scene.scaleMode = .ResizeFill
                scene.size = skView!.bounds.size
                centralGameKitHelper.match?.disconnect()
                skView?.presentScene(scene, transition: SKTransition.fadeWithDuration(0.5))
            })
        })
    }
    
    //put new code above ------------------------------------------------ignore functions below
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: texture.size())
    }
}