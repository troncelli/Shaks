import Foundation
import Network

/// Envia JPEGs ao app principal via loopback. Descarta quadros se a rede estiver ocupada.
final class FrameSender {
    private let queue = DispatchQueue(label: "carmirror.sender")
    private var connection: NWConnection?
    private var ready = false
    private var inFlight = false
    private var stopped = false

    func start() {
        queue.async { self.connect() }
    }

    func stop() {
        queue.async {
            self.stopped = true
            self.connection?.cancel()
            self.connection = nil
        }
    }

    func send(_ jpeg: Data) {
        queue.async {
            guard self.ready, !self.inFlight, let connection = self.connection else { return }
            self.inFlight = true
            connection.send(content: FrameProtocol.packet(for: jpeg), completion: .contentProcessed { [weak self] error in
                self?.queue.async {
                    self?.inFlight = false
                    if error != nil { self?.reconnect() }
                }
            })
        }
    }

    private func connect() {
        guard !stopped else { return }
        let conn = NWConnection(host: "127.0.0.1", port: NWEndpoint.Port(rawValue: FrameProtocol.port)!, using: .tcp)
        connection = conn
        conn.stateUpdateHandler = { [weak self, weak conn] state in
            guard let self = self, let conn = conn else { return }
            self.queue.async {
                guard conn === self.connection else { return }
                switch state {
                case .ready:
                    self.ready = true
                case .failed, .cancelled:
                    self.reconnect()
                default:
                    break
                }
            }
        }
        conn.start(queue: queue)
    }

    private func reconnect() {
        ready = false
        inFlight = false
        connection?.cancel()
        connection = nil
        guard !stopped else { return }
        queue.asyncAfter(deadline: .now() + 1) { self.connect() }
    }
}
