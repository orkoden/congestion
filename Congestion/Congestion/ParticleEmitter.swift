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
    static let ParticleEmitterPeerConnectedNotification = "ParticleEmitterPeerConnectedNotification"
    
    static let CongestionServiceType = "Congestion"
 
    let localPeerId: MCPeerID
    let serviceAdvertiser: MCNearbyServiceAdvertiser
    
    override init() {
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
        let data = "".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        let error = NSErrorPointer()
        session.sendData(data, toPeers: [peerID], withMode: MCSessionSendDataMode.Reliable, error: error)
    }
    
}