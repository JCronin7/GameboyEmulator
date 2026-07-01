import SpriteKit
import Foundation
import GameboyEmulatorCore

/// A custom SpriteKit node that renders the Gameboy emulator screen.
final class GameNode: SKSpriteNode {
    private let emulatorBridge: GameboyEmulatorBridge
    private let frameWidth = 160
    private let frameHeight = 144
    private let bytesPerPixel = 4

    let screenTexture: SKMutableTexture

    init(emulatorBridge: GameboyEmulatorBridge) {
        self.emulatorBridge = emulatorBridge
        self.screenTexture = SKMutableTexture(size: CGSize(width: frameWidth, height: frameHeight))
        self.screenTexture.filteringMode = .nearest
        
        super.init(texture: self.screenTexture, color: .clear, size: CGSize(width: frameWidth, height: frameHeight))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Updates the mutable texture with the latest frame buffer data
    func updateFrame() {
        guard let frameData = emulatorBridge.getFrameBufferData() else { return }

        screenTexture.modifyPixelData { rawBufferPointer, lengthInBytes in
            frameData.withUnsafeBytes { dataPointer in
                if let source = dataPointer.baseAddress {
                    memcpy(rawBufferPointer, source, min(lengthInBytes, frameData.count))
                }
            }
        }
    }
}
