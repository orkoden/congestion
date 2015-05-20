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
    @IBOutlet weak var particleScene: SCNView!
    
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
    }
    
}
