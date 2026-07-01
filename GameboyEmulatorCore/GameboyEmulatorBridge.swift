//
//  GameboyEmulatorBridge.swift
//  GameboyEmulatorBridge
//
//  Created by Jacob Cronin on 6/30/26.
//

import Foundation

public class GameboyEmulatorBridge {
    
    public init() {
        // TODO: Initialize your underlying C++ emulator core here
    }
    
    /// Retrieves the current 160x144 frame buffer from the emulator.
    public func getFrameBufferData() -> Data? {
        let width = 160
        let height = 144
        let bytesPerPixel = 4
        let totalBytes = width * height * bytesPerPixel
        
        // Mock frame buffer (static noise) so the project builds and runs
        var pixelData = [UInt8](repeating: 255, count: totalBytes)
        
        for i in stride(from: 0, to: totalBytes, by: bytesPerPixel) {
            // Generate a random shade of green for classic Gameboy feel
            let shade = UInt8.random(in: 50...200)
            pixelData[i] = shade - 50      // R
            pixelData[i+1] = shade + 50    // G
            pixelData[i+2] = shade - 50    // B
            pixelData[i+3] = 255           // A
        }
        
        return Data(pixelData)
    }
}
