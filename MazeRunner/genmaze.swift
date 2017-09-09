//
//  genmaze.swift
//  MazeRunner
//
//  Created by Jose on 9/8/17.
//  Copyright © 2017 Jose. All rights reserved.
//


import UIKit

enum Tiles{
    case Wall, Space, Start, End
}

struct Cell{
    var y : Int
    var x : Int
    var type : Tiles
    var visited: Bool
}

func genMaze(Height: Int, Width: Int, StartY: Int, StartX: Int) -> [[Cell]]{
    var maze: [[Cell]] = [[Cell]]()
    var stack: [Cell] = [Cell]()
    var current: Cell
    var ended : Bool = false
    
    
    for y in 0..<Height{
        maze.append([Cell(y: y,x: 0,type: Tiles.Wall,visited: false)])
        for x in 1..<Width{
            maze[y].append(Cell(y: y,x: x,type: Tiles.Wall,visited: false))
        }
    }
    
    maze[StartY][StartX].type = Tiles.Start
    if StartX == 0 {
        current = maze[StartY][StartX+1]
        maze[StartY][StartX+1].type = Tiles.Space
    }
    else if StartX == maze[0].count - 1 {
        current = maze[StartY][StartX-1]
        maze[StartY][StartX-1].type = Tiles.Space
    }
    else if StartY == 0{
        current = maze[StartY+1][StartX]
        maze[StartY+1][StartX].type = Tiles.Space
    }
    else{
        current = maze[StartY-1][StartX]
        maze[StartY-1][StartX].type = Tiles.Space
    }
    
    stack.append(current)
    while stack.count > 0 {
        maze[current.y][current.x].visited = true
        
        if let neighbors = getNeighbors(Current: current,Maze: maze){
            let rn = arc4random_uniform(UInt32(neighbors.count))
            let neighbor = neighbors[Int(rn)]
            
            let xd = neighbor.x - current.x
            let yd = neighbor.y - current.y
            
            if xd > 0 {
                maze[current.y][current.x+1].type = Tiles.Space
                maze[current.y][current.x+1].visited = true
            }
            else if xd < 0 {
                maze[current.y][current.x-1].type = Tiles.Space
                maze[current.y][current.x-1].visited = true
            }
            else if yd > 0 {
                maze[current.y+1][current.x].type = Tiles.Space
                maze[current.y+1][current.x].visited = true
            }
            else if yd < 0 {
                maze[current.y-1][current.x].type = Tiles.Space
                maze[current.y-1][current.x].visited = true
            }
            
            current = neighbor
            maze[current.y][current.x].type = Tiles.Space
            stack.append(current)
        }
        else{
            if !ended{
                if current.x == 1 {
                    maze[current.y][0].type = Tiles.End
                    ended = true
                }
                else if current.x == maze[0].count-2 {
                    maze[current.y][current.x+1].type = Tiles.End
                    ended = true
                }
                else if current.y == 1{
                    maze[0][current.x].type = Tiles.End
                    ended = true
                }
                else if current.y == maze.count-2{
                    maze[current.y+1][current.x].type = Tiles.End
                    ended = true
                }
            }
            _ = stack.popLast()
            if stack.count > 0 {
                current = stack[stack.count-1]
            }
        }
    }
    
    return maze
}

func getNeighbors(Current: Cell, Maze: [[Cell]]) -> [Cell]?{
    var neighbors: [Cell] = [Cell]()
    
    //top
    if Current.y > 2 && !Maze[Current.y-2][Current.x].visited{
        neighbors.append(Maze[Current.y-2][Current.x])
    }
    //right
    if Current.x < Maze[0].count-3 && !Maze[Current.y][Current.x+2].visited{
        neighbors.append(Maze[Current.y][Current.x+2])
    }
    //bottom
    if Current.y < Maze.count-3 && !Maze[Current.y+2][Current.x].visited{
        neighbors.append(Maze[Current.y+2][Current.x])
    }
    //left
    if Current.x > 2 && !Maze[Current.y][Current.x-2].visited{
        neighbors.append(Maze[Current.y][Current.x-2])
    }
    
    return neighbors.count > 0 ? neighbors : nil
}
