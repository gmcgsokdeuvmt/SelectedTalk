//
//  ConnectManager.swift
//  SelectedTalk
//
//  Created by Arashi USUKI on 12/3/15.
//  Copyright © 2015 Arashi USUKI. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class ConnectManager : NSObject {
    
    private let ConnectName = "example-color"
    
    private let myPeerID = MCPeerID(displayName: UIDevice.currentDevice().name)
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    
    private let serviceBrowser : MCNearbyServiceBrowser
    private var invitingPeers : [String] = []
    
    var delegate : ConnectManagerDelegate?
    
    override init() {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: ConnectName)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: ConnectName)
        super.init()
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
        
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.Required)
        session.delegate = self
        return session
        }()
    
    func sendText(text : String,toSendList: [Bool]) {
        NSLog("%@", "sendText: \(text)")
        
        if session.connectedPeers.count > 0 {
            var toPeers = [MCPeerID]()
            for i in 0..<session.connectedPeers.count{
                if toSendList[i]{
                    toPeers.append(session.connectedPeers[i-1])
                }
            }
            var error : NSError?
            do {
                try self.session.sendData(text.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, toPeers: toPeers, withMode: MCSessionSendDataMode.Reliable)
            } catch let error1 as NSError {
                error = error1
                NSLog("%@", "\(error)")
            }
        }
        
    }
    
    func sendImage(image: UIImage,toSendList: [Bool]){
        if session.connectedPeers.count > 0 {
            var toPeers = [MCPeerID]()
            for i in 0..<session.connectedPeers.count{
                if toSendList[i]{
                    toPeers.append(session.connectedPeers[i-1])
                }
            }
            if let imageData = UIImagePNGRepresentation(image) {
                var error : NSError?
                do {
                    try self.session.sendData(imageData, toPeers: toPeers, withMode: MCSessionSendDataMode.Reliable)
                } catch let error1 as NSError {
                    error = error1
                    NSLog("%@", "\(error)")
                }
            }
        }
    }
    
    func refreshPeers(){
        self.invitingPeers.removeAll()
        serviceAdvertiser.stopAdvertisingPeer()
        serviceAdvertiser.startAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
        serviceBrowser.startBrowsingForPeers()
        
    }
    
}

extension ConnectManager : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser,
        didNotStartAdvertisingPeer error: NSError) {
            NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: ((Bool, MCSession) -> Void)) {
        if !self.invitingPeers.contains(peerID.displayName) {
            
            NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
            invitationHandler(true, self.session)
        }
    }
    
}

extension ConnectManager : MCNearbyServiceBrowserDelegate {
    
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError){
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?){
        NSLog("%@", "foundPeer: \(peerID.displayName)")
        if !self.invitingPeers.contains(peerID.displayName) {
            NSLog("%@", "invitePeer: \(peerID.displayName)")
            browser.invitePeer(peerID, toSession: self.session, withContext: nil, timeout: 10)
            self.invitingPeers.append(peerID.displayName)
            NSLog("%@", "invitingPeers: \(invitingPeers)")
        }
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
    }
    
}

extension MCSessionState {
    
    func stringValue() -> String {
        switch(self) {
        case .NotConnected: return "NotConnected"
        case .Connecting: return "Connecting"
        case .Connected: return "Connected"
        default: return "Unknown"
        }
    }
    
}

extension ConnectManager : MCSessionDelegate {
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        NSLog("%@", "peer: \(peerID) didChangeState: \(state.stringValue())")
        self.delegate?.connectedDevicesChanged(self, connectedDevices: session.connectedPeers.map({$0.displayName}))
        switch state{
        case .NotConnected:
            self.invitingPeers.removeAll()
            for cPeers in self.session.connectedPeers{
                self.invitingPeers.append(cPeers.displayName)
            }
            break
        default: break
        }
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData")
        if let nsstr = NSString(data: data, encoding: NSUTF8StringEncoding){
            let str = nsstr as String
             NSLog("getTEXT")
            self.delegate?.textChanged(self, text: str)
        }
        if let image = UIImage(data: data) {
            dispatch_async(dispatch_get_main_queue()) {
                NSLog("getIMAGE")
                self.delegate?.imageChanged(self, image: image)
            }
        }
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
        // no use
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
        // no use
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress){
        NSLog("%@", "didStartReceivingResourceWithName")
        // no use
    }
    
}

protocol ConnectManagerDelegate {
    
    func connectedDevicesChanged(manager : ConnectManager, connectedDevices: [String])
    func textChanged(manager : ConnectManager, text: String)
    func imageChanged(manager : ConnectManager, image: UIImage)
    
}

