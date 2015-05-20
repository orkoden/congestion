//
//  BlueParticle.swift
//  Congestion
//
//  Created by Robert Atkins on 20/05/2015.
//  Copyright (c) 2015 Congestion. All rights reserved.
//

import Foundation

struct BlueParticle: Hashable, Equatable {
    let uuid: NSUUID
    let rssi: NSNumber
    
    var hashValue: Int {
        return uuid.hashValue
    }
    
}

func ==(lhs: BlueParticle, rhs: BlueParticle) -> Bool {
    return lhs.uuid == rhs.uuid
}