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
    //gameview
    @IBOutlet weak var gameField: UIStackView!
    @IBOutlet weak var scoreField: UILabel!
    @IBOutlet weak var stepsField: UILabel!
    
    let wallImg = UIImage(named: "wall")
    let spaceImg = UIImage(named: "space")
    let startImg = UIImage(named: "start")
    let endImg = UIImage(named: "end")
    
    var backGroundPlayer = AVAudioPlayer()
    
    //variable for current maze
    var maze: [[Cell]] = [[Cell]]()
    
    //GLOBAL VARIABLES FOR HIEGHT AND WIDTH OF MAZES(both must be odd)
    let HEIGHT = 21
    let WIDTH = 21
    
    //initial location for start of maze and end of maze
    var mStartY = 20
    var mStartX = 1
    
    //player location
    struct Player {
        var x: Int = 0
        var y: Int = 0
    }
    var player = Player(x: 0, y: 0)
    var isMovable = true
    enum Movement{
        case Up, Down, Right, Left
    }
    @IBOutlet weak var player_sprite: UIImageView!
    
    //game vars
    var score = 0
    var steps = 200
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
                manager.deviceMotionUpdateInterval = 0.2
                manager.startDeviceMotionUpdates(to: myq){
                    (data: CMDeviceMotion?, error: Error?) in
                    if let mydata = data {
                        let attitude = mydata.attitude
                        let pitch = self.degrees(radians: attitude.pitch)
                        let roll = self.degrees(radians: attitude.roll)
                        
                        if abs(pitch) > abs(roll){
                            if pitch > 5{
                                self.movePlayer(moveTo: Movement.Up)
                            }else if pitch < -5 {
                                self.movePlayer(moveTo: Movement.Down)
                            }
                        }else {
                            if roll > 5 {
                                self.movePlayer(moveTo: Movement.Right)
                            }else if roll < -5 {
                                self.movePlayer(moveTo: Movement.Left)
                            }
                        }
                        self.displayPlayer()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func restartButtonPressed(_ sender: Any) {
        isMovable = false
        mStartY = 20
        mStartX = 1
        self.player.y = 20
        self.player.x = 1
        DispatchQueue.main.async{
            for toRemove in self.gameField.subviews{
                toRemove.removeFromSuperview()
            }
            self.genNewMaze()
            self.isMovable = true
        }
        score = 0
        steps = 200
        self.updateLabels()
        if let gameOver = self.view.viewWithTag(69) as? UILabel {
            gameOver.removeFromSuperview()
        }
    }

    
    func displayPlayer(){
        if isMovable{
            DispatchQueue.main.async{
                self.view.bringSubview(toFront: self.player_sprite)
                let w = self.gameField.subviews[self.player.y].subviews[self.player.x].frame.size.width
                let h = self.gameField.subviews[self.player.y].subviews[self.player.x].frame.size.height
                
                print("x: \(self.gameField.frame.origin.x + (CGFloat(self.player.x) * w)) y: \(self.gameField.frame.origin.y + (CGFloat(self.player.y) * h))")
                self.player_sprite.frame = CGRect(x: self.gameField.frame.origin.x + (CGFloat(self.player.x) * w), y: self.gameField.frame.origin.y + (CGFloat(self.player.y) * h), width: w, height: h)
            }
        }
    }
    
    func movePlayer(moveTo: Movement){
        
        if isMovable {
            switch moveTo {
            case Movement.Down:
                if self.player.y != 0 && maze[self.player.y-1][self.player.x].type != Tiles.Wall{
                    self.player.y -= 1
                    mStartY = 0
                    mStartX = self.player.x
                    self.legalMove()
                }
            case Movement.Up:
                if self.player.y != HEIGHT-1 && maze[self.player.y+1][self.player.x].type != Tiles.Wall{
                    self.player.y += 1
                    mStartY = HEIGHT - 1
                    mStartX = self.player.x
                    self.legalMove()
                }
            case Movement.Right:
                if self.player.x != WIDTH-1 && maze[self.player.y][self.player.x+1].type != Tiles.Wall{
                    self.player.x += 1
                    mStartY = self.player.y
                    mStartX = 0
                    self.legalMove()
                }
            case Movement.Left:
                if self.player.x != 0 && maze[self.player.y][self.player.x-1].type != Tiles.Wall{
                    self.player.x -= 1
                    mStartY = self.player.y
                    mStartX = WIDTH - 1
                    self.legalMove()
                }
            }
        }
    }
    
    func legalMove(){
        self.backGroundPlayer.rate = 1 + (1 - Float(steps)/200)
        self.steps -= 1
        self.score += 69
        if maze[self.player.y][self.player.x].type == Tiles.End{
            isMovable = false
            if self.steps < 100{
                self.steps += 100
            }
            else{
                self.steps = 200
            }
            self.player.x = mStartX
            self.player.y = mStartY
            DispatchQueue.main.async{
                for toRemove in self.gameField.subviews{
                    toRemove.removeFromSuperview()
                }
                self.genNewMaze()
                self.isMovable = true            }
        }
        self.updateLabels()
    }
    
    func updateLabels() {
        if steps == 0 {
            DispatchQueue.main.async{
                self.isMovable = false
                let rect = CGRect(x: (self.view.frame.width/2)-50, y: (self.view.frame.height/2)-50, width: 100, height: 100)
                let label = UILabel(frame: rect)
                label.text = "GAME OVER"
                label.textColor = UIColor.red
                label.backgroundColor = UIColor.black
                label.tag = 69
                self.view.addSubview(label)
                self.isMovable = false
                self.playBGMusic(fileNamed: "bensound-love.mp3")
            }
        }
        DispatchQueue.main.async{
            self.stepsField.text = String(self.steps)
            self.scoreField.text = String(self.score)
        }
    }
    
    // Radians to degrees conversion
    func degrees(radians: Double) -> Double {
        return 180/Double.pi * radians
    }

    //generate new maze, relocate player
    func genNewMaze(){
        maze = genMaze(Height: HEIGHT, Width: WIDTH, StartY: mStartY, StartX: mStartX)
        self.player.x = mStartX
        self.player.y = mStartY
        
        for row in maze{
            let hstackview = UIStackView()
            hstackview.axis = UILayoutConstraintAxis.horizontal
            hstackview.distribution = UIStackViewDistribution.fillEqually
            for col in row{
                let tile :UIImageView
                switch col.type {
                case Tiles.Wall:
                    tile = UIImageView(image: wallImg!)
                case Tiles.Space:
                    tile = UIImageView(image: spaceImg!)
                case Tiles.Start:
                    tile = UIImageView(image: startImg!)
                case Tiles.End:
                    tile = UIImageView(image: endImg!)
                }
                hstackview.addArrangedSubview(tile)
            }
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
            backGroundPlayer.enableRate = true;
            backGroundPlayer.play()
        }
        catch let error as NSError{
            print(error.description)
        }
    }
}

