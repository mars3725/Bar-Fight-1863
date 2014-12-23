//
//  Button.swift
//  Bar Fight 1863
//
//  Created by Matthew Mohandiss on 10/26/14.
//  Copyright (c) 2014 Matthew Mohandiss. All rights reserved.
//

import SpriteKit

class Button: SKLabelNode {
    
        override init() {
            super.init()
        }
        
        override init(fontNamed fontName: String!) {
            super.init(fontNamed: fontName)
            self.text = "Hello, World!"
            self.fontSize = 65;
            self.position = CGPoint(x: 400, y: 500);
        }
        
        required init(coder aDecoder: NSCoder) {
            super.init()
        }
    
    convenience init(_text: String) {
        self.init()
        self.fontName = "Arial"
        self.fontSize = 30
        self.fontColor = SKColor.whiteColor()
        self.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        
        self.text = _text
    }
    
    func center(scene: SKScene?) {
        if scene != nil {
     self.position = CGPointMake(self.scene!.frame.midX, self.scene!.frame.midY)
        } else {
            println("Cant center Labelnode.Unknown Scene")
        }
    }
    
    override func containsPoint(p: CGPoint) -> Bool {
        let threshhold:CGFloat = 20
        var hitbox = CGRectMake(self.frame.origin.x , self.frame.origin.y, self.frame.width + threshhold, self.frame.height + threshhold)
        hitbox.offset(dx: -threshhold/2, dy: +threshhold/2)
        
        if hitbox.contains(p) {
            return true
        } else {
            return false
        }
    }
        
}
