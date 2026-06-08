import SpriteKit
import AppKit

enum LogLevel {
    case debug
    case info
    case warning
    case error
    case fatal
    
    var color: SKColor {
        switch self {
        case .debug: return .gray
        case .info: return .white
        case .warning: return .yellow
        case .error: return .red
        case .fatal: return SKColor(red: 0.6, green: 0.0, blue: 0.0, alpha: 1.0)
        }
    }
}

struct LogEntry {
    let level: LogLevel
    let message: String
}

/// A custom SpriteKit node that functions as a read-only log viewer.
/// It accepts new log messages and streams them, rolling upwards.
class LoggerNode: SKShapeNode {
    
    // Stores the log messages to render.
    var logs: [LogEntry] = [] {
        didSet {
            updateRender()
        }
    }
    
    // The label node responsible for actually rendering the text on screen.
    private var textLabel: SKLabelNode!
    
    init(rect: CGRect) {
        super.init()
        
        // Setup the visual background of the log panel.
        self.path = CGPath(rect: rect, transform: nil)
        self.fillColor = .black
        self.strokeColor = .darkGray
        self.isUserInteractionEnabled = false // No keyboard or mouse input
        
        // Create a crop node to clip the text so it doesn't spill out of the log panel or over the title.
        let cropNode = SKCropNode()
        let maskHeight = max(rect.height - 30, 0) // Leave room for the "Log Window" title label at the top
        let maskNode = SKSpriteNode(color: .white, size: CGSize(width: rect.width, height: maskHeight))
        maskNode.position = CGPoint(x: rect.minX + rect.width / 2, y: rect.minY + maskHeight / 2)
        cropNode.maskNode = maskNode
        addChild(cropNode)
        
        // Initialize and position the text label within the log panel.
        textLabel = SKLabelNode(fontNamed: "Courier")
        textLabel.fontSize = 12
        textLabel.fontColor = .lightGray
        textLabel.horizontalAlignmentMode = .left
        textLabel.verticalAlignmentMode = .bottom
        textLabel.numberOfLines = 0
        textLabel.preferredMaxLayoutWidth = rect.width - 16
        textLabel.lineBreakMode = .byCharWrapping
        textLabel.position = CGPoint(x: rect.minX + 8, y: rect.minY + 8)
        textLabel.text = ""
        cropNode.addChild(textLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateRender() {
        let attrString = NSMutableAttributedString()
        let font = NSFont(name: "Courier", size: 12) ?? NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        
        for (index, log) in logs.enumerated() {
            let suffix = index == logs.count - 1 ? "" : "\n"
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: log.level.color,
                .font: font
            ]
            attrString.append(NSAttributedString(string: log.message + suffix, attributes: attributes))
        }
        
        textLabel.attributedText = attrString
    }
    
    /// Appends a new log message to the log viewer and trims history if it gets too long.
    func addLog(_ level: LogLevel, _ message: String) {
        logs.append(LogEntry(level: level, message: message))
        if logs.count > 100 {
            logs.removeFirst()
        }
    }
}
