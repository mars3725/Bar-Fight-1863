//
//  GameKitHelper.swift
//  Bar Fight 1863
//
//  Created by Matthew Mohandiss on 10/25/14.
//  Copyright (c) 2014 Matthew Mohandiss. All rights reserved.
//

import GameKit
import SpriteKit
@objc
class GameKitHelper: SKNode, GKMatchmakerViewControllerDelegate, GKMatchDelegate {
    var GameCenterEnabled = Bool()
    var localPlayer = getLocalPlayer()
    var match = GKMatch?()
    var players = NSArray()
    var myRandomNumber = Int()
    var lastpositionX = CGFloat()
    //Authentication
    func authenticateLocalPlayer() -> NSString {
        var returnString = "Unknown"
        localPlayer.authenticateHandler = {(_viewController : UIViewController!, error : NSError!) -> Void in
            
            if (_viewController != nil) {
                let viewController = self.scene?.view?.window?.rootViewController
                viewController?.presentViewController(_viewController, animated: true, completion: nil)
                self.GameCenterEnabled = true
                returnString = "Sucess. Player Logged in!"
                
            }
            else if (self.localPlayer.authenticated) {
                self.GameCenterEnabled = true
                returnString = "Sucess. Player Already Logged in"
            }
            else {
                self.GameCenterEnabled = false
                returnString = "Faliure. \(error.localizedDescription)"
            }
        }
        return returnString
    }
    
    //Find Match
    func findMatch() {
        let matchRequest = GKMatchRequest()
        matchRequest.minPlayers = 2
        matchRequest.maxPlayers = 2
        
        let mmvc = GKMatchmakerViewController(matchRequest: matchRequest)
        mmvc.matchmakerDelegate = self
        let viewController = self.scene?.view?.window?.rootViewController
        viewController?.presentViewController(mmvc, animated: true, completion: nil)
    }
    
    func matchmakerViewController(viewController: GKMatchmakerViewController!, didFindMatch match: GKMatch!) {
        self.scene?.view?.window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
        self.match = match
        self.match?.delegate = self
        self.players = match.players
        
        if (self.match?.expectedPlayerCount == 0) {
            println("Attempting to send random Number")
            sendRandomNumber()
        }
    }
    
    func matchmakerViewControllerWasCancelled(viewController: GKMatchmakerViewController!) {
        self.scene?.view?.window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func matchmakerViewController(viewController: GKMatchmakerViewController!, didFailWithError error: NSError!) {
        self.scene?.view?.window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
        println("finding match failed with error: \(error.code) : \(error.localizedFailureReason)")
    }
    
    //Data Transfer
    
    func match(match: GKMatch!, didReceiveData data: NSData!, fromRemotePlayer player: GKPlayer!) {
        var messageRecieved = NSKeyedUnarchiver.unarchiveObjectWithData(data) as Message
        if (self.scene != nil) {
            switch (messageRecieved.type) {
            case .RandomNumberMessage:
                let otherPlayersNumber = messageRecieved.content as Int
                println("Random Number Recieved is: \(otherPlayersNumber)")
                println("My Random Number is: \(myRandomNumber)")
                if (myRandomNumber > otherPlayersNumber) {
                    println("I am player 1")
                    let parentScene = self.scene as GameMenu
                    parentScene.startGame(0)
                } else if (myRandomNumber < otherPlayersNumber) {
                    println("I am player 2")
                    let parentScene = self.scene as GameMenu
                    parentScene.startGame(1)
                } else {
                    //try again
                    println("Random Numbers were the same. Trying again")
                    sendRandomNumber()
                }
                break
                
            case .EnemyStatusMessage:
                let otherPlayersStats = NSKeyedUnarchiver.unarchiveObjectWithData(messageRecieved.content as NSData) as? MyStats
                
                if let parentScene = self.scene as? GameScene {
                    let otherPlayer = parentScene.getOtherPlayer()
                    
                    otherPlayer.position = otherPlayersStats!.position
                    otherPlayer.physicsBody?.velocity = otherPlayersStats!.velocity
                    if (otherPlayersStats!.punching && !otherPlayer.punching) { //more animations later
                        otherPlayer.punch()
                    }
                    //            if (lastpositionX > lastpositionX) {
                    //                otherPlayer.xScale = otherPlayer.scale
                    //            } else {                                                  <-----Working on flipping image
                    //                otherPlayer.xScale = -otherPlayer.scale
                    //            }
                    lastpositionX = otherPlayer.position.x
                    
                } else {
                    println("Hmmm???")
                }
                break
                
            default:
                break
            }
        } else {
            println("Parent scene equal to nil!")
        }
        
    }
    
    func match(match: GKMatch!, didFailWithError error: NSError!) {
        println("Match Falied! Quitting. Error \(error.localizedFailureReason)")
        var scene = GameMenu(size: self.scene!.size)
        //self.skView?.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        //scene.size = skView!.bounds.size
        (self.parent as GameScene).gamekithelper.match?.disconnect()
        self.scene!.view!.presentScene(scene, transition: SKTransition.fadeWithDuration(0.5))
    }
    
    func match(match: GKMatch!, player: GKPlayer!, didChangeConnectionState state: GKPlayerConnectionState) {
        if(state == .StateUnknown || state == .StateDisconnected) {
            println("Opponents connection state unknown or disconnected. Quitting match")
            var scene = GameMenu(size: self.scene!.size)
            //self.skView?.ignoresSiblingOrder = true
            scene.scaleMode = .ResizeFill
            //scene.size = skView!.bounds.size
            (self.parent as GameScene).gamekithelper.match?.disconnect()
            if self.scene!.view != nil {
                self.scene!.view!.presentScene(scene, transition: SKTransition.fadeWithDuration(0.5))
            }
        }
    }
    
    func sendRandomNumber() {
        var messageToSend = Message(type: .RandomNumberMessage)
        myRandomNumber = messageToSend.content as Int //Keeps Number For Later Comparison
        
        let packet = NSKeyedArchiver.archivedDataWithRootObject(messageToSend)
        var error = NSErrorPointer()
        
        match?.sendDataToAllPlayers(packet, withDataMode: GKMatchSendDataMode.Reliable, error: error)
        println("data size sent: \(packet.length)")
        
        if (error != nil) {
            println("error sending Random Number: \(error.debugDescription)")
        }
    }
    
    func sendPosition() {
        var messageToSend = Message(type: .EnemyStatusMessage)
        let parentScene = self.scene as GameScene
        let player = parentScene.currentplayer
        
        if (player!.jumping) {
            let unEncodedContent = MyStats(position: player!.position, velocity: player!.physicsBody!.velocity, punching: false)
            messageToSend.content = NSKeyedArchiver.archivedDataWithRootObject(unEncodedContent)
            
        } else {
            let unEncodedContent = MyStats(position: player!.position, velocity: player!.physicsBody!.velocity, punching: player!.punching)
            messageToSend.content = NSKeyedArchiver.archivedDataWithRootObject(unEncodedContent)
        }
        
        let packet = NSKeyedArchiver.archivedDataWithRootObject(messageToSend)
        var error = NSErrorPointer()
        match?.sendDataToAllPlayers(packet, withDataMode: GKMatchSendDataMode.Unreliable, error: error)
        if (error != nil) {
            println("error sending Position: \(error.debugDescription)")
        }
    }
    
}

enum MessageType : String {
    case Default = "Default"
    case RandomNumberMessage = "RandomNumberMessage"
    case EnemyStatusMessage = "EnemyStatusMessage"
    init() {
        self = .Default
    }
}
@objc
class Message: NSObject, NSCoding {
    var type = MessageType()
    var content: AnyObject? = AnyObject?()
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(content, forKey: "content")
        aCoder.encodeObject(type.rawValue, forKey: "type")
    }
    
    required init(coder aDecoder: NSCoder) {
        content = aDecoder.decodeObjectForKey("content")
        type = MessageType(rawValue: (aDecoder.decodeObjectForKey("type") as String))!
    }
    
    init(type: MessageType) {
        switch (type) {
        case .RandomNumberMessage: // 302 Bytes
            self.type = MessageType.RandomNumberMessage
            content = Int(arc4random_uniform(1000000))
            break
            
        case .EnemyStatusMessage: //762
            self.type = MessageType.EnemyStatusMessage
            content = MyStats()
            break
            
        default:
            break
        }
    }
}
@objc
class MyStats: NSObject, NSCoding {
    var position = CGPoint()
    var punching = Bool()
    var velocity = CGVector(dx: 0,dy: 0)
    
    init(position: CGPoint, velocity: CGVector, punching: Bool) { //jumping init
        self.position = position
        self.velocity = velocity
        self.punching = punching
    }
    
    override init() {
        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeCGPoint(position, forKey: "position")
        aCoder.encodeBool(punching, forKey: "punching")
        aCoder.encodeCGVector(velocity, forKey: "velocity")
    }
    
    required init(coder aDecoder: NSCoder) {
        position = aDecoder.decodeCGPointForKey("position")
        punching = aDecoder.decodeBoolForKey("punching")
        velocity = aDecoder.decodeCGVectorForKey("velocity")
        
    }
}