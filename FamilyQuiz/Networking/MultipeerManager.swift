//
//  MultipeerManager.swift
//  Multi-User Family Quiz Arena
//
//  Manages Multipeer Connectivity for player-TV communication
//  Handles device discovery, connection, and message passing
//

import MultipeerConnectivity
import Foundation
import Combine

/// Manages multipeer connectivity between Apple TV and player devices
class MultipeerManager: NSObject, ObservableObject {
    // MARK: - Published Properties
    @Published var connectedPlayers: [Player] = []
    @Published var isHosting: Bool = false
    @Published var receivedMessage: GameMessage?

    // MARK: - Multipeer Components
    private let serviceType = "familyquiz" // Must be 15 chars or less, lowercase
    private var peerID: MCPeerID
    private var session: MCSession
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?

    // MARK: - Callbacks
    var onPlayerJoined: ((Player) -> Void)?
    var onPlayerLeft: ((UUID) -> Void)?
    var onPlayerAnswer: ((UUID, Int, TimeInterval) -> Void)?

    // MARK: - Initialization
    override init() {
        // Create peer ID with device name
        let deviceName = "Quiz TV"
        self.peerID = MCPeerID(displayName: deviceName)

        // Create session with encryption required
        self.session = MCSession(
            peer: peerID,
            securityIdentity: nil,
            encryptionPreference: .required
        )

        super.init()

        self.session.delegate = self
    }

    // MARK: - Host Methods (Apple TV)

    /// Start advertising as host (Apple TV)
    func startHosting() {
        guard !isHosting else { return }

        advertiser = MCNearbyServiceAdvertiser(
            peer: peerID,
            discoveryInfo: ["role": "host"],
            serviceType: serviceType
        )
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()

        isHosting = true
        print("🎮 Started hosting quiz game")
    }

    /// Stop hosting and disconnect all players
    func stopHosting() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
        session.disconnect()
        isHosting = false
        connectedPlayers.removeAll()
        print("🛑 Stopped hosting")
    }

    /// Send game message to all connected players
    func sendToAllPlayers(_ message: GameMessage) {
        guard !session.connectedPeers.isEmpty else { return }

        do {
            let data = try JSONEncoder().encode(message)
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("❌ Error sending message: \(error.localizedDescription)")
        }
    }

    /// Send message to specific player
    func sendToPlayer(_ message: GameMessage, playerId: UUID) {
        // Find peer for this player
        guard let peer = session.connectedPeers.first else { return }

        do {
            let data = try JSONEncoder().encode(message)
            try session.send(data, toPeers: [peer], with: .reliable)
        } catch {
            print("❌ Error sending message to player: \(error.localizedDescription)")
        }
    }

    // MARK: - Player Methods (iPhone/Controller)

    /// Start browsing for quiz games (iPhone app would use this)
    func startBrowsing() {
        browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
        print("🔍 Started browsing for quiz games")
    }

    /// Stop browsing for games
    func stopBrowsing() {
        browser?.stopBrowsingForPeers()
        browser = nil
    }

    /// Send player message to host
    func sendToHost(_ message: PlayerMessage) {
        guard let hostPeer = session.connectedPeers.first else {
            print("❌ No host connected")
            return
        }

        do {
            let data = try JSONEncoder().encode(message)
            try session.send(data, toPeers: [hostPeer], with: .reliable)
        } catch {
            print("❌ Error sending to host: \(error.localizedDescription)")
        }
    }

    // MARK: - Helper Methods

    /// Get number of connected peers
    var connectedPeerCount: Int {
        return session.connectedPeers.count
    }

    /// Check if session has connected peers
    var hasConnectedPeers: Bool {
        return !session.connectedPeers.isEmpty
    }
}

// MARK: - MCSessionDelegate

extension MultipeerManager: MCSessionDelegate {
    /// Peer changed state (connected, connecting, or not connected)
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                print("✅ Connected to: \(peerID.displayName)")

            case .connecting:
                print("🔄 Connecting to: \(peerID.displayName)")

            case .notConnected:
                print("❌ Disconnected from: \(peerID.displayName)")
                // Remove player if they disconnect
                if let index = self.connectedPlayers.firstIndex(where: { $0.name == peerID.displayName }) {
                    let player = self.connectedPlayers.remove(at: index)
                    self.onPlayerLeft?(player.id)
                }

            @unknown default:
                print("⚠️ Unknown connection state")
            }
        }
    }

    /// Received data from peer
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // Decode message based on whether we're host or player
        if isHosting {
            // Decode PlayerMessage (from iPhone to TV)
            do {
                let message = try JSONDecoder().decode(PlayerMessage.self, from: data)
                handlePlayerMessage(message, from: peerID)
            } catch {
                print("❌ Error decoding player message: \(error)")
            }
        } else {
            // Decode GameMessage (from TV to iPhone)
            do {
                let message = try JSONDecoder().decode(GameMessage.self, from: data)
                DispatchQueue.main.async {
                    self.receivedMessage = message
                }
            } catch {
                print("❌ Error decoding game message: \(error)")
            }
        }
    }

    /// Handle incoming player messages
    private func handlePlayerMessage(_ message: PlayerMessage, from peer: MCPeerID) {
        DispatchQueue.main.async {
            switch message {
            case .join(let playerName, let avatar):
                let player = Player(name: playerName, avatar: avatar)
                self.connectedPlayers.append(player)
                self.onPlayerJoined?(player)
                print("👤 Player joined: \(playerName)")

            case .answer(let playerId, let answerIndex, let timeElapsed):
                self.onPlayerAnswer?(playerId, answerIndex, timeElapsed)
                print("✍️ Player answered: \(playerId)")

            case .ready:
                print("✅ Player ready: \(peer.displayName)")

            case .leave(let playerId):
                if let index = self.connectedPlayers.firstIndex(where: { $0.id == playerId }) {
                    self.connectedPlayers.remove(at: index)
                    self.onPlayerLeft?(playerId)
                }
            }
        }
    }

    // MARK: - Unused MCSessionDelegate Methods

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Not used in this implementation
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // Not used in this implementation
    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // Not used in this implementation
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension MultipeerManager: MCNearbyServiceAdvertiserDelegate {
    /// Received invitation request from peer
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Automatically accept connections (in production, might want user confirmation)
        print("📨 Received invitation from: \(peerID.displayName)")
        invitationHandler(true, session)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension MultipeerManager: MCNearbyServiceBrowserDelegate {
    /// Found a peer advertising the service
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        // Check if this is a host
        if info?["role"] == "host" {
            print("🎯 Found quiz game host: \(peerID.displayName)")
            // Invite the host to connect
            browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
        }
    }

    /// Lost a peer
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("📡 Lost connection to: \(peerID.displayName)")
    }
}
