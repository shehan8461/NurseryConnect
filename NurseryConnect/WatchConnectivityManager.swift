import Foundation
import WatchConnectivity

/// Manages communication from the iOS app to the NurseryConnect Watch companion.
/// Call `sendUpdate(...)` whenever key data changes (e.g., on app foreground).
final class WatchConnectivityManager: NSObject {

    static let shared = WatchConnectivityManager()

    private override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    // MARK: – Public API

    /// Pushes the latest nursery state to the paired Apple Watch.
    func sendUpdate(pendingCount: Int, ratioStatus: RatioStatus, childCount: Int, staffCount: Int) {
        guard WCSession.default.activationState == .activated,
              WCSession.default.isReachable else { return }

        let payload: [String: Any] = [
            "pendingCount": pendingCount,
            "ratioStatus":  ratioStatus.rawValue,
            "isBreached":   ratioStatus == .breached,
            "childCount":   childCount,
            "staffCount":   staffCount,
            "timestamp":    Date().timeIntervalSince1970
        ]
        WCSession.default.sendMessage(payload, replyHandler: nil, errorHandler: nil)
    }
}

// MARK: – WCSessionDelegate (iOS)

extension WatchConnectivityManager: WCSessionDelegate {
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {}

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        // Re-activate after hand-off to a new watch
        WCSession.default.activate()
    }
}
