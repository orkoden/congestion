//
//  ParticleGraphicNodeCreator.swift
//  Congestion
//
//  Created by Jörg Bühmann on 20.05.15.
//  Copyright (c) 2015 Congestion. All rights reserved.
//

import Foundation
import SceneKit

func createPartcleSceneNodeFromSets (particleSets: Array<ParticleSet>) -> SCNNode {
    
    // randomly arrange different ParticleSets on a plane
    let colorSections = 1 / Float(particleSets.count)
    var rootNode = SCNNode()
    for var i = 0 ; i < particleSets.count ; ++i {
        let hue = CGFloat(colorSections) * CGFloat (i)
        rootNode.addChildNode(createParticlesceneNode(particleSets[i], Float(i), hue))
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
        let node = createParticleNode( particle, Double(i) * rotationOffset, zplane, hue)
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
