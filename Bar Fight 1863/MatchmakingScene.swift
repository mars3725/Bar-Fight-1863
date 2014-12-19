//
//  MatchmakingScene.swift
//  Bar Fight 1863
//
//  Created by Matthew Mohandiss on 10/29/14.
//  Copyright (c) 2014 Matthew Mohandiss. All rights reserved.
//

import SpriteKit
import GameKit

class MatchmakingScene: SKScene {
    var matchRequest = GKMatchRequest()
    
    override func didMoveToView(view: SKView) {
        
        matchRequest.minPlayers = 2
        matchRequest.maxPlayers = 2
        
        let mmvc = GKMatchmakerViewController()
        let viewController = self.view?.window?.rootViewController
        viewController?.presentViewController(mmvc, animated: true, completion: nil)
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
                }
    }
    
}
