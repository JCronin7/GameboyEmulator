import SpriteKit

class MainMenuConfiguration {
    var backgroundColor: SKColor = .systemGray
    var fontName: String = "Avenir-Light"
    var titleFontSize: CGFloat = 40
    var optionFontSize: CGFloat = 24
}

class MainMenuScene: SKScene {
    var configuration: MainMenuConfiguration = MainMenuConfiguration()

    convenience init(configuration: MainMenuConfiguration) {
        self.init(size: .zero)
        self.configuration = configuration
    }

    override init(size: CGSize) {
        self.configuration = MainMenuConfiguration()
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        self.configuration = MainMenuConfiguration()
        super.init(coder: aDecoder)
    }

    private var menuOptions: [String: Any] = [
        "Sound Enabled": true,
        "Show FPS": false,
        "Scale Filter": "Nearest Neighbor"
    ]

    override func didMove(to view: SKView) {
        // Apply background from configuration with desired alpha
        backgroundColor = configuration.backgroundColor.withAlphaComponent(0.5)

        // Enforce resizeFill so the scene doesn't squish or stretch when the window resizes
        self.scaleMode = .resizeFill

        setupLayout()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        removeAllChildren()
        setupLayout()
    }

    private func setupLayout() {
        // Add the Game Boy logo
        var logo: SKSpriteNode? = nil

        // Safely check if the image exists in the app bundle
        if NSImage(named: "Nintendo GameBoy Logo") != nil {
            logo = SKSpriteNode(imageNamed: "Nintendo GameBoy Logo")
            logo!.position = CGPoint(x: frame.midX - 80, y: frame.midY + 50)
            logo!.size = CGSize(width: 384.0, height: 67.3)
            addChild(logo!)
        } else {
            print("WARNING: Could not find 'Nintendo GameBoy Logo' in the asset catalog.")
        }

        let titleLabel = SKLabelNode(text: "Emulator")
        titleLabel.fontName = configuration.fontName + "-Bold"
        titleLabel.fontSize = configuration.titleFontSize
        titleLabel.verticalAlignmentMode = .center

        // Position the title next to the logo if it loaded, otherwise center it
        titleLabel.horizontalAlignmentMode = logo != nil ? .left : .center
        titleLabel.position = logo != nil ? CGPoint(x: logo!.frame.maxX + 16, y: logo!.position.y) : CGPoint(x: frame.midX, y: frame.midY + 50)
        addChild(titleLabel)

        let startButton = SKLabelNode(text: "Start Game")
        startButton.fontName = configuration.fontName
        startButton.fontSize = configuration.optionFontSize
        startButton.position = CGPoint(x: frame.midX, y: frame.midY - 50)
        startButton.name = "startButton"
        addChild(startButton)

        let startDebugger = SKLabelNode(text: "Start Debugger")
        startDebugger.fontName = configuration.fontName
        startDebugger.fontSize = configuration.optionFontSize
        startDebugger.position = CGPoint(x: frame.midX, y: frame.midY - 100)
        startDebugger.name = "debuggerStartButton"
        addChild(startDebugger)
    }

    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            if node.name == "startButton" {
                startGame()
            }
            if node.name == "debuggerStartButton" {
                startDebugger()
            }
        }
    }

    private func startGame() {
        let gameScene = GameScene.newGameScene()
        gameScene.size = self.size
        let transition = SKTransition.crossFade(withDuration: 1.0)
        view?.presentScene(gameScene, transition: transition)
    }

    private func startDebugger() {
        let debuggerScene = DebuggerScene(size: self.size)
        debuggerScene.scaleMode = .resizeFill
        let transition = SKTransition.crossFade(withDuration: 1.0)
        view?.presentScene(debuggerScene, transition: transition)
    }
}
