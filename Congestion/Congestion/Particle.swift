//
//  Particle.swift
//  Congestion
//
//  Created by Robert Atkins on 20/05/2015.
//  Copyright (c) 2015 Congestion. All rights reserved.
//

import Foundation

class Particle: Hashable, Equatable {

    let uuid: NSUUID
    let rssi: NSNumber
    
    init(uuid: NSUUID, rssi: NSNumber) {
        self.uuid = uuid
        self.rssi = rssi
    }
    
    var hashValue: Int {
        return uuid.hashValue
    }
    
}

func ==(lhs: Particle, rhs: Particle) -> Bool {
    return lhs.uuid == rhs.uuid
}