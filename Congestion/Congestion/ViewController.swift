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
        scene.rootNode.addChildNode(createPartcleSceneNodeFromSets(randomSets) )

        particleSceneView.autoenablesDefaultLighting = true
        particleSceneView.allowsCameraControl = true

        // 3
        particleSceneView.scene = scene
    }

    func createPartcleSceneNodeFromSets (particleSets: Array<ParticleSet>) -> SCNNode {
        
        // randomly arrange different ParticleSets on a plane
        let colorSections = 1 / Float(particleSets.count)
        var rootNode = SCNNode()
        for var i = 0 ; i < particleSets.count ; ++i {
            let hue = CGFloat(colorSections) * CGFloat (i)
            rootNode.addChildNode(createParticlesceneNode(particleSets[i], zplane: Float(i), hue: hue))
        }
        
        return rootNode;
    }
    
    func randomParticleSet() -> ParticleSet {
        var particles = Set<Particle>()
        
        for i in 1...10 {
            particles.insert(Particle(uuid: NSUUID(), rssi: NSNumber(unsignedInt: arc4random_uniform(200)) ))
        }
        return ParticleSet(timestamp: NSDate(), nucleus: UIDevice.currentDevice().identifierForVendor, particles: particles)
    }
    
    func createParticlesceneNode (particleSet: ParticleSet, zplane: Float, hue: CGFloat) -> SCNNode {
//      create center Node
        let spereGeometry = SCNSphere(radius: 0.2)
        spereGeometry.firstMaterial!.diffuse.contents = UIColor.blackColor()
        spereGeometry.firstMaterial!.specular.contents = UIColor.lightGrayColor()
        
        let sphereCenterNode =  SCNNode(geometry: spereGeometry)
        sphereCenterNode.position = SCNVector3Make(-6, 0, 0)
        
//  create all child nodes
        let rotationOffset = 2.0 * M_PI / Double(particleSet.particles.count)
        
        var childNodes = Array<SCNNode>()
        let particleArray = Array(particleSet.particles)
        
        for var i = 0 ; i < particleArray.count ; ++i {
            let particle = particleArray[i]
            let node = createParticleNode( particle, rotationOffset: Double(i) * rotationOffset, zplane: zplane, hue: hue)
            childNodes.append(node)
        }
        
        for node in childNodes {
            sphereCenterNode.addChildNode(node)
        }
        
        return sphereCenterNode
    }
    
    func createParticleNode (particle: Particle, rotationOffset: Double, zplane: Float, hue: CGFloat) -> SCNNode {
        let spereGeometry = SCNSphere(radius: 0.2)
        spereGeometry.firstMaterial!.diffuse.contents = UIColor(hue: hue, saturation: 1.0, brightness: 0.8, alpha: 1)
        
        spereGeometry.firstMaterial!.specular.contents = UIColor(hue: hue, saturation: 0.2, brightness: 1, alpha: 1)
        
        let normalizedSignal = particle.rssi.doubleValue / 200.0
        let maxRadius = 2.2
        let minRadius = 0.2
        let radius = normalizedSignal * maxRadius + minRadius
        
        let x = sin(rotationOffset) * radius
        let y = cos(rotationOffset) * radius
        
        let sphereNode =  SCNNode(geometry: spereGeometry)
        sphereNode.position = SCNVector3Make(Float(x), Float(y), zplane / 3)
        
        return sphereNode
    }
}
