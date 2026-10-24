import UIKit
import Combine

/// Estado global: recebe quadros da extensão e entrega ao CarPlay.
final class MirrorModel: ObservableObject {
    static let shared = MirrorModel()

    @Published private(set) var carPlayConnected = false
    @Published private(set) var receiving = false
    @Published private(set) var fps = 0

    /// Definido pela tela do CarPlay para receber as imagens.
    var frameSink: ((UIImage) -> Void)?

    private let receiver = FrameReceiver()
    private let keepAlive = KeepAlive()
    private var started = false
    private var frameCount = 0
    private var lastFrameDate = Date.distantPast
    private var timer: Timer?

    func start() {
        guard !started else { return }
        started = true
        keepAlive.start()
        receiver.onFrame = { [weak self] image in
            DispatchQueue.main.async { self?.handle(image) }
        }
        receiver.start()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.fps = self.frameCount
            self.frameCount = 0
            self.receiving = Date().timeIntervalSince(self.lastFrameDate) < 2
        }
    }

    func setCarPlayConnected(_ connected: Bool) {
        carPlayConnected = connected
    }

    private func handle(_ image: UIImage) {
        frameCount += 1
        lastFrameDate = Date()
        frameSink?(image)
    }
}
