//
//  ParticleSet.swift
//  Congestion
//
//  Created by Robert Atkins on 20/05/2015.
//  Copyright (c) 2015 Congestion. All rights reserved.
//

import Foundation

class ParticleSet {
    
    let timestamp: NSDate
    let nucleus: NSUUID
    let particles: Set<Particle>
    
    init(timestamp: NSDate, nucleus: NSUUID, particles: Set<Particle>) {
        self.timestamp = timestamp
        self.nucleus = nucleus
        self.particles = particles
    }
    
}