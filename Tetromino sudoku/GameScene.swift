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
    var isSquareSolid : [[Bool]] = [[]]
    var gridsize = CGFloat()
    var newShapeNodes = Array(repeating: Array(repeating: Array(repeating: SKShapeNode(), count: 4), count: 4), count: 3)
    let brickMargin : CGFloat = 0.1
    var brickInnerSizeRatio = CGFloat()
    
    let boardBackgroundColor = UIColor.darkGray
    
    func createBoard() {
        // Create board
        let (w, h) = (size.width, size.height)
        gridsize = min(w / CGFloat(boardWidth), h / CGFloat(boardHeight))
        
        brickInnerSizeRatio = 1.0 - brickMargin * 2.0
        
        for (x, line) in board.enumerated() {
            for (y, _) in line.enumerated() {
                board[x][y] = SKShapeNode(rect: CGRect(
                    x: gridsize * (CGFloat(x) + brickMargin - CGFloat(boardWidth) / 2.0),
                    y: gridsize * (CGFloat(y + 2) + brickMargin - CGFloat(boardHeight) / 2.0),
                    width : gridsize * brickInnerSizeRatio,
                    height: gridsize * brickInnerSizeRatio
                    )
                )
                board[x][y].lineWidth = gridsize * brickMargin
                
                board[x][y].strokeColor = boardBackgroundColor //(((x/3+y/3)) % 2 == 1) ? .gray : .darkGray
                
                addChild(board[x][y])
            }
        }
    }
    
    override func sceneDidLoad() {
        // Removing example label programmatically, cannot access .sks file,
        (self.childNode(withName: "//helloLabel") as? SKLabelNode)?.removeFromParent()
        board = Array(repeating: Array(repeating: SKShapeNode(), count: boardHeight), count: boardWidth)
        isSquareSolid = Array(repeating: Array(repeating: false, count: boardHeight), count: boardWidth)
        backgroundColor = .black
        
        createBoard()
        
        // Draw lines seperating cells
        for line in [1, 2] {
            let pathX = UIBezierPath()
            pathX.move(to: CGPoint(
                x: gridsize * (                        -CGFloat(boardWidth)   / 2.0),
                y: gridsize * (CGFloat(line * 3 + 2)  - CGFloat(boardHeight ) / 2.0)
            ))
            pathX.addLine(to: CGPoint(
                x: gridsize * (CGFloat(9)            - CGFloat(boardWidth)   / 2.0),
                y: gridsize * (CGFloat(line * 3 + 2) - CGFloat(boardHeight ) / 2.0)
            ))
            
            let lineX = SKShapeNode(path: pathX.cgPath)
            lineX.strokeColor = .lightGray
            lineX.lineWidth = 4
            addChild(lineX)
            
            let pathY = UIBezierPath()
            pathY.move(to: CGPoint(
                x: gridsize * (CGFloat(line * 3)  - CGFloat(boardWidth ) / 2.0),
                y: gridsize * (2                  - CGFloat(boardHeight) / 2.0)
            ))
            pathY.addLine(to: CGPoint(
                x: gridsize * (CGFloat(line * 3) - CGFloat(boardWidth ) / 2.0),
                y: gridsize * (CGFloat(9 + 2)    - CGFloat(boardHeight) / 2.0)
            ))
            
            let lineY = SKShapeNode(path: pathY.cgPath)
            lineY.strokeColor = .lightGray
            lineY.lineWidth = 4
            addChild(lineY)
        }
        
        
        newShapeGridSize = gridsize / 2.0
        for (shapeIndex, shape) in newShapeNodes.enumerated() {
            for (x, line) in shape.enumerated() {
                for (y, _) in line.enumerated() {
                    newShapeNodes[shapeIndex][x][y] = SKShapeNode(rect: CGRect( x: 0, y: 0,
                            width : newShapeGridSize * brickInnerSizeRatio,
                            height: newShapeGridSize * brickInnerSizeRatio
                        ))
                    newShapeNodes[shapeIndex][x][y].position.x = CGFloat(shapeIndex) * newShapeGridSize * 5.0
                    newShapeNodes[shapeIndex][x][y].lineWidth = newShapeGridSize * brickMargin
                    newShapeNodes[shapeIndex][x][y].strokeColor = shapeColors[shapeIndex]
                    newShapeNodes[shapeIndex][x][y].isHidden = true
                    addChild(newShapeNodes[shapeIndex][x][y])
                }
            }
        }
        
        // Show score
        scoreLabel.position = CGPoint(x: -size.width / 2, y: size.height / 2.0)
        scoreLabel.fontSize = 52
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        currentShapes = [getRandomShape(), getRandomShape(), getRandomShape()]
        resetShapePositions()
    }
    
    var scoreLabel = SKLabelNode(text: "0")
    
    var newShapeGridSize = CGFloat()
    let transparent = UIColor(white: 0.0, alpha: 0.0)
    var currentShapes : [[[Int]]] = []
    var shapeIsVisible = [true, true, true]
    
    func resetShapePositions() {
        for shapeIndex in 0..<3 {
            let (hShape, wShape) = (currentShapes[shapeIndex][0].count, currentShapes[shapeIndex].count)
            
            for (x, line) in newShapeNodes[shapeIndex].enumerated() {
                for (y, block) in line.enumerated() {
                    let xOffset = CGFloat(6 - wShape) / 2.0
                    block.position.x = newShapeGridSize * CGFloat(xOffset + CGFloat(x + 6 * shapeIndex)) + brickMargin - size.width / 2.0
                    block.position.y = newShapeGridSize * CGFloat(y + 4) + brickMargin - size.height / 2.0
                    (block.xScale, block.yScale) = (1, 1)
                    block.isHidden = !(shapeIsVisible[shapeIndex] && (x < wShape && y < hShape && currentShapes[shapeIndex][x][y] == 1))
                }
            }
        }
    }
    
    
    func moveShape(_ p: CGPoint) {

        let (hShape, wShape) = (currentShapes[shapeIndex][0].count, currentShapes[shapeIndex].count)
        
            for (x, line) in newShapeNodes[shapeIndex].enumerated() {
                for (y, block) in line.enumerated() {
                    block.position.x = gridsize * (CGFloat(x) - CGFloat(wShape)/2.0) + brickMargin + p.x
                    block.position.y = gridsize * (2.0 + CGFloat(y) - CGFloat(wShape) / 2.0) + brickMargin + p.y
                    block.xScale = 2
                    block.yScale = 2
                    block.isHidden = !(shapeIsVisible[shapeIndex] && x < wShape && y < hShape && currentShapes[shapeIndex][x][y] == 1)
                }
            }
        
    }
    
    var shapeIndex = -1
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let x = brickMargin - size.width  / 2.0
        let y = brickMargin - size.height / 2.0
        
        let size = newShapeGridSize * 6
        
        let p = touches.first!.location(in: self)
        
        if y <= p.y && p.y <= y + size * 2 {
            
            shapeIndex = Int((p.x - x) / size)
            if shapeIndex >= 3 {
                shapeIndex = -1
            }
        }
    }
    
    let previewColor = UIColor.gray
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let p = touches.first!.location(in: self)
        if shapeIndex >= 0 {
            _ = dropShape(boardBackgroundColor)
            moveShape(p)
            _ = dropShape(previewColor)
        }
    }
    
    func shapeFits(_ shape: [[Int]]) -> Bool {
        for x in 0...(boardWidth - shape.count) {
            for y in 0...(boardWidth - shape[0].count) {
                var hasSpace = true
                for dx in 0..<shape.count {
                    for dy in 0..<shape[0].count {
                        if isSquareSolid[x + dx][y + dy] && shape[dx][dy] == 1  {
                            hasSpace = false
                        }
                    }
                }
                if hasSpace {
                    return true
                }
            }
            
        }
        
        return false
    }
    
    fileprivate func clearBoard() {
        for (x, line) in board.enumerated() {
            for (y, square) in line.enumerated() {
                square.strokeColor = boardBackgroundColor
                isSquareSolid[x][y] = false
            }
        }
    }
    
    
    var nodesToRemove :  [SKNode] = []
    @objc func removeLabels() {
        for node in nodesToRemove {
            node.removeFromParent()
        }
        nodesToRemove = []
    }
    
    func printLabel(_ text: String, _ secondsToShow: Double = 3.0) {
        removeLabels()
        var labels : [SKLabelNode] = []
        var shapes : [SKShapeNode] = []
        for (i, line) in text.split(separator:   "\n").reversed().enumerated() {
            let currentScoreLabel = SKLabelNode()
            currentScoreLabel.text = String(line)
            currentScoreLabel.fontSize = 120
            currentScoreLabel.position.y = +currentScoreLabel.fontSize * CGFloat(i + 1) - size.height / 2
            
            currentScoreLabel.color = .white
            let shade = SKShapeNode(rect: CGRect(
                    x: -size.width / 2,
                    y: currentScoreLabel.position.y,
                    width: size.width,
                    height: currentScoreLabel.fontSize
                )
            )
            shade.fillColor = UIColor.init(white: 0, alpha: 0.3)
            shade.strokeColor = shade.fillColor
            labels += [currentScoreLabel]
            shapes += [shade]
            nodesToRemove +=  [shade, currentScoreLabel]
        }
        
        for shape in shapes { addChild(shape) }
        for label in labels { addChild(label) }
        
        nodesToRemove += shapes + labels
        
        Timer.scheduledTimer(timeInterval: secondsToShow, target: self, selector: #selector(self.removeLabels), userInfo: nil, repeats: false)
    }
    var highScore = UserDefaults.standard.integer(forKey: "highscore")
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if shapeIndex >= 0 {
            
            
            let shapeDropped = dropShape(shapeColors[shapeIndex])
            if shapeDropped {
                shapeIsVisible[shapeIndex] = false
                removeFullLinesAndCells()
                if shapeIsVisible == [false, false, false] {
                    shapeIsVisible = [true, true, true]
                    currentShapes = [getRandomShape(), getRandomShape(), getRandomShape()]
                }
                var gameOver = true
                for (shapeIndex, shape) in currentShapes.enumerated() {
                    if shapeIsVisible[shapeIndex] {
                        if shapeFits(shape) {
                            gameOver = false
                            break
                        }
                    }
                }
                if gameOver {
                    
                    clearBoard()
                    shapeIsVisible = [true, true, true]
                    currentShapes = [getRandomShape(), getRandomShape(), getRandomShape()]
                    if (score > highScore) {
                        printLabel("Game over\nNew high score:\n\(score)", 3)
                        highScore = UserDefaults.standard.integer(forKey: "highscore")
                    } else {
                        printLabel("Game over\nHigh score:\n\(highScore)\nScore:\n\(score)", 3)
                    }
                    
                    score = 0
                    scoreLabel.text = "0"
                }
            }
            resetShapePositions()
            shapeIndex = -1
        }
        
    }
    
    func dropShape(_ color: UIColor) -> Bool {
        var blocksToColor : [[Int]] = []
        for (_, line) in newShapeNodes[shapeIndex].enumerated() {
            for (_, block) in line.enumerated() {
                
                
                // Center of block
                let pX = block.position.x + gridsize / 2.0
                let pY = block.position.y + gridsize / 2.0
                
                // Bottom left of board
                let minX = gridsize * (brickMargin - CGFloat(boardWidth) / 2.0)
                let minY = gridsize * (2 + brickMargin - CGFloat(boardHeight) / 2.0)
                
                // Board position (index)
                let x = Int(floor((pX - minX) / gridsize))
                let y = Int(floor((pY - minY) / gridsize))
                
                if block.isHidden { continue }
                
                
                if 0 <= x && x < boardWidth && 0 <= y && y < boardHeight {
                    if isSquareSolid[x][y] { return false }
                    blocksToColor.append([x, y])
                } else {
                    return false
                }
            }
        }
        for xy in blocksToColor {
            board[xy[0]][xy[1]].strokeColor = color
            isSquareSolid[xy[0]][xy[1]] = color != boardBackgroundColor && color != previewColor
        }
        return true
    }
    
    func removeFullLinesAndCells() {
        var blocksForRemoval : [[Int]] = []
        var rowCount = 0
        var cellCount = 0
        for x in 0..<boardWidth {
            var candidatesForRemoval : [[Int]] = []
            for y in 0..<boardHeight{
                if isSquareSolid[x][y] { candidatesForRemoval.append([x, y]) }
            }
            if candidatesForRemoval.count == boardHeight {
                rowCount += 1
                blocksForRemoval.append(contentsOf: candidatesForRemoval)
            }
        }
        
        for y in 0..<boardHeight {
            var candidatesForRemoval : [[Int]] = []
            for x in 0..<boardWidth{
                if isSquareSolid[x][y] { candidatesForRemoval.append([x, y]) }
            }
            if candidatesForRemoval.count == boardHeight {
                rowCount += 1
                blocksForRemoval.append(contentsOf: candidatesForRemoval)
            }
        }
        
        for cellX in 0..<3 {
            for cellY in 0..<3 {
                var candidatesForRemoval : [[Int]] = []
                for x in (cellX * 3)..<(cellX * 3 + 3) {
                    for y in (cellY * 3)..<(cellY * 3 + 3) {
                        if isSquareSolid[x][y] { candidatesForRemoval.append([x, y]) }
                    }
                    if candidatesForRemoval.count == boardHeight {
                        cellCount += 1
                        blocksForRemoval.append(contentsOf: candidatesForRemoval)
                    }
                }
            }
        }
        
        
        for xy in blocksForRemoval {
            board[xy[0]][xy[1]].strokeColor = boardBackgroundColor
            isSquareSolid[xy[0]][xy[1]] = false
        }
        score += 100 * (cellCount + rowCount)
        if score > UserDefaults.standard.integer(forKey: "highscore") {
            UserDefaults.standard.set(score, forKey: "highscore")
        }
        scoreLabel.text = "\(score)"
    }
    var score = 0
    var shapeColors : [UIColor] = [.yellow, .cyan, .orange, .blue, .purple, .red, .green, .magenta, .brown, .yellow, .cyan, .orange,.yellow, .cyan, .orange]
    var shapes = [
        [[1, 1],
         [1, 1]],
        
        [[1, 1, 1, 1]],
        
        [[0, 0, 1],
         [1, 1, 1]],
        
        [[1, 1, 1],
         [0, 0, 1]],
        
        [[0, 1, 0],
         [1, 1, 1]],
        
        [[1, 1, 0],
         [0, 1, 1]],
        
        [[0, 1, 1],
         [1, 1, 0]],
        
         [[1]],
         
         [[1, 1]],
         
         [[1, 0],
          [0, 1]],
         
         [[1, 1],
          [1, 0]],
         
         [[1, 0, 0],
          [0, 1, 0],
          [0, 0, 1]],
         
         [[1 ,1, 1],
          [0 ,1, 0],
          [0 ,1, 0]],
         
         [[0, 1, 0],
          [1, 1, 1],
          [0, 1, 0]]
    ]
    
    func getRandomShape() -> Array<[Int]> {
        var newshape:Array<[Int]>
        
        let shape = shapes[Int.random(in: 0..<shapes.count)]
        let rotation = Int.random(in: 0..<4)
        if (rotation == 1 || rotation == 3) { // 90 or 270 deg
            newshape = Array(repeating: Array(repeating: 0, count: shape.count), count: shape[0].count)
            for (dx, line) in shape.enumerated() {
                for (dy, block) in line.enumerated() {
                    if (rotation == 1) {
                        newshape[line.count - 1 - dy][dx] = block
                    }
                    if (rotation == 3) {
                        newshape[dy][shape.count - 1 - dx] = block
                    }
                }
            }
        }
        else if (rotation == 2) { // 180 deg
            newshape = shape
            for (dx, line) in shape.enumerated() {
                for (dy, block) in line.enumerated() {
                    newshape[shape.count - 1 - dx][line.count - 1 - dy] = block
                }
            }
        } else {
            return shape
        }
        return newshape
    }
    
   
}
