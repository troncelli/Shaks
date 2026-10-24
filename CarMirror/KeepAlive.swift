import AVFoundation

/// Toca silêncio em loop (mixando com outros apps) para o iOS não suspender o app
/// enquanto a tela é espelhada com o iPhone em segundo plano.
final class KeepAlive {
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()

    func start() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)

            let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
            let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 44100)!
            buffer.frameLength = 44100 // zerado = silêncio

            engine.attach(player)
            engine.connect(player, to: engine.mainMixerNode, format: format)
            try engine.start()
            player.scheduleBuffer(buffer, at: nil, options: .loops)
            player.play()
        } catch {
            NSLog("KeepAlive falhou: \(error)")
        }
    }
}
