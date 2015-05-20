//
//  ParticleRepository.swift
//  Congestion
//
//  Created by Robert Atkins on 20/05/2015.
//  Copyright (c) 2015 Congestion. All rights reserved.
//

import Foundation

class ParticleRepository: ParticleDetectorDelegate {
    
    static let ParticleSetAddedNotification = "ParticleSetAddedNotification"
    
    private(set) var particleSets: [BlueParticleSet] = [] {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(ParticleRepository.ParticleSetAddedNotification, object: self)
        }
    }
    
    func particleDetector(particleDetector: ParticleDetector, didDetectParticleSet particleSet: BlueParticleSet) {
        particleSets.append(particleSet)
    }
    
}