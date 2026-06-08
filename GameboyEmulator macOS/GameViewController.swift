//
//  GameViewController.swift
//  GameboyEmulator macOS
//
//  Created by Jacob Cronin on 5/26/26.
//

import Cocoa
import SpriteKit
import GameplayKit

class GameViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = self.view as! SKView
        
        let scene = MainMenuScene(size: skView.bounds.size)
        scene.scaleMode = .resizeFill
        
        // Present the scene
        skView.presentScene(scene)
        
        skView.ignoresSiblingOrder = true
        
        skView.showsFPS = true
        skView.showsNodeCount = true
    }

}
