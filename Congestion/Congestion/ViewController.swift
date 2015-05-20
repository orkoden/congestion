//
//  ViewController.swift
//  Congestion
//
//  Created by Robert Atkins on 20/05/2015.
//  Copyright (c) 2015 Congestion. All rights reserved.
//

import UIKit
import SceneKit

class ViewController: UIViewController {
    
    lazy var particleRepository: ParticleRepository = ParticleRepository()
    lazy var particleDetector: ParticleDetector! = nil
    lazy var particleEmitter: ParticleEmitter! = nil

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var particleSceneView: SCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set up our service classes
        particleDetector = ParticleDetector(delegate: particleRepository)
        particleEmitter = ParticleEmitter(particleRepository: particleRepository, delegate: particleRepository)
        
        statusLabel.hidden = true
        
        NSNotificationCenter.defaultCenter().addObserverForName(ParticleRepository.ParticleSetAddedNotification, object: nil, queue: NSOperationQueue.mainQueue()) { notification in
            self.updateDisplay()
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(ParticleEmitter.ParticleEmitterErrorNotification, object: nil, queue: NSOperationQueue.mainQueue()) { notification in
            
            if let userInfo = notification.userInfo, message = userInfo[ParticleEmitter.ParticleEmitterNotificationMessageKey] as? String {
                self.statusLabel.text = message
            } else {
                self.statusLabel.text = ""
            }
        
            self.statusLabel.textColor = UIColor.redColor()
            self.statusLabel.alpha = 1.0
            UIView.animateWithDuration(1.0) {
                self.statusLabel.alpha = 0.0
            }
        }

        NSNotificationCenter.defaultCenter().addObserverForName(ParticleEmitter.ParticleEmitterInfoNotification, object: nil, queue: NSOperationQueue.mainQueue()) { notification in
            
            if let userInfo = notification.userInfo, message = userInfo[ParticleEmitter.ParticleEmitterNotificationMessageKey] as? String {
                self.statusLabel.text = message
            } else {
                self.statusLabel.text = ""
            }
            
            self.statusLabel.textColor = UIColor.blueColor()
            self.statusLabel.alpha = 1.0
            UIView.animateWithDuration(1.0) {
                self.statusLabel.alpha = 0.0
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateDisplay() {
        self.particleRepository.particleSets
        let scene = particleSceneView.scene!
        for object in scene.rootNode.childNodes {
            let node = object as! SCNNode
            node.removeFromParentNode()
        }
        particleSceneView.scene?.rootNode.addChildNode(createPartcleSceneNodeFromSets(self.particleRepository.particleSets))
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        sceneSetup()
    }
    
    func sceneSetup() {
        // 1
        let scene = SCNScene()

        var randomSets = Array<ParticleSet>()
        for i in 1...10 {
            let particleSet = randomParticleSet()
            randomSets.append(particleSet)
        }
//        scene.rootNode.addChildNode(createPartcleSceneNodeFromSets(randomSets) ) // adds random sample data

        particleSceneView.autoenablesDefaultLighting = true
        particleSceneView.allowsCameraControl = true

        // 3
        particleSceneView.scene = scene
    }

}
