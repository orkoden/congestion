//
//  ParticleEmitter.swift
//  Congestion
//
//  Created by Robert Atkins on 20/05/2015.
//  Copyright (c) 2015 Congestion. All rights reserved.
//

import MultipeerConnectivity

protocol ParticleEmitterDelegate {
    
    func particleEmitter(particleEmitter: ParticleEmitter, didReceiveParticleSet particleSet: ParticleSet)
    
}

class ParticleEmitter: NSObject, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate {
    
    static let ParticleEmitterErrorNotification = "ParticleEmitterErrorNotification"
    static let ParticleEmitterInfoNotification = "ParticleEmitterInfoNotification"
    static let ParticleEmitterNotificationMessageKey = "ParticleEmitterNotificationMessageKey"
    
    static let CongestionServiceType = "Congestion"
    
    let particleRepository: ParticleRepository
    let delegate: ParticleEmitterDelegate
 
    let localPeerId: MCPeerID
    let serviceAdvertiser: MCNearbyServiceAdvertiser
    let serviceBrowser: MCNearbyServiceBrowser
    
    init(particleRepository: ParticleRepository, delegate: ParticleEmitterDelegate) {
        self.particleRepository = particleRepository
        localPeerId = MCPeerID(displayName: UIDevice.currentDevice().name) // should we use the UUID for this?
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: localPeerId, discoveryInfo: nil, serviceType: ParticleEmitter.CongestionServiceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: localPeerId, serviceType: ParticleEmitter.CongestionServiceType)
        serviceBrowser.startBrowsingForPeers()
        
        self.delegate = delegate
        
        super.init()
        
        serviceAdvertiser.delegate = self
        serviceBrowser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()
    }
    
    
    // MARK: - Advertiser delegate

    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didNotStartAdvertisingPeer error: NSError!) {
        println("\(__FILE__), \(__FUNCTION__)")
        NSNotificationCenter.defaultCenter().postNotificationName(ParticleEmitter.ParticleEmitterErrorNotification,
            object: [ParticleEmitter.ParticleEmitterNotificationMessageKey: "Advertising failed, retrying..."])
        serviceAdvertiser.startAdvertisingPeer()
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
        println("\(__FILE__), \(__FUNCTION__)")
        NSNotificationCenter.defaultCenter().postNotificationName(ParticleEmitter.ParticleEmitterInfoNotification,
            object: [ParticleEmitter.ParticleEmitterNotificationMessageKey: "Found peer, sending..."])
        let session = MCSession(peer: localPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.None)
        
        let propertyListSerialisationError = NSErrorPointer()
        let data = NSPropertyListSerialization.dataWithPropertyList(particleRepository.particleSets, format: NSPropertyListFormat.BinaryFormat_v1_0, options: 0, error: propertyListSerialisationError)
        
        let sendDataError = NSErrorPointer()
        let success = session.sendData(data, toPeers: [peerID], withMode: MCSessionSendDataMode.Reliable, error: sendDataError)
        if !success {
            NSNotificationCenter.defaultCenter().postNotificationName(ParticleEmitter.ParticleEmitterErrorNotification,
                object: [ParticleEmitter.ParticleEmitterNotificationMessageKey: "Sending data failed"])
        }
    }
    
    
    // MARK: - Browser delegate
    
    func browser(browser: MCNearbyServiceBrowser!, didNotStartBrowsingForPeers error: NSError!) {
        println("\(__FILE__), \(__FUNCTION__)")
        NSNotificationCenter.defaultCenter().postNotificationName(ParticleEmitter.ParticleEmitterErrorNotification,
            object: [ParticleEmitter.ParticleEmitterNotificationMessageKey: "Browsing failed, retrying..."])
        serviceBrowser.startBrowsingForPeers()
    }
    
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        println("\(__FILE__), \(__FUNCTION__)")
        NSNotificationCenter.defaultCenter().postNotificationName(ParticleEmitter.ParticleEmitterInfoNotification,
            object: [ParticleEmitter.ParticleEmitterNotificationMessageKey: "Found peer, receiving..."])
        let session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.None)
        session.delegate = self
    }
    
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
        println("\(__FILE__), \(__FUNCTION__)")
        NSNotificationCenter.defaultCenter().postNotificationName(ParticleEmitter.ParticleEmitterErrorNotification,
            object: [ParticleEmitter.ParticleEmitterNotificationMessageKey: "Lost peer"])
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        println("\(__FILE__), \(__FUNCTION__)")
        let readError = NSErrorPointer()
        let propertyList: AnyObject? = NSPropertyListSerialization.propertyListWithData(data, options: Int(NSPropertyListMutabilityOptions.Immutable.rawValue), format: nil, error: readError)
        if let particleSet = propertyList as? Array<ParticleSet> {
            for particleSet in particleSet {
                delegate.particleEmitter(self, didReceiveParticleSet: particleSet)
            }
        }
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        println("\(__FILE__), \(__FUNCTION__)")
        //...
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        println("\(__FILE__), \(__FUNCTION__)")
        //...
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        println("\(__FILE__), \(__FUNCTION__)")
        //...
    }
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        println("\(__FILE__), \(__FUNCTION__)")
        //...
    }
    
}