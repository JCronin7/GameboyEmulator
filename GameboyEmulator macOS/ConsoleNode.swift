import SpriteKit

/// A custom SpriteKit node that functions as an interactive text console.
/// It allows the user to click to focus, type commands, and submit them via the Return key.
class ConsoleNode: SKShapeNode {
    
    // The current text displayed in the console. Updating this automatically refreshes the label.
    var text: String = "" {
        didSet { updateRender() }
    }
    
    // Tracks whether the cursor should be drawn as visible (used for the blinking cursor effect).
    var cursorVisible: Bool = true {
        didSet { updateRender() }
    }
    
    // Stores previous commands to render above the current prompt.
    var commandHistory: [String] = [] {
        didSet {
            historyIndex = commandHistory.count
            updateRender()
        }
    }
    
    // Tracks the current position in the command history when using arrow keys.
    private var historyIndex: Int = 0
    
    // Temporarily stores the current typed text when cycling through history.
    private var currentDraft: String = ""
    
    // The static prompt symbol displayed at the beginning of the line.
    let prompt: String = "> "
    
    // The label node responsible for actually rendering the text on screen.
    private var textLabel: SKLabelNode!
    
    // Tracks if the console is currently focused and accepting input.
    var isActive: Bool = false {
        didSet { updateRender() }
    }
    
    // Required for macOS to allow this SKNode to become the first responder and receive keyboard events.
    override var acceptsFirstResponder: Bool { return true }
    
    // The original frame of the console, used to calculate maximum text width.
    private var consoleRect: CGRect
    
    init(rect: CGRect) {
        self.consoleRect = rect
        super.init()
        
        // Setup the visual background of the console panel.
        self.path = CGPath(rect: rect, transform: nil)
        self.fillColor = .black
        self.strokeColor = .darkGray
        self.isUserInteractionEnabled = true
        
        // Create a crop node to clip the text so it doesn't spill out of the console or over the title.
        let cropNode = SKCropNode()
        let maskHeight = max(rect.height - 30, 0) // Leave room for the "Console" title label at the top
        let maskNode = SKSpriteNode(color: .white, size: CGSize(width: rect.width, height: maskHeight))
        maskNode.position = CGPoint(x: rect.minX + rect.width / 2, y: rect.minY + maskHeight / 2)
        cropNode.maskNode = maskNode
        addChild(cropNode)
        
        // Initialize and position the text label within the console.
        textLabel = SKLabelNode(fontNamed: "Courier")
        textLabel.fontSize = 12
        textLabel.fontColor = .green
        textLabel.horizontalAlignmentMode = .left
        textLabel.verticalAlignmentMode = .bottom
        textLabel.numberOfLines = 0
        textLabel.preferredMaxLayoutWidth = rect.width - 16
        textLabel.lineBreakMode = .byCharWrapping
        textLabel.position = CGPoint(x: rect.minX + 8, y: rect.minY + 8)
        textLabel.text = prompt
        cropNode.addChild(textLabel)
        
        self.text = prompt
        
        // Create a blinking cursor effect by repeatedly toggling `cursorVisible` every 0.5 seconds.
        let wait = SKAction.wait(forDuration: 0.5)
        let toggle = SKAction.run { [weak self] in
            self?.cursorVisible.toggle()
        }
        run(SKAction.repeatForever(SKAction.sequence([wait, toggle])))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateRender() {
        // Note: Cursor rendering is currently commented out, but this applies the latest text to the label.
        let historyText = commandHistory.isEmpty ? "" : commandHistory.joined(separator: "\n") + "\n"
        textLabel.text = historyText + text + (isActive && cursorVisible ? "_" : "")
    }
    
    override func mouseDown(with event: NSEvent) {
        // When the user clicks on the console, make it active and request keyboard focus.
        isActive = true
        self.scene?.view?.window?.makeFirstResponder(self)
    }
    
    override func keyDown(with event: NSEvent) {
        // Ignore key presses if the console hasn't been clicked/focused.
        guard isActive else { return }
        
        if event.keyCode == 51 { // Delete key
            // Prevent the user from deleting the prompt prefix.
            if text.count > prompt.count {
                text.removeLast()
            }
        } else if event.keyCode == 36 { // Return key
            // Process the submitted command and reset the console text.
            print("Command submitted: \(text)")
            
            // Only add to history if the typed command isn't empty or just whitespace
            let input = text.dropFirst(prompt.count).trimmingCharacters(in: .whitespaces)
            if !input.isEmpty {
                commandHistory.append(text)
            }
            text = prompt // Reset after submission
            currentDraft = ""
        } else if event.keyCode == 126 { // Up arrow
            if historyIndex == commandHistory.count {
                currentDraft = text // Save what the user is currently typing
            }
            if historyIndex > 0 {
                historyIndex -= 1
                text = commandHistory[historyIndex]
            }
        } else if event.keyCode == 125 { // Down arrow
            if historyIndex < commandHistory.count - 1 {
                historyIndex += 1
                text = commandHistory[historyIndex]
            } else if historyIndex == commandHistory.count - 1 {
                historyIndex += 1
                text = currentDraft // Restore the saved draft when reaching the bottom
            }
        } else if let characters = event.characters, !characters.isEmpty {
            // Append typed characters to the string, ignoring invisible control characters (like arrows, shift, etc).
            if characters.rangeOfCharacter(from: .controlCharacters) == nil {
                text.append(characters)
            }
        }
    }
}
