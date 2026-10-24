import Foundation

/// Protocolo entre a extensão de captura (ReplayKit) e o app:
/// TCP em loopback, cada quadro = 4 bytes (big-endian) com o tamanho + bytes JPEG.
enum FrameProtocol {
    static let port: UInt16 = 52847
    static let maxFrameBytes = 4 * 1024 * 1024

    static func packet(for jpeg: Data) -> Data {
        var length = UInt32(jpeg.count).bigEndian
        var data = Data(bytes: &length, count: 4)
        data.append(jpeg)
        return data
    }
}
