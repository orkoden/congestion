//
//  ParticleRepository.swift
//  Congestion
//
//  Created by Robert Atkins on 20/05/2015.
//  Copyright (c) 2015 Congestion. All rights reserved.
//

import Foundation

class ParticleRepository: ParticleDetectorDelegate, ParticleEmitterDelegate {
    
    static let ParticleSetAddedNotification = "ParticleSetAddedNotification"
    
    private(set) var particleSets: [ParticleSet] = [] {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(ParticleRepository.ParticleSetAddedNotification, object: self)
        }
    }
    
    func particleDetector(particleDetector: ParticleDetector, didDetectParticleSet particleSet: ParticleSet) {
        particleSets.append(particleSet)
    }
    
    func particleEmitter(particleEmitter: ParticleEmitter, didReceiveParticleSet particleSet: ParticleSet) {
        particleSets.append(particleSet)
    }

}