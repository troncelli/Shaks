import UIKit
import Network

/// Servidor TCP em loopback que recebe os JPEGs da extensão de captura.
final class FrameReceiver {
    var onFrame: ((UIImage) -> Void)?

    private let queue = DispatchQueue(label: "carmirror.receiver")
    private var listener: NWListener?
    private var current: NWConnection?

    func start() {
        queue.async { self.startListener() }
    }

    private func startListener() {
        do {
            let params = NWParameters.tcp
            params.requiredInterfaceType = .loopback
            let listener = try NWListener(using: params, on: NWEndpoint.Port(rawValue: FrameProtocol.port)!)
            listener.newConnectionHandler = { [weak self] connection in
                self?.queue.async { self?.accept(connection) }
            }
            listener.stateUpdateHandler = { [weak self] state in
                if case .failed = state {
                    self?.queue.asyncAfter(deadline: .now() + 2) { self?.startListener() }
                }
            }
            listener.start(queue: queue)
            self.listener = listener
        } catch {
            queue.asyncAfter(deadline: .now() + 2) { self.startListener() }
        }
    }

    private func accept(_ connection: NWConnection) {
        current?.cancel()
        current = connection
        connection.start(queue: queue)
        readHeader(connection)
    }

    private func readHeader(_ connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 4, maximumLength: 4) { [weak self] data, _, _, error in
            guard let self = self, error == nil, let data = data, data.count == 4 else {
                connection.cancel()
                return
            }
            let length = data.reduce(0) { ($0 << 8) | Int($1) }
            guard length > 0, length <= FrameProtocol.maxFrameBytes else {
                connection.cancel()
                return
            }
            self.readBody(connection, length: length)
        }
    }

    private func readBody(_ connection: NWConnection, length: Int) {
        connection.receive(minimumIncompleteLength: length, maximumLength: length) { [weak self] data, _, _, error in
            guard let self = self, error == nil, let data = data, data.count == length else {
                connection.cancel()
                return
            }
            if let image = UIImage(data: data)?.preparingForDisplay() {
                self.onFrame?(image)
            }
            self.readHeader(connection)
        }
    }
}
