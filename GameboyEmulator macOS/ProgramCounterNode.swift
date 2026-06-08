import SpriteKit

class ProgramCounterNode: SKShapeNode {
    
    private var textLabel: SKLabelNode!
    
    init(rect: CGRect) {
        super.init()
        
        self.path = CGPath(rect: rect, transform: nil)
        self.fillColor = .black
        self.strokeColor = .darkGray
        self.lineWidth = 1.0
        
        let titleLabel = SKLabelNode(text: "Current Instruction")
        titleLabel.fontName = "HelveticaNeue-Bold"
        titleLabel.fontSize = 14
        titleLabel.fontColor = SKColor(red: 0.4, green: 0.8, blue: 0.4, alpha: 1.0)
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.verticalAlignmentMode = .top
        titleLabel.position = CGPoint(x: rect.minX + 8, y: rect.maxY - 8)
        addChild(titleLabel)
        
        textLabel = SKLabelNode()
        textLabel.fontName = "Courier"
        textLabel.fontSize = 12
        textLabel.fontColor = .yellow
        textLabel.horizontalAlignmentMode = .left
        textLabel.verticalAlignmentMode = .top
        textLabel.numberOfLines = 0
        textLabel.position = CGPoint(x: rect.minX + 8, y: rect.maxY - 35)
        addChild(textLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateInstructions(_ lines: [String]) {
        textLabel.text = lines.joined(separator: "\n")
    }
}