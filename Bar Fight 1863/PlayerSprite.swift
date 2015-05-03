//
//  PlayerSprite.swift
//  Bar Fight 1863
//
//  Created by Matthew Mohandiss on 10/5/14.
//  Copyright (c) 2014 Matthew Mohandiss. All rights reserved.
//

import SpriteKit

class PlayerSprite: SKSpriteNode {
    
    enum playerType: Int {
        case Abe = 1, George }
    let playerSpeed: CGFloat = 180
    var PunchTextures = [SKTexture]()
    var idle = SKAction()
    let scale:CGFloat = 1.5
    var jumping = false
    var punching = false
    var animationState = String()
    
    convenience init(type: playerType) {
        var initTexture = SKTexture()
        
        switch type {
        case playerType.Abe:
            initTexture = SKTexture(imageNamed: "Abe_Punch_1")
            break
        case playerType.George:
            initTexture = SKTexture(imageNamed: "george") //George_Punch_1
            break
        default:
            break
        } //sets initial texture
        
        self.init(texture: initTexture, color: UIColor(), size: CGSize())
        setProperties(type)
    }
    
    func move(direction: NSString) {
        switch direction {
        case "left":
            
            let moveleft = SKAction.customActionWithDuration(0.05, actionBlock: { (node: SKNode!, CGFloat) -> Void in
                let sprite = node as! SKSpriteNode
                sprite.physicsBody?.applyForce(CGVectorMake(-self.playerSpeed, 0))
            })
            if !self.xScale.isSignMinus {
                (self.scene as! GameScene).gamekithelper.sendFlipMessage()
                self.xScale = -scale
            }
            self.runAction(SKAction.repeatActionForever(moveleft), withKey: "move left")
            break
        case "right":
            let moveright = SKAction.customActionWithDuration(0.05, actionBlock: { (node: SKNode!, CGFloat) -> Void in
                let sprite = node as! SKSpriteNode
                sprite.physicsBody?.applyForce(CGVectorMake(self.playerSpeed, 0))
            })
            if self.xScale.isSignMinus {
                (self.scene as! GameScene).gamekithelper.sendFlipMessage()
                self.xScale = scale
            }
            self.runAction(SKAction.repeatActionForever(moveright), withKey: "move right")
            break
        case "up":
            if !jumping {
                self.physicsBody?.applyImpulse(CGVectorMake(0, 100))
                jumping = true
            }
            break
        case "stop":
            self.removeActionForKey("move left")
            self.removeActionForKey("move right")
            break
        default:
            break
        }
    }
    
    func setProperties(type: playerType) {
        self.setScale(scale)
        self.name = "\(type.hashValue)"
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size)
        self.physicsBody?.restitution = 0
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.categoryBitMask = 2
        self.physicsBody?.collisionBitMask = 1
        self.physicsBody?.contactTestBitMask = 2
        self.physicsBody?.friction = 1
        //Animate(type)
    }
    
    func Animate(type: playerType) {
        
        var idleTextures = [SKTexture]()
        var Atlas = SKTextureAtlas()
        switch type {
        case playerType.Abe:
            Atlas = SKTextureAtlas(named: "Abe")
            idleTextures = [Atlas.textureNamed("Idle1.png"), Atlas.textureNamed("Idle2.png"), Atlas.textureNamed("Idle3.png"), Atlas.textureNamed("Idle4.png")]
            PunchTextures = [SKTexture(imageNamed: "Abe_Punch_1"), SKTexture(imageNamed: "Abe_Punch_2")]
            break
        case playerType.George:
            Atlas = SKTextureAtlas(named: "George")
            idleTextures = [Atlas.textureNamed("Idle1.png"), Atlas.textureNamed("Idle2.png"), Atlas.textureNamed("Idle3.png"), Atlas.textureNamed("Idle4.png")]
            PunchTextures = [SKTexture(imageNamed: "George_Punch_1"), SKTexture(imageNamed: "George_Punch_2")]
            break
        default:
            break
        } //load texture atlases and setup texture arrays (idle & punch)
        
        idle = SKAction.animateWithTextures(idleTextures, timePerFrame: 0.2)
        animationState = "idle"
        self.runAction(SKAction.repeatActionForever(idle), withKey: "idle")
    }
    
    func punch() {
        
        punching = true
        animationState = "punching"
        var punchVar = Int(arc4random_uniform(UInt32(PunchTextures.count)))
        let punchtextureArray = NSArray(array: PunchTextures)
        
        self.removeActionForKey("idle")
        self.texture = punchtextureArray.firstObject as? SKTexture //replace firstObject with objectAtIndex(punchVar)
        self.runAction(SKAction.waitForDuration(0.5), completion: {
            self.runAction(SKAction.repeatActionForever(self.idle), withKey: "idle")
            self.punching = false
        })
    }
    
    func die(draw: Bool, hitFromDirection direction: NSString) {
        let skView = self.scene?.view
        
        self.physicsBody?.allowsRotation = true
        self.removeActionForKey("idle")
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
                (self.parent as! GameScene).gamekithelper.match?.disconnect()
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