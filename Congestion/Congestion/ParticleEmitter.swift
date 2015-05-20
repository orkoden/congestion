//
//  ParticleEmitter.swift
//  Congestion
//
//  Created by Robert Atkins on 20/05/2015.
//  Copyright (c) 2015 Congestion. All rights reserved.
//

import MultipeerConnectivity

class ParticleEmitter: NSObject, MCNearbyServiceAdvertiserDelegate {
    
    static let ParticleEmitterAdvertisingFailedNotification = "ParticleEmitterAdvertisingFailedNotification"
    static let ParticleEmitterSendingFailedNotification = "ParticleEmitterSendingFailedNotification"
    static let ParticleEmitterPeerConnectedNotification = "ParticleEmitterPeerConnectedNotification"
    
    static let CongestionServiceType = "Congestion"
    
    let particleRepository: ParticleRepository
 
    let localPeerId: MCPeerID
    let serviceAdvertiser: MCNearbyServiceAdvertiser
    
    init(particleRepository: ParticleRepository) {
        self.particleRepository = particleRepository
        localPeerId = MCPeerID(displayName: UIDevice.currentDevice().name) // should we use the UUID for this?
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: localPeerId, discoveryInfo: nil, serviceType: ParticleEmitter.CongestionServiceType)
        
        super.init()
        
        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
    }

    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didNotStartAdvertisingPeer error: NSError!) {
        NSNotificationCenter.defaultCenter().postNotificationName(ParticleEmitter.ParticleEmitterAdvertisingFailedNotification, object: nil)
        serviceAdvertiser.startAdvertisingPeer()
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
        NSNotificationCenter.defaultCenter().postNotificationName(ParticleEmitter.ParticleEmitterPeerConnectedNotification, object: nil)
        let session = MCSession(peer: localPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.None)
        
        let propertyListSerialisationError = NSErrorPointer()
        let data = NSPropertyListSerialization.dataWithPropertyList(particleRepository.particleSets, format: NSPropertyListFormat.BinaryFormat_v1_0, options: 0, error: propertyListSerialisationError)
        
        let sendDataError = NSErrorPointer()
        let success = session.sendData(data, toPeers: [peerID], withMode: MCSessionSendDataMode.Reliable, error: sendDataError)
        if !success {
            NSNotificationCenter.defaultCenter().postNotificationName(ParticleEmitter.ParticleEmitterSendingFailedNotification, object: nil)
        }
    }
    
}