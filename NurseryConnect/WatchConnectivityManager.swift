import Foundation
import WatchConnectivity

/// Manages communication from the iOS/iPhone app to the NurseryConnect Watch companion.
///
/// **Delivery strategy (layered):**
/// 1. `updateApplicationContext` — primary. Persists even when Watch is asleep or
///    the app is closed. The Watch reads it the moment its app opens.
/// 2. `sendMessage` — real-time supplement. Only sent when the Watch is reachable
///    (app is open and in the foreground) for an instant refresh.
///
/// The Watch app can also send a "requestSync" message back to ask for the
/// latest data (e.g. on Watch app launch when iPhone is reachable).
final class WatchConnectivityManager: NSObject {

    static let shared = WatchConnectivityManager()

    // Stored so we can re-send on a requestSync from the Watch
    private var lastPayload: [String: Any]? = nil

    private override init() {
        super.init()
        // WCSession is only supported on iPhone, not iPad.
        // The guard here ensures we do nothing silently on iPad.
        guard WCSession.isSupported() else {
            print("📵 [iPhone→Watch] WCSession NOT supported on this device (iPad). Watch sync disabled.")
            return
        }
        print("✅ [iPhone→Watch] WCSession IS supported. Activating session...")
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    // MARK: – Public API

    /// Pushes the latest nursery state to the paired Apple Watch.
    /// Safe to call from any thread; internally dispatched correctly.
    func sendUpdate(pendingCount: Int, ratioStatus: RatioStatus, childCount: Int, staffCount: Int) {
        guard WCSession.isSupported() else {
            print("⚠️ [iPhone→Watch] sendUpdate skipped — WCSession not supported (device may be iPad)")
            return
        }

        let payload: [String: Any] = [
            "pendingCount": pendingCount,
            "ratioStatus":  ratioStatus.rawValue,
            "isBreached":   ratioStatus == .breached,
            "childCount":   childCount,
            "staffCount":   staffCount,
            "timestamp":    Date().timeIntervalSince1970
        ]

        // Cache payload so we can re-send when the Watch sends a requestSync
        // We do this BEFORE checking activationState, because onAppear might fire before activation completes.
        lastPayload = payload

        guard WCSession.default.activationState == .activated else {
            print("⚠️ [iPhone→Watch] sendUpdate cached but deferred — session not yet activated")
            return
        }

        send(payload)
    }

    private func send(_ payload: [String: Any]) {
        print("📤 [iPhone→Watch] Sending update — pending:\(payload["pendingCount"] ?? "?") ratio:\(payload["ratioStatus"] ?? "?") staff:\(payload["staffCount"] ?? "?") children:\(payload["childCount"] ?? "?")")

        // PRIMARY: updateApplicationContext persists and is delivered even when
        // the Watch app is closed. The Watch reads it immediately on next launch.
        do {
            try WCSession.default.updateApplicationContext(payload)
            print("✅ [iPhone→Watch] applicationContext updated successfully")
        } catch {
            print("❌ [iPhone→Watch] updateApplicationContext failed: \(error)")
        }

        // SUPPLEMENT: sendMessage for instant refresh if Watch is open right now
        if WCSession.default.isReachable {
            print("📡 [iPhone→Watch] Watch is REACHABLE — sending real-time message too")
            WCSession.default.sendMessage(payload, replyHandler: nil) { error in
                print("⚠️ [iPhone→Watch] sendMessage error (non-fatal, context already sent): \(error)")
            }
        } else {
            print("📴 [iPhone→Watch] Watch not reachable right now — context delivery will occur when Watch opens")
        }
    }

    private func replyPayload() -> [String: Any] {
        if let lastPayload {
            return lastPayload
        }

        let context = WCSession.default.applicationContext
        if !context.isEmpty {
            return context
        }

        return [
            "pendingCount": 0,
            "ratioStatus": RatioStatus.compliant.rawValue,
            "isBreached": false,
            "childCount": 0,
            "staffCount": 0,
            "timestamp": Date().timeIntervalSince1970
        ]
    }
}

// MARK: – WCSessionDelegate (iOS)

extension WatchConnectivityManager: WCSessionDelegate {

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        if let error = error {
            print("❌ [iPhone→Watch] Session activation FAILED: \(error)")
            return
        }

        let stateString: String
        switch activationState {
        case .activated:   stateString = "ACTIVATED ✅"
        case .inactive:    stateString = "inactive"
        case .notActivated: stateString = "notActivated"
        @unknown default:  stateString = "unknown"
        }

        print("🔗 [iPhone→Watch] Session activation state: \(stateString)")
        print("🔗 [iPhone→Watch] isPaired=\(session.isPaired)  isWatchAppInstalled=\(session.isWatchAppInstalled)  isReachable=\(session.isReachable)")

        // Push latest data as soon as session activates,
        // so Watch gets it immediately if it's already open.
        if activationState == .activated, let payload = lastPayload {
            send(payload)
            print("✅ [iPhone→Watch] Pushed cached payload on activation")
        }
    }

    /// The Watch sends a "requestSync" message when its app launches
    /// and the iPhone is reachable — reply with the latest data.
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if message["requestSync"] as? Bool == true {
            print("📩 [iPhone→Watch] Received requestSync from Watch (no-reply form)")
            let payload = replyPayload()
            lastPayload = payload
            send(payload)
        }
    }

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        // Watch asked for data via the reply-handler form — respond immediately
        if message["requestSync"] as? Bool == true {
            print("📩 [iPhone→Watch] Received requestSync from Watch (reply-handler form) — sending reply")
            let payload = replyPayload()
            lastPayload = payload
            replyHandler(payload)
        } else {
            replyHandler([:])
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        print("📴 [iPhone→Watch] Session became inactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("🔄 [iPhone→Watch] Session deactivated — re-activating for new watch pairing")
        WCSession.default.activate()
    }
}
