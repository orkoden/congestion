//
//  ParticleDetector.swift
//  Congestion
//
//  Created by Jörg Bühmann on 20.05.15.
//  Copyright (c) 2015 Congestion. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit

protocol ParticleDetectorDelegate {
 
    func particleDetector (particleDetector: ParticleDetector, didDetectParticleSet particleSet : ParticleSet)
}


@objc class ParticleDetector : NSObject, CBCentralManagerDelegate {
    var btCentralmanager: CBCentralManager!
    var delegate: ParticleDetectorDelegate!
    var collectedParticles = Set<Particle>()
    var dumpingTimer: NSTimer!

    init (delegate: ParticleDetectorDelegate){
        super.init()

        self.delegate = delegate
        self.dumpingTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: Selector("dumpParticlesToDelegate"), userInfo: nil, repeats: true)

        let queue = dispatch_queue_create("congestion.particledetector", nil)
        self.btCentralmanager = CBCentralManager(delegate: self, queue: queue)
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!){
        let state: String
            switch central.state {
            case .Unknown:
                state = "Unknown"
            case .Resetting:
                state = "Resetting"
            case .Unsupported:
                state = "Unsupported"
            case .Unauthorized:
                state = "Unauthorized"
            case .PoweredOff:
                state = "PoweredOff"
            case .PoweredOn:
                self.btCentralmanager.scanForPeripheralsWithServices([CBUUID(string: "0x180A")], options: nil)
                state = "PoweredOn"
            }
        println("\(__FUNCTION__): \(state)")
    }
    
    func centralManager(central: CBCentralManager!,
        didDiscoverPeripheral peripheral: CBPeripheral!,
        advertisementData: [NSObject : AnyObject]!,
        RSSI: NSNumber!){
            println("\(__FUNCTION__)")
            let discoveredParticle = Particle(uuid: peripheral.identifier, rssi: RSSI)
            self.collectedParticles.insert(discoveredParticle)
    }
    
    func dumpParticlesToDelegate () {
        let deviceid = UIDevice.currentDevice().identifierForVendor
        if (self.collectedParticles.count > 0){
            let setToDump = ParticleSet(timestamp: NSDate(), nucleus: deviceid, particles: self.collectedParticles)
            self.collectedParticles = Set<Particle>()
            
            println("\(__FUNCTION__): \(setToDump)")
            self.delegate.particleDetector(self, didDetectParticleSet: setToDump)
        }
    }
}