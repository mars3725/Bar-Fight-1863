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
    var player1 = Bool()
    var baseScene = SKScene()
    func getOtherPlayerAlias()->String {
        if match?.players.first?.player == localPlayer.playerID {
            return match!.players.last!.displayName!!
        } else if match?.players.first?.player != localPlayer.playerID {
            return match!.players.first!.displayName!!
        } else {
            println("Could not fetch other player's alias")
            return "Error"
        }
    }
    //Authentication
    func authenticateLocalPlayer(){
        localPlayer.authenticateHandler = {(_viewController : UIViewController!, error : NSError!) -> Void in
            
            if _viewController != nil {
                self.baseScene.view?.window?.rootViewController?.presentViewController(_viewController, animated: true, completion: nil)
                self.GameCenterEnabled = true
            }
            else if self.localPlayer.authenticated {
                self.GameCenterEnabled = true
            }
            else {
                self.GameCenterEnabled = false
            }
        }
    }
    
    //Find Match
    func findMatch() {
        let matchRequest = GKMatchRequest()
        matchRequest.minPlayers = 2
        matchRequest.maxPlayers = 2
        
        let mmvc = GKMatchmakerViewController(matchRequest: matchRequest)
        mmvc.matchmakerDelegate = self
        baseScene.view?.window?.rootViewController?.presentViewController(mmvc, animated: true, completion: nil)
    }
    
    func matchmakerViewController(viewController: GKMatchmakerViewController!, didFindMatch match: GKMatch!) {
        self.match = match
        self.match?.delegate = self
        self.match?.delegate
        self.players = match.players
        
        if self.match?.expectedPlayerCount == 0 {
            println("Attempting to send random Number")
            sendRandomNumber()
            baseScene.view?.window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func matchmakerViewControllerWasCancelled(viewController: GKMatchmakerViewController!) {
        baseScene.view?.window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func matchmakerViewController(viewController: GKMatchmakerViewController!, didFailWithError error: NSError!) {
        baseScene.view?.window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
        println("finding match failed with error: \(error.code) : \(error.localizedFailureReason)")
    }
    
    //Data Transfer
    
    func match(match: GKMatch!, didReceiveData data: NSData!, fromRemotePlayer player: GKPlayer!) {
        var messageRecieved = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! Message
        switch messageRecieved.type {
        case .RandomNumberMessage:
            let otherPlayersNumber = messageRecieved.content as! Int
            println("Other Player's Random Number is: \(otherPlayersNumber)")
            println("My Random Number is: \(myRandomNumber)")
            if myRandomNumber > otherPlayersNumber {
                println("I am player 1")
                player1 = true
                let parentScene = baseScene as! GameMenu
                parentScene.startGame()
            } else if myRandomNumber < otherPlayersNumber {
                println("I am player 2")
                player1 = false
                let parentScene = baseScene as! GameMenu
                parentScene.startGame()
            } else {
                //try again
                println("Random Numbers were the same. Trying again")
                sendRandomNumber()
            }
            break
            
        case .XPositionMessage:
            let otherPlayersStats = NSKeyedUnarchiver.unarchiveObjectWithData(messageRecieved.content as! NSData) as? MyPositionInfo
            
            if let parentScene = baseScene as? GameScene {
                let otherPlayer = parentScene.getOtherPlayer()
                
                otherPlayer.position.x = CGFloat(otherPlayersStats!.position)
                otherPlayer.physicsBody!.velocity.dx = CGFloat(otherPlayersStats!.velocity)
                otherPlayer.action(.animate)
            }
            break
        case .SpecialMessage:
            if let parentScene = baseScene as? GameScene {
                let otherPlayer = parentScene.getOtherPlayer()
                switch messageRecieved.content as! String {
                case "Flip":
                    if otherPlayer.xScale.isSignMinus {
                        otherPlayer.xScale = otherPlayer.scale
                    } else if !otherPlayer.xScale.isSignMinus {
                        otherPlayer.xScale = -otherPlayer.scale
                    }
                    
                case "Punch":
                    otherPlayer.action(.punch)
                    break
                case "Jump":
                    otherPlayer.action(.up)
                    break
                default:
                    break
                }
            }
            
        default:
            break
        }
    }
    
    func match(match: GKMatch!, didFailWithError error: NSError!) {
        println("Match Falied! Quitting. Error \(error.localizedFailureReason)")
        var scene = GameMenu(size: baseScene.size)
        //self.skView?.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        //scene.size = skView!.bounds.size
        centralGameKitHelper.match?.disconnect()
        baseScene.view!.presentScene(scene, transition: SKTransition.fadeWithDuration(0.5))
    }
    
    func match(match: GKMatch!, player: GKPlayer!, didChangeConnectionState state: GKPlayerConnectionState) {
        if state == .StateUnknown || state == .StateDisconnected {
            leaveMatch()
        }
    }
    
    func leaveMatch() {
        var scene = GameMenu(size: baseScene.size)
        scene.scaleMode = .ResizeFill
        centralGameKitHelper.match?.disconnect()
        baseScene.view!.presentScene(scene, transition: SKTransition.fadeWithDuration(0.5))
    }
    
    func sendRandomNumber() {
        var messageToSend = Message(type: .RandomNumberMessage)
        myRandomNumber = messageToSend.content as! Int //Keeps Number For Later Comparison
        
        let packet = NSKeyedArchiver.archivedDataWithRootObject(messageToSend)
        var error = NSErrorPointer()
        
        match?.sendDataToAllPlayers(packet, withDataMode: GKMatchSendDataMode.Reliable, error: error)
        println("data size sent: \(packet.length)")
        
        if error != nil {
            println("error sending Random Number: \(error.debugDescription)")
        }
    }
    
    func sendPosition() {
        var messageToSend = Message(type: .XPositionMessage)
        if let parentScene = baseScene as? GameScene {
            
            let unEncodedContent = MyPositionInfo(xPosition: parentScene.currentplayer!.position.x, xVelocity: parentScene.currentplayer!.physicsBody!.velocity.dx)
            messageToSend.content = NSKeyedArchiver.archivedDataWithRootObject(unEncodedContent)
            
            let packet = NSKeyedArchiver.archivedDataWithRootObject(messageToSend)
            var error = NSErrorPointer()
            
                match?.sendDataToAllPlayers(packet, withDataMode: GKMatchSendDataMode.Unreliable, error: error)
            if error != nil {
                println("error sending Position: \(error.debugDescription)")
            }
        }
    }
    
    func sendFlipMessage() {
        let message = Message(type: .SpecialMessage)
        message.content = "Flip"
        let packet = NSKeyedArchiver.archivedDataWithRootObject(message)
        var error = NSErrorPointer()
        match?.sendDataToAllPlayers(packet, withDataMode: GKMatchSendDataMode.Reliable, error: error)
        if error != nil {
            println("error sending Flip Message: \(error.debugDescription)")
        }
    }
    
    func sendPunchMessage() {
        let message = Message(type: .SpecialMessage)
        message.content = "Punch"
        let packet = NSKeyedArchiver.archivedDataWithRootObject(message)
        var error = NSErrorPointer()
        match?.sendDataToAllPlayers(packet, withDataMode: GKMatchSendDataMode.Unreliable, error: error)
        if error != nil {
            println("error sending Punch Message: \(error.debugDescription)")
        }
    }
    
    func sendJumpMessage() {
        let message = Message(type: .SpecialMessage)
        message.content = "Jump"
        let packet = NSKeyedArchiver.archivedDataWithRootObject(message)
        var error = NSErrorPointer()
        match?.sendDataToAllPlayers(packet, withDataMode: GKMatchSendDataMode.Unreliable, error: error)
        if error != nil {
            println("error sending Jump Message: \(error.debugDescription)")
        }
    }
    
}

enum MessageType : String {
    case Default = "Default"
    case RandomNumberMessage = "RandomNumberMessage"
    case XPositionMessage = "XPositionMessage"
    case SpecialMessage = "SpecialMessage"
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
        type = MessageType(rawValue: (aDecoder.decodeObjectForKey("type") as! String))!
    }
    
    init(type: MessageType) {
        switch type {
        case .RandomNumberMessage: // 302 Bytes
            self.type = MessageType.RandomNumberMessage
            content = UInt(arc4random_uniform(1000000))
            break
        case .XPositionMessage:
            self.type = MessageType.XPositionMessage
            content = MyPositionInfo()
            break
        case .SpecialMessage:
            self.type = MessageType.SpecialMessage
            content = String()
            break
        default:
            break
        }
    }
}


@objc
class MyPositionInfo: NSObject, NSCoding {
    var position = Float()
    var velocity = Float()
    
    init(xPosition: CGFloat, xVelocity: CGFloat) { //jumping init
        self.position = Float(xPosition)
        self.velocity = Float(xVelocity)
    }
    
    override init() {
        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeFloat(position, forKey: "position")
        aCoder.encodeFloat(velocity, forKey: "velocity")
    }
    
    required init(coder aDecoder: NSCoder) {
        position = aDecoder.decodeFloatForKey("position")
        velocity = aDecoder.decodeFloatForKey("velocity")
        
    }
}