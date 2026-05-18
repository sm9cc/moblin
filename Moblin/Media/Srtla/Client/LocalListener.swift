import Foundation
import Network

class LocalListener: @unchecked Sendable {
    private var listener: NWListener!
    private var connection: NWConnection?
    var onReady: ((_ port: UInt16) -> Void)?
    var onError: ((_ message: String) -> Void)?

    init() {}

    func start() -> Bool {
        do {
            let options = NWProtocolUDP.Options()
            let parameters = NWParameters(dtls: .none, udp: options)
            parameters.acceptLocalOnly = true
            listener = try NWListener(using: parameters)
        } catch {
            logger.info("srtla: local: Failed to create listener with error \(error)")
            onError?("failed to create local listener")
            return false
        }
        listener.stateUpdateHandler = handleListenerStateChange(to:)
        listener.newConnectionHandler = handleNewListenerConnection(connection:)
        listener.start(queue: srtlaClientQueue)
        return true
    }

    func stop() {
        listener?.cancel()
        listener = nil
        connection?.cancel()
        connection = nil
    }

    func sendPacket(packet: Data) {
        guard let connection else {
            return
        }
        connection.send(content: packet, completion: .idempotent)
    }

    private func handleListenerStateChange(to state: NWListener.State) {
        switch state {
        case .setup:
            break
        case .ready:
            guard let port = listener.port else {
                onError?("missing local listener port")
                return
            }
            onReady?(port.rawValue)
        default:
            onError?("bad network state")
        }
    }

    private func handleNewListenerConnection(connection: NWConnection) {
        self.connection = connection
        connection.start(queue: srtlaClientQueue)
    }
}
