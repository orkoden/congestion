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
    var collectedParticles = Set<BlueParticle>()

    init (delegate: ParticleDetectorDelegate){
        super.init()

        let queue = dispatch_queue_create("congestion.particledetector", nil)
        self.btCentralmanager = CBCentralManager(delegate: self, queue: queue)

        self.delegate = delegate
        
        self.btCentralmanager.scanForPeripheralsWithServices([CBUUID(string: "0x180A")], options: nil)
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!){
    
    }
    
    func centralManager(central: CBCentralManager!,
        didDiscoverPeripheral peripheral: CBPeripheral!,
        advertisementData advertisementData: [NSObject : AnyObject]!,
        RSSI RSSI: NSNumber!){
            
            
            let discoveredParticle = BlueParticle(uuid: peripheral.identifier, rssi: RSSI)
            self.collectedParticles.insert(discoveredParticle)
    }
}