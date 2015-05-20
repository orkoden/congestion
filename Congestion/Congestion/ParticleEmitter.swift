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
    
    static let CongestionServiceType = "congestion"
    
    let particleRepository: ParticleRepository
    let delegate: ParticleEmitterDelegate
 
    let localPeerId: MCPeerID
    let serviceAdvertiser: MCNearbyServiceAdvertiser
    let serviceBrowser: MCNearbyServiceBrowser
    
    var session: MCSession
    
    // joerg:   C7470831-0122-4B9D-AD31-B6362CBBB49F
    // ratkins: D890E9D6-BDE6-4496-A6F8-F7D81B62CB79
    init(particleRepository: ParticleRepository, delegate: ParticleEmitterDelegate) {
        self.particleRepository = particleRepository
        localPeerId = MCPeerID(displayName: UIDevice.currentDevice().identifierForVendor.UUIDString)
        self.session = MCSession(peer: localPeerId, securityIdentity: nil, encryptionPreference: .None)
        
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: localPeerId, discoveryInfo: nil, serviceType: ParticleEmitter.CongestionServiceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: localPeerId, serviceType: ParticleEmitter.CongestionServiceType)
        self.delegate = delegate
        
        super.init()

        self.session.delegate = self
        if UIDevice.currentDevice().identifierForVendor.UUIDString == "C7470831-0122-4B9D-AD31-B6362CBBB49F" {
            // Joerg advertises
            serviceAdvertiser.delegate = self
            serviceAdvertiser.startAdvertisingPeer()
        } else {
            // Robert browses
            serviceBrowser.delegate = self
            serviceBrowser.startBrowsingForPeers()
        }
    }
    
    func upload(session: MCSession!, peerID: MCPeerID) {
        let propertyListSerialisationError = NSErrorPointer()
        let data = NSPropertyListSerialization.dataWithPropertyList(particleRepository.particleSets, format: NSPropertyListFormat.BinaryFormat_v1_0, options: 0, error: propertyListSerialisationError)
        
        let sendDataError = NSErrorPointer()
        let success = session.sendData(data, toPeers: [peerID], withMode: MCSessionSendDataMode.Reliable, error: sendDataError)
        if !success {
            NSNotificationCenter.defaultCenter().postNotificationName(ParticleEmitter.ParticleEmitterErrorNotification,
                object: [ParticleEmitter.ParticleEmitterNotificationMessageKey: "Sending data failed"])
        }
    }
    
    
    // MARK: - Advertiser delegate

    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didNotStartAdvertisingPeer error: NSError!) {
        println("\(__FUNCTION__)")
        NSNotificationCenter.defaultCenter().postNotificationName(ParticleEmitter.ParticleEmitterErrorNotification,
            object: [ParticleEmitter.ParticleEmitterNotificationMessageKey: "Advertising failed, retrying..."])
        serviceAdvertiser.startAdvertisingPeer()
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
        println("\(__FUNCTION__)")
        NSNotificationCenter.defaultCenter().postNotificationName(ParticleEmitter.ParticleEmitterInfoNotification,
            object: [ParticleEmitter.ParticleEmitterNotificationMessageKey: "Found peer, sending..."])

        invitationHandler(true, session)
    }
    

    // MARK: - Browser delegate
    
    func browser(browser: MCNearbyServiceBrowser!, didNotStartBrowsingForPeers error: NSError!) {
        println("\(__FUNCTION__)")
        NSNotificationCenter.defaultCenter().postNotificationName(ParticleEmitter.ParticleEmitterErrorNotification,
            object: [ParticleEmitter.ParticleEmitterNotificationMessageKey: "Browsing failed, retrying..."])
        serviceBrowser.startBrowsingForPeers()
    }
    
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        println("\(__FUNCTION__)")
        NSNotificationCenter.defaultCenter().postNotificationName(ParticleEmitter.ParticleEmitterInfoNotification,
            object: [ParticleEmitter.ParticleEmitterNotificationMessageKey: "Found peer, receiving..."])

        session.nearbyConnectionDataForPeer(peerID) { data, error in
            if data != nil {
                self.session.connectPeer(peerID, withNearbyConnectionData: data)
            }
        }
    }
    
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
        println("\(__FUNCTION__)")
        NSNotificationCenter.defaultCenter().postNotificationName(ParticleEmitter.ParticleEmitterErrorNotification,
            object: [ParticleEmitter.ParticleEmitterNotificationMessageKey: "Lost peer"])
    }
    
    
    // MARK: - Session delegate
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        println("\(__FUNCTION__)")
        let readError = NSErrorPointer()
        let propertyList: AnyObject? = NSPropertyListSerialization.propertyListWithData(data, options: Int(NSPropertyListMutabilityOptions.Immutable.rawValue), format: nil, error: readError)
        if let particleSet = propertyList as? Array<ParticleSet> {
            for particleSet in particleSet {
                delegate.particleEmitter(self, didReceiveParticleSet: particleSet)
            }
        }
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        println("\(__FUNCTION__)")
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        println("\(__FUNCTION__)")
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        println("\(__FUNCTION__)")
    }
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        let str: String
        
        switch state {
        case .NotConnected:
            str = "NotConnected"
        case .Connecting:
            str = "Connecting"
        case .Connected:
            str = "Connected"
            upload(session, peerID: peerID)
        }
        println("\(__FUNCTION__) \(peerID.description) did change state to \(str)")
    }
    
    func session(session: MCSession!, didReceiveCertificate certificate: [AnyObject]!, fromPeer peerID: MCPeerID!, certificateHandler: ((Bool) -> Void)!) {
        println("\(__FUNCTION__)")
        certificateHandler(true)
    }
    
}