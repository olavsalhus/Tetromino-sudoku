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
    
    let boardBackgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
    
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
                addShaderToBlock(board[x][y])
                addChild(board[x][y])
            }
        }
    }
    
    fileprivate func drawSeperatorLines() {
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
    }
    
    override func sceneDidLoad() {
        // Removing example label programmatically, cannot access .sks file,
        (self.childNode(withName: "//helloLabel") as? SKLabelNode)?.removeFromParent()
        board = Array(repeating: Array(repeating: SKShapeNode(), count: boardHeight), count: boardWidth)
        isSquareSolid = Array(repeating: Array(repeating: false, count: boardHeight), count: boardWidth)
        backgroundColor = .black
        
        createBoard()
        
        drawSeperatorLines()
        
        
        currentShapes = [getRandomShape(), getRandomShape(), getRandomShape()]
        newShapeGridSize = gridsize / 2.0
        for (shapeIndex, shape) in newShapeNodes.enumerated() {
            for (x, line) in shape.enumerated() {
                for (y, _) in line.enumerated() {
                    newShapeNodes[shapeIndex][x][y] = SKShapeNode(rect: CGRect( x: 0, y: 0,
                            width : newShapeGridSize * brickInnerSizeRatio,
                            height: newShapeGridSize * brickInnerSizeRatio
                        ))
                    newShapeNodes[shapeIndex][x][y].position.x = CGFloat(shapeIndex) * newShapeGridSize * 5.0
                    newShapeNodes[shapeIndex][x][y].strokeColor = getShapeColor(currentShapes[shapeIndex].1)
                    newShapeNodes[shapeIndex][x][y].lineWidth = newShapeGridSize * brickMargin
                    newShapeNodes[shapeIndex][x][y].isHidden = true
                    addShaderToBlock(newShapeNodes[shapeIndex][x][y])
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
        
        resetShapePositions()
    }
    
    func getShapeColor(_ i: Int) -> UIColor {
        return UIColor(hue: CGFloat(i)/CGFloat(shapes.count), saturation: 1, brightness: 1, alpha: 1)
    }
    
    var scoreLabel = SKLabelNode(text: "0")
    
    var newShapeGridSize = CGFloat()
    let transparent = UIColor(white: 0.0, alpha: 0.0)
    var currentShapes : [([[Int]], Int)] = []
    var shapeIsVisible = [true, true, true]
    
    func resetShapePositions() {
        for shapeIndex in 0..<3 {
            let (hShape, wShape) = (currentShapes[shapeIndex].0[0].count, currentShapes[shapeIndex].0.count)
            
            for (x, line) in newShapeNodes[shapeIndex].enumerated() {
                for (y, block) in line.enumerated() {
                    let xOffset = CGFloat(6 - wShape) / 2.0
                    block.position.x = newShapeGridSize * CGFloat(xOffset + CGFloat(x + 6 * shapeIndex)) + brickMargin - size.width / 2.0
                    block.position.y = newShapeGridSize * CGFloat(y + 4) + brickMargin - size.height / 2.0
                    (block.xScale, block.yScale) = (1, 1)
                    block.strokeColor = getShapeColor(currentShapes[shapeIndex].1)
                    //block.strokeColor = UIColor.clear
                    block.isHidden = !(shapeIsVisible[shapeIndex] && (x < wShape && y < hShape && currentShapes[shapeIndex].0[x][y] == 1))
                    //block.glowWidth = 15
                    addShaderToBlock(block);
                }
            }
        }
    }
    
    func getRgba(_ color: UIColor) -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (r: red, g: green, b: blue, a: alpha)
        
    }
    
    func addShaderToBlock(_ block: SKShapeNode) {
        
        let checkerboardShader = SKShader(source:
"""

float getDistanceFromHollowSquare(vec2 pos) {
    
    float r = 0.4;
    bool isDiagonallyOutside = abs(pos.x) > r && abs(pos.y) > r;
    if (isDiagonallyOutside) return length(vec2(abs(pos.x), abs(pos.y)) - r);
    
    bool isOutside = abs(pos.x) > r || abs(pos.y) > r;
    
    if (isOutside) return max(abs(pos.x) - r, abs(pos.y) - r);
    
    // Handle inside of square
    
    // This line prevented sharp diagonal lines, uncomment this line to get the shortest distance
    return 1.0 / (1.0 / abs(pos.x - r) + 1.0 / abs(pos.y - r) + 1.0 / abs(pos.x + r) + 1.0 / abs(pos.y + r)) * 2.0;
    
    return min(
        min(abs(pos.x - r), abs(pos.y - r)),
        min(abs(pos.x + r), abs(pos.y + r))
    );
    
}
//https://www.shadertoy.com/view/3s3GDn
float getGlow(float dist, float radius, float intensity){
    return pow(radius/dist, intensity);
}
            void main() {
                float intensity = 1.3;
                float radius = 0.20;
                vec2 uv = v_tex_coord;
                vec2 centre = vec2(0.5, 0.5);
                vec2 pos = uv- centre;
    //Get first segment
    float dist1 = getDistanceFromHollowSquare(pos);
                //https://www.shadertoy.com/view/3s3GDn
                float glow1 = getGlow(dist1, radius, intensity);
                
                vec3 col =
                  + glow1 * clamp(u_color, 0.05, 1.0);
                
                //Tone mapping
                col = 1.0 - exp(-col);
                
                //Gamma
                col = pow(col, vec3(1.5));

                //Output to screen
                gl_FragColor = vec4(col,1.0);
            }
"""
        )
        let colors = getRgba(block.strokeColor)
        let a = Float(block.alpha)
        checkerboardShader.uniforms = [
            SKUniform(name: "u_color", vectorFloat3: vector_float3(
                Float(colors.r) * a, Float(colors.g) * a, Float(colors.b) * a
            ))
        ]
        block.lineWidth = 0 // Shader is used to draw line instead
        
        
        block.fillShader = checkerboardShader
    }
    
    
    func moveShape(_ p: CGPoint) {

        let (hShape, wShape) = (currentShapes[shapeIndex].0[0].count, currentShapes[shapeIndex].0.count)
        
        for (x, line) in newShapeNodes[shapeIndex].enumerated() {
            for (y, block) in line.enumerated() {
                block.position.x = gridsize * (CGFloat(x) - CGFloat(wShape)/2.0) + brickMargin + p.x
                block.position.y = gridsize * (2.0 + CGFloat(y) - CGFloat(wShape) / 2.0) + brickMargin + p.y
                block.xScale = 2
                block.yScale = 2
                block.isHidden = !(shapeIsVisible[shapeIndex] && x < wShape && y < hShape && currentShapes[shapeIndex].0[x][y] == 1)
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
            let shapeDropped = dropShape(previewColor, highlight: true)
            
            if !shapeDropped {
                removeHighlight()
            }
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
                addShaderToBlock(square)
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

        removeHighlight()
        if shapeIndex >= 0 {
            
            let shapeDropped = dropShape(getShapeColor(currentShapes[shapeIndex].1))
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
                        if shapeFits(shape.0) {
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
    var lastDropZone = [-1, -1]
    func dropShape(_ color: UIColor, highlight: Bool = false) -> Bool {
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
        if highlight && blocksToColor.count > 0 {
            
            if blocksToColor[0] != lastDropZone {
                for xy in blocksToColor {
                    isSquareSolid[xy[0]][xy[1]] = true
                }
                removeFullLinesAndCells(highlightOnly: true)
                for xy in blocksToColor {
                    isSquareSolid[xy[0]][xy[1]] = false
                }
                lastDropZone = blocksToColor[0]
            }
        }
        for xy in blocksToColor {
            board[xy[0]][xy[1]].strokeColor = color
            addShaderToBlock(board[xy[0]][xy[1]])
            isSquareSolid[xy[0]][xy[1]] = color != boardBackgroundColor && color != previewColor
        }
        return true
    }
    
    func removeHighlight() {
        for line in board {
            for square in line {
                if (square.alpha != 1.0) {
                    square.alpha = 1.0
                    addShaderToBlock(square)
                }
            }
        }
        lastDropZone = [-1, -1]
    }
    
    func removeFullLinesAndCells(highlightOnly: Bool = false) {
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
        if highlightOnly {
            for xy in blocksForRemoval {
                board[xy[0]][xy[1]].alpha = 0.5
                addShaderToBlock(board[xy[0]][xy[1]])
            }
            if blocksForRemoval.count == 0 {
                removeHighlight()
            }
            return
        }
        
        for xy in blocksForRemoval {
            board[xy[0]][xy[1]].strokeColor = boardBackgroundColor
            addShaderToBlock(board[xy[0]][xy[1]])
            isSquareSolid[xy[0]][xy[1]] = false
        }
        score += 100 * (cellCount + rowCount)
        if score > UserDefaults.standard.integer(forKey: "highscore") {
            UserDefaults.standard.set(score, forKey: "highscore")
        }
        scoreLabel.text = "\(score)"
    }
    
    var score = 0
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
    
    func getRandomShape() -> (Array<[Int]>, Int) {
        var newshape:Array<[Int]>
        let shapeNumber = Int.random(in: 0..<shapes.count)
        let shape = shapes[shapeNumber]
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
            return (shape, shapeNumber)
        }
        return (newshape, shapeNumber)
    }
    
   
}
