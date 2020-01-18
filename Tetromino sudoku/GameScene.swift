//
//  GameScene.swift
//
//  Created by Olav Salhus on 2010-01-05.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let boardWidth = 9
    let boardHeight = 9
    var board : [[SKShapeNode]] = [[]]
    var gridsize = CGFloat()
    var boardBackgroundColor = UIColor.darkGray
    
    override func sceneDidLoad() {
        // Removing example label manually, cannot access .sks file,
        (self.childNode(withName: "//helloLabel") as? SKLabelNode)?.removeFromParent()
        
        board = Array(repeating: Array(repeating: SKShapeNode(), count: boardHeight), count: boardWidth)
        
        
        // Create board
        backgroundColor = .black
        let (w, h) = (size.width, size.height)
        
        gridsize = min(w / CGFloat(boardWidth), h / CGFloat(boardHeight))
        let brickMargin : CGFloat = 0.1
        let brickInnerSizeRatio : CGFloat = (1.0 - brickMargin * 2.0)
        for (x, line) in board.enumerated() {
            for (y, _) in line.enumerated() {
                
                board[x][y] = SKShapeNode(rect: CGRect(
                        x: gridsize * (CGFloat(x) + brickMargin - CGFloat(boardWidth) / 2.0),
                        y: gridsize * (CGFloat(y) + brickMargin - CGFloat(boardHeight) / 2.0),
                        width : gridsize * brickInnerSizeRatio,
                        height: gridsize * brickInnerSizeRatio
                    )
                )
                board[x][y].lineWidth = gridsize * 0.1
            
                board[x][y].strokeColor = (((x/3+y/3)) % 2 == 1) ? .gray : .darkGray
                
                addChild(board[x][y])
            }
        }
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}
