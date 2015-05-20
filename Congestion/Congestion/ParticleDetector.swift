//
//  ParticleDetector.swift
//  Congestion
//
//  Created by Jörg Bühmann on 20.05.15.
//  Copyright (c) 2015 Congestion. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol ParticleDetectorDelegate {
 
    func particleDetector (particleDetector: ParticleDetector, didDetectParticleSet particleSet : BlueParticleSet)
}


@objc class ParticleDetector : NSObject, CBCentralManagerDelegate {
    var btCentralmanager: CBCentralManager!
    var delegate: ParticleDetectorDelegate!
    
    init (delegate: ParticleDetectorDelegate){
        super.init()

        let queue = dispatch_queue_create("congestion.particledetector", nil)
        self.btCentralmanager = CBCentralManager(delegate: self, queue: queue)

        self.delegate = delegate
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!){
    
    }
}