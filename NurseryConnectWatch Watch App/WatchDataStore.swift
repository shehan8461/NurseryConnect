import Foundation
import WatchConnectivity

/// Receives nursery data from the iOS NurseryConnect app via WatchConnectivity.
///
/// **Sync strategy (layered):**
/// 1. On session activation: reads `receivedApplicationContext` (the last context
///    pushed by iPhone) so data is available instantly even if iPhone is offline.
/// 2. On session activation: sends a "requestSync" ping to iPhone if it is
///    reachable, triggering an immediate fresh push.
/// 3. `didReceiveMessage` — handles real-time pushes while Watch app is open.
/// 4. `didReceiveApplicationContext` — handles context updates delivered while
///    the Watch app is already running.
final class WatchDataStore: NSObject, ObservableObject {

    @Published var pendingCount:  Int    = 0
    @Published var ratioStatus:   String = "—"
    @Published var isBreached:    Bool   = false
    @Published var childCount:    Int    = 0
    @Published var staffCount:    Int    = 0
    @Published var lastUpdated:   Date?  = nil
    @Published var isReachable:   Bool   = false

    override init() {
        super.init()
        guard WCSession.isSupported() else {
            print("📵 [Watch] WCSession not supported on this device")
            return
        }
        print("✅ [Watch] WCSession supported — activating...")
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    // MARK: - Helpers

    /// Apply a received message/context dictionary to published properties.
    private func apply(_ dict: [String: Any], source: String) {
        DispatchQueue.main.async {
            print("📥 [Watch] Applying data from [\(source)] — pending:\(dict["pendingCount"] ?? "?") ratio:\(dict["ratioStatus"] ?? "?") staff:\(dict["staffCount"] ?? "?") children:\(dict["childCount"] ?? "?")")
            if let v = dict["pendingCount"] as? Int    { self.pendingCount = v }
            if let v = dict["ratioStatus"]  as? String { self.ratioStatus  = v }
            if let v = dict["isBreached"]   as? Bool   { self.isBreached   = v }
            if let v = dict["childCount"]   as? Int    { self.childCount   = v }
            if let v = dict["staffCount"]   as? Int    { self.staffCount   = v }
            self.lastUpdated = Date()
        }
    }
}

// MARK: – WCSessionDelegate (watchOS)

extension WatchDataStore: WCSessionDelegate {

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error = error {
            print("❌ [Watch] Session activation FAILED: \(error)")
            return
        }

        let stateString = activationState == .activated ? "ACTIVATED ✅" : "not activated"
        print("🔗 [Watch] Session state: \(stateString)  isReachable=\(session.isReachable)")

        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }

        guard activationState == .activated else { return }

        // Step 1: Apply any cached context the iPhone pushed previously.
        // This gives us real data immediately even if iPhone is offline right now.
        let cached = session.receivedApplicationContext
        if !cached.isEmpty {
            print("💾 [Watch] Found cached applicationContext — applying immediately")
            apply(cached, source: "cachedContext")
        } else {
            print("ℹ️ [Watch] No cached applicationContext found yet (first launch or no iPhone data sent)")
        }

        // Step 2: If iPhone is reachable, ask for a fresh update.
        if session.isReachable {
            print("📡 [Watch] iPhone is REACHABLE — sending requestSync...")
            session.sendMessage(["requestSync": true], replyHandler: { [weak self] reply in
                if !reply.isEmpty {
                    print("📩 [Watch] Received reply to requestSync")
                    self?.apply(reply, source: "requestSyncReply")
                } else {
                    print("⚠️ [Watch] requestSync reply was empty (iPhone may not have data yet)")
                }
            }, errorHandler: { error in
                print("⚠️ [Watch] requestSync failed (non-fatal, cached context still valid): \(error)")
            })
        } else {
            print("📴 [Watch] iPhone NOT reachable — will rely on cached context")
        }
    }

    // MARK: Real-time message from iPhone (Watch app is open)

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print("📨 [Watch] Received real-time message from iPhone")
        apply(message, source: "sendMessage")
    }

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        print("📨 [Watch] Received real-time message from iPhone (reply-handler form)")
        apply(message, source: "sendMessage+reply")
        replyHandler([:])
    }

    // MARK: Application context (Watch app was closed when iPhone sent the update)

    func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        print("📬 [Watch] Received applicationContext update from iPhone (background delivery)")
        apply(applicationContext, source: "applicationContext")
    }

    // watchOS does not need sessionDidBecomeInactive / sessionDidDeactivate
}
