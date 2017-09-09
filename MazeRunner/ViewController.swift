//
//  ViewController.swift
//  MazeRunner
//
//  Created by Jose on 9/8/17.
//  Copyright © 2017 Jose. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    //views
    
    //gameview
    @IBOutlet weak var GameView: UIStackView!
    @IBOutlet weak var gameField: UIStackView!
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
    
    //initial location for start of maze and end of maze
    var mStartY = 20
    var mStartX = 1
    
    //player location
    var playerY = 0
    var playerX = 0
    
    //game vars
    var score = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        score = 0
        genNewMaze()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //generate new maze, relocate player
    func genNewMaze(){
        maze = genMaze(Height: HEIGHT, Width: WIDHT, StartY: mStartY, StartX: mStartX)
        playerX = mStartX
        playerY = mStartY
        
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

