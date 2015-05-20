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
    var dumpingTimer: NSTimer!

    init (delegate: ParticleDetectorDelegate){
        super.init()

        self.delegate = delegate
        self.dumpingTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: Selector("dumpParticlesToDelegate"), userInfo: nil, repeats: true)

        let queue = dispatch_queue_create("congestion.particledetector", nil)
        self.btCentralmanager = CBCentralManager(delegate: self, queue: queue)
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
    
    func dumpParticlesToDelegate () {
        let setToDump = BlueParticleSet(timestamp: NSDate(), nucleus: NSUUID(), particles: self.collectedParticles)
        self.collectedParticles = Set<BlueParticle>()
        
        self.delegate.particleDetector(self, didDetectParticleSet: setToDump)
    }
}