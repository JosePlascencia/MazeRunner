//
//  ViewController.swift
//  MazeRunner
//
//  Created by Jose on 9/8/17.
//  Copyright © 2017 Jose. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion


class ViewController: UIViewController {
    //views
    
    //gameview
    @IBOutlet weak var GameView: UIStackView!
    @IBOutlet weak var gameField: UIStackView!
    @IBOutlet weak var player_sprite: UILabel!
    
    let wallColor = UIColor.black
    let spaceColor = UIColor.green
    let startColor = UIColor.blue
    let endColor = UIColor.red
    
    var backGroundPlayer = AVAudioPlayer()
    
    //variable for current maze
    var maze: [[Cell]] = [[Cell]]()
    
    //GLOBAL VARIABLES FOR HIEGHT AND WIDTH OF MAZES(both must be odd)
    let HEIGHT = 21
    let WIDHT = 21
    var FRAME_SIZE : CGRect = CGRect()
    
    //initial location for start of maze and end of maze
    var mStartY = 20
    var mStartX = 1
    
    //player location
    struct Player {
        var x: Int = 0
        var y: Int = 0
    }
    var player = Player(x: 0, y: 0)
    
    enum Movement{
        case Up,Down,Right,Left
    }
    
    //game vars
    var score = 0
    
    //Motion Manager
    var motionManager: CMMotionManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        score = 0
        genNewMaze()
        motionManager = CMMotionManager()
        if let manager = motionManager {
            print("We have a motion manager \(manager)")
            if manager.isDeviceMotionAvailable {
                print("We can detect motion!")
                let myq = OperationQueue()
                manager.deviceMotionUpdateInterval = 1
                manager.startDeviceMotionUpdates(to: myq){
                    (data: CMDeviceMotion?, error: Error?) in
                    if let mydata = data {
                        let attitude = mydata.attitude
                        let pitch = self.degrees(radians: attitude.pitch)
                        let roll = self.degrees(radians: attitude.roll)
                        
                        if abs(pitch) < abs(roll){
                            if roll > 5{
                                print("moving down")
                                self.movePlayer(moveTo: Movement.Down)
                            }else if roll < -5 {
                                print("moving down")
                                self.movePlayer(moveTo: Movement.Up)
                            }
                        }else {
                            if pitch > 5 {
                                print("moving right")
                                self.movePlayer(moveTo: Movement.Right)
                            }else if pitch < -5 {
                                print("moving left")
                                self.movePlayer(moveTo: Movement.Left)
                            }
                        }
                        print(self.player)
                        
                        self.displayPlayer()
//                        print("pitch", self.degrees(radians: attitude.pitch))
//                        print("roll", self.degrees(radians: attitude.roll))
                        
                    }
                }
            }
            else {
                print("We cannot detect motion")
            }
        }
        else {
            print("No manager")
        }
        
    }
    func displayPlayer(){
        DispatchQueue.main.async{
            self.player_sprite.frame.size = self.FRAME_SIZE.size
            self.player_sprite.frame.offsetBy(dx: CGFloat(self.player.x), dy: CGFloat(self.player.y))
        }
    }
    func movePlayer(moveTo: Movement){
        switch moveTo {
        case Movement.Down:
            if self.player.y != 0 && maze[self.player.y-1][self.player.x].type != Tiles.Wall{
                self.player.y -= 1
                if maze[self.player.y][self.player.x].type == Tiles.End{
                    mStartY = 0
                    mStartX = self.player.x
                    DispatchQueue.main.async{
                        for toRemove in self.gameField.arrangedSubviews{
                            self.gameField.removeArrangedSubview(toRemove)
                        }
                        self.genNewMaze()
                    }
                }
            }
        case Movement.Up:
            if self.player.y != HEIGHT-1 && maze[self.player.y+1][self.player.x].type != Tiles.Wall{
                self.player.y += 1
                if maze[self.player.y][self.player.x].type == Tiles.End{
                    mStartY = HEIGHT - 1
                    mStartX = self.player.x
                    DispatchQueue.main.async{
                        for toRemove in self.gameField.arrangedSubviews{
                            self.gameField.removeArrangedSubview(toRemove)
                        }
                        self.genNewMaze()
                    }
                }
            }
        case Movement.Right:
            if self.player.x != WIDHT-1 && maze[self.player.y][self.player.x+1].type != Tiles.Wall{
                self.player.x += 1
                if maze[self.player.y][self.player.x].type == Tiles.End{
                    mStartY = self.player.y
                    mStartX = 0
                    DispatchQueue.main.async{
                        for toRemove in self.gameField.arrangedSubviews{
                            self.gameField.removeArrangedSubview(toRemove)
                        }
                        self.genNewMaze()
                    }
                }
            }
        case Movement.Left:
            if self.player.x != 0 && maze[self.player.y][self.player.x-1].type != Tiles.Wall{
                self.player.x -= 1
                if maze[self.player.y][self.player.x].type == Tiles.End{
                    mStartY = self.player.y
                    mStartX = WIDHT - 1
                    DispatchQueue.main.async{
                        for toRemove in self.gameField.arrangedSubviews{
                            self.gameField.removeArrangedSubview(toRemove)
                        }
                        self.genNewMaze()
                    }
                }
            }
        }
    }
    
    // Radians to degrees conversion
    func degrees(radians: Double) -> Double {
        return 180/Double.pi * radians
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //generate new maze, relocate player
    func genNewMaze(){
        maze = genMaze(Height: HEIGHT, Width: WIDHT, StartY: mStartY, StartX: mStartX)
        self.player.x = mStartX
        self.player.y = mStartY
        
        for row in maze{
            let hstackview = UIStackView()
            hstackview.axis = UILayoutConstraintAxis.horizontal
            hstackview.distribution = UIStackViewDistribution.fillEqually
            for col in row{
                let tile = UILabel()
                switch col.type {
                case Tiles.Wall:
                    tile.backgroundColor = wallColor
                case Tiles.Space:
                    tile.backgroundColor = spaceColor
                case Tiles.Start:
                    tile.backgroundColor = startColor
                case Tiles.End:
                    tile.backgroundColor = endColor
                }
                hstackview.addArrangedSubview(tile)
            }
            
            FRAME_SIZE = hstackview.subviews[0].frame
            gameField.addArrangedSubview(hstackview)
        }
        playBGMusic(fileNamed: "bensound-epic.mp3")
    }
    
    //Play Background Music
    func playBGMusic(fileNamed: String){
        let url = Bundle.main.url(forResource: fileNamed, withExtension: nil)
        guard let newUrl = url else{
            print ("Could not find sound file")
            return
        }
        do{
            backGroundPlayer = try AVAudioPlayer(contentsOf: newUrl)
            backGroundPlayer.numberOfLoops = -1
            backGroundPlayer.prepareToPlay()
            backGroundPlayer.play()
        }
        catch let error as NSError{
            print(error.description)
        }
    }
}

