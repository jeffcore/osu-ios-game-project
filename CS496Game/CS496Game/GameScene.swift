//
//  GameScene.swift
//  CS496Game
//
//  Created by Rix on 10/31/14.
//  Copyright (c) 2014 bitcore. All rights reserved.
//

import UIKit
import SpriteKit
import CoreMotion

let kPlayerSpeed = 300
let kTiltSensitivity = 0.15
let kPlayerMovement = 10

//struct for physics world
struct PhysicsCategory
{
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Monster   : UInt32 = 0b1
    static let Player    : UInt32 = 0b10
}

class GameScene: SKScene, SKPhysicsContactDelegate
{
    let player = SKSpriteNode(imageNamed: "knight")
    var monstersDestroyed = 0
    
    override func didMoveToView(view: SKView)
    {
        //add background image to scene
        backgroundColor = SKColor.whiteColor()
        var bgImage = SKSpriteNode(imageNamed: "grass")
        bgImage.position = CGPointMake(self.size.width/2, self.size.height/2)
        self.addChild(bgImage)
        
        //add game directions to scene
        let label = SKLabelNode(fontNamed: "Arial")
        label.text = "Kill 10 Evil Pumpkins to Win"
        label.fontSize = 15
        label.fontColor = SKColor.whiteColor()
        label.position = CGPoint(x: 100, y: 5)
        addChild(label)

        //set initial location of player
        player.position = CGPoint(x: size.width * 0.5, y:size.height * 0.5)
        
        //add player to physics world
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
        player.physicsBody?.dynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        player.physicsBody?.collisionBitMask = PhysicsCategory.None
        player.physicsBody?.usesPreciseCollisionDetection = true
        
        //add player to scene
        addChild(self.player)
        
        //set physics world
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        //Start Accelermeter for player movement
        accelerometerProcess()
        
        //run action sequence to add monsters to screen
        runAction(SKAction.repeatActionForever(
            SKAction.sequence([
                SKAction.runBlock(addMonster),
                SKAction.waitForDuration(1.5)
            ])
        ))
    }
    
    //code for accelerometer
    //used to control player  with up/down/left/right movements
    func accelerometerProcess()
    {
        let motionManager: CMMotionManager = CMMotionManager()
        if (motionManager.accelerometerAvailable)
        {
            //add accelerometer checking to queue, this will run on a background thread
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue())
            {
                //get current position of player
                (data, error) in
                let currentX = self.player.position.x
                let currentY = self.player.position.y
                
                //println("x \(currentX) y \(currentY) width \(self.size.width) height \(self.size.height)")
                //println("acceleration x \(data.acceleration.x) acceleration y \(data.acceleration.y)")
                
                if(data.acceleration.x > kTiltSensitivity)
                { // tilting the device to the up
                    //println("tilt up \(data.acceleration.x)")
                    //stop movement if at edge of screen
                    if (currentY + (self.player.size.height / 2)  + CGFloat(kPlayerMovement) < self.size.height)
                    {
                        //println("plyaer middle \(currentY) player edige \(self.player.size.height / 2  + currentY) less than screen edge \(self.size.height)")
                        
                        //set x and y end points
                        var destX = CGFloat(currentX)
                        var destY = CGFloat(kPlayerMovement) + CGFloat(currentY)
                        println("destY for accerl \(destY)")
                     
                        motionManager.accelerometerActive == true;
                        let action = SKAction.moveTo(CGPointMake(destX, destY), duration: 0.04)
                        self.player.runAction(action)
                    }
                }
                else if (data.acceleration.x < -kTiltSensitivity)
                { // tilting the device to the down
                    // println("tilt down \(data.acceleration.x)")
                    
                    //println("if \(currentY - 9 - (self.player.size.height / 2))")
                     //stop movement if at edge of screen
                    if (currentY - CGFloat(kPlayerMovement) - (self.player.size.height / 2) > 0)
                    { //println("in if statement")
                        //println("Tile bottom plyaer middle \(currentY) player edige \(self.player.size.height / 2  + currentY) less than screen edge \(self.size.height)")
                        //set x and y end points
                        var destX = CGFloat(currentX)
                        var destY = CGFloat(currentY) - CGFloat(kPlayerMovement)
                       
                        motionManager.accelerometerActive == true;
                        let action = SKAction.moveTo(CGPointMake(destX, destY), duration: 0.04)
                        self.player.runAction(action)
                    }
                }
                else if(data.acceleration.y < -kTiltSensitivity)
                { // tilting the device to the right
                    // println("tilt right \(data.acceleration.y)")
                    //stop movement if at edge of screen
                    if (currentX + (self.player.size.width / 2)  + CGFloat(kPlayerMovement) < self.size.width)
                    {
                        //set x and y end points
                        var destX = CGFloat(kPlayerMovement) + CGFloat(currentX)
                        var destY = CGFloat(currentY)
                      
                        motionManager.accelerometerActive == true;
                        let action = SKAction.moveTo(CGPointMake(destX, destY), duration: 0.04)
                        self.player.runAction(action)
                    }
                }
                else if (data.acceleration.y > kTiltSensitivity)
                { // tilting the device to the left
                    // println("tilt left \(data.acceleration.y)")
                    //stop movement if at edge of screen
                    if (currentX - CGFloat(kPlayerMovement) - (self.player.size.width / 2) > 0)
                    {
                        //set x and y end points
                        var destX = CGFloat(currentX) - CGFloat(kPlayerMovement)
                        var destY = CGFloat(currentY)
                       
                        motionManager.accelerometerActive == true;
                        let action = SKAction.moveTo(CGPointMake(destX, destY), duration: 0.04)
                        self.player.runAction(action)
                    }
                }
            }
        }
    }
    
    //function called when there is a collision between player and monster
    func playerDidCollideWithMonster(monster:SKSpriteNode, player:SKSpriteNode)
    {
        println("Hit")
        monster.removeFromParent()
        
        monstersDestroyed++
        if (monstersDestroyed > 10)
        {
            //println("winner")
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    //SKPhysicsContactDelegate method called when a collision is detected
    func didBeginContact(contact: SKPhysicsContact)
    {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask
        {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else
        {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Player != 0))
        {
                playerDidCollideWithMonster(firstBody.node as SKSpriteNode, player: secondBody.node as SKSpriteNode)
        }
    }
    
    //random number generators
    func random() -> CGFloat
    {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(#min: CGFloat, max: CGFloat) -> CGFloat
    {
        return random() * (max - min) + min
    }
    
    //randomly add monsters to scene
    func addMonster()
    {
        // Create sprite
        let monster = SKSpriteNode(imageNamed: "pumpkin")
        
        //add monster to physics world
        monster.physicsBody = SKPhysicsBody(rectangleOfSize: monster.size)
        monster.physicsBody?.dynamic = true
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None

        //random number to pick side where moster originates from
        var sideScreen = Int(floor(random() * 4))
        //println("random \(sideScreen)")
        var startX : CGFloat = 0.0
        var startY : CGFloat = 0.0
        var endX : CGFloat = 0.0
        var endY : CGFloat = 0.0
        
        //each case is a side of the screen
        switch (sideScreen)
        {
            case 0://left to right
                startX = size.width + monster.size.width/2
                startY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
                endX = -monster.size.width/2
                endY = startY
            case 1://right to left
                startX = -monster.size.width/2
                startY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
                endX = size.width + monster.size.width/2
                endY = startY
            case 2://up to down
                startX = random(min: monster.size.width/2, max: size.width - monster.size.width/2)
                startY = size.height + monster.size.height/2
                endX = startX
                endY = -monster.size.height/2
            case 3://down to up
                startX = random(min: monster.size.width/2, max: size.width - monster.size.width/2)
                startY = -monster.size.height/2
                endX = startX
                endY = size.height + monster.size.height/2
            default:
                println("error")
        }
        
        //original start placement of monster offset from edge
        monster.position = CGPoint(x: startX, y: startY)
        
        // add monster to the scene
        addChild(monster)
        
        // create random speed for monster
        let actualDuration = random(min: CGFloat(6.0), max: CGFloat(10.0))
        
        //set move to location for monster
        let actionMove = SKAction.moveTo(CGPoint(x: endX, y: endY), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
      
        //run action
        monster.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
}
