import SpriteKit

class DebuggerScene: SKScene {
    // UI Panels
    private var consolePanel: ConsoleNode!
    private var logPanel: LoggerNode!
    private var instructionPanel: ProgramCounterNode!
    private var registerPanel: RegisterNode!
    private var gameWindowPanel: SKShapeNode!
    private var memoryPanel: MemoryNode!
    
    override func didMove(to view: SKView) {
        self.scaleMode = .resizeFill
        backgroundColor = SKColor(white: 0.15, alpha: 1.0)
        setupLayout()
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        guard oldSize != .zero else { return }
        
        // Save state of the interactive console before rebuilding
        let savedText = consolePanel?.text ?? "> "
        let savedActive = consolePanel?.isActive ?? false
        let savedHistory = consolePanel?.commandHistory ?? []
        let savedLogs = logPanel?.logs ?? []
        
        removeAllChildren()
        setupLayout()
        
        consolePanel.text = savedText
        consolePanel.isActive = savedActive
        consolePanel.commandHistory = savedHistory
        logPanel.logs = savedLogs
    }
    
    private func setupLayout() {
        let w = size.width
        let h = size.height
        
        let leftColWidth = w * 0.25
        let midColWidth = w * 0.45
        let rightColWidth = w * 0.30
        let bottomRowHeight = h * 0.25
        
        // Console (Bottom Left)
        let consoleRect = CGRect(x: 0, y: 0, width: w * 0.5, height: bottomRowHeight)
        consolePanel = ConsoleNode(rect: consoleRect)
        let consoleTitle = SKLabelNode(text: "Console")
        consoleTitle.fontName = "HelveticaNeue-Bold"
        consoleTitle.fontSize = 14
        consoleTitle.fontColor = SKColor(red: 0.4, green: 0.8, blue: 0.4, alpha: 1.0)
        consoleTitle.horizontalAlignmentMode = .left
        consoleTitle.verticalAlignmentMode = .top
        consoleTitle.position = CGPoint(x: consoleRect.minX + 8, y: consoleRect.maxY - 8)
        consolePanel.addChild(consoleTitle)
        addChild(consolePanel)
        
        // Log Window (Bottom Right)
        let logRect = CGRect(x: w * 0.5, y: 0, width: w * 0.5, height: bottomRowHeight)
        logPanel = LoggerNode(rect: logRect)
        //logPanel = createPanel(rect: logRect, title: "Log Window", color: .black)
        addChild(logPanel)
        
        // Current Instruction (Top Left)
        let instructionRect = CGRect(x: 0, y: h * 0.8, width: leftColWidth, height: h * 0.2)
        instructionPanel = ProgramCounterNode(rect: instructionRect)
        addChild(instructionPanel)
        
        // Register View (Mid Left)
        let registerRect = CGRect(x: 0, y: bottomRowHeight, width: leftColWidth, height: h * 0.8 - bottomRowHeight)
        registerPanel = RegisterNode(rect: registerRect)
        addChild(registerPanel)
        
        // Game Window (Middle)
        let gameRect = CGRect(x: leftColWidth, y: bottomRowHeight, width: midColWidth, height: h - bottomRowHeight)
        gameWindowPanel = createPanel(rect: gameRect, title: "Game Window", color: .black)
        addChild(gameWindowPanel)
        
        // Memory View (Right)
        let memoryRect = CGRect(x: leftColWidth + midColWidth, y: bottomRowHeight, width: rightColWidth, height: h - bottomRowHeight)
        memoryPanel = MemoryNode(rect: memoryRect)
        addChild(memoryPanel)
        
        setupPlaceholderContent()
    }
    
    private func createPanel(rect: CGRect, title: String, color: SKColor) -> SKShapeNode {
        let node = SKShapeNode(rect: rect)
        node.fillColor = color
        node.strokeColor = .darkGray
        node.lineWidth = 1.0
        
        let titleLabel = SKLabelNode(text: title)
        titleLabel.fontName = "HelveticaNeue-Bold"
        titleLabel.fontSize = 14
        titleLabel.fontColor = SKColor(red: 0.4, green: 0.8, blue: 0.4, alpha: 1.0)
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.verticalAlignmentMode = .top
        titleLabel.position = CGPoint(x: rect.minX + 8, y: rect.maxY - 8)
        
        node.addChild(titleLabel)
        return node
    }
    
    private func setupPlaceholderContent() {
        // Current Instruction
        instructionPanel.updateInstructions(["0x0100: NOP", "0x0101: JP 0x0150"])
        
        // Registers
        registerPanel.updateRegisters(["A:  00   F:  00", "B:  00   C:  00", "D:  00   E:  00", "H:  00   L:  00", "SP: 0000", "PC: 0100"])
        
        // Memory
        memoryPanel.updateMemory(["0100: 00 C3 50 01 00 00 00 00", "0108: 00 00 00 00 00 00 00 00", "0110: 00 00 00 00 00 00 00 00"])
        
        // Log
        logPanel.addLog(.info, "[INFO] Debugger attached.")
        
        // Game Window Placeholder (A classic green rectangle scaled to 160x144 proportions)
        let gameScreenHeight = gameWindowPanel.frame.height * 0.6
        let gameScreenWidth = gameScreenHeight * (160.0 / 144.0)
        let gameScreen = SKShapeNode(rectOf: CGSize(width: gameScreenWidth, height: gameScreenHeight))
        gameScreen.fillColor = SKColor(red: 0.61, green: 0.73, blue: 0.06, alpha: 1.0)
        gameScreen.strokeColor = .clear
        gameScreen.position = CGPoint(x: gameWindowPanel.frame.midX, y: gameWindowPanel.frame.midY - 10)
        gameWindowPanel.addChild(gameScreen)
    }
    
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        // Deactivate console and resign first responder if clicking outside of it
        if consolePanel != nil, !consolePanel.contains(location) {
            consolePanel.isActive = false
            self.view?.window?.makeFirstResponder(self.view)
        }
    }
}
