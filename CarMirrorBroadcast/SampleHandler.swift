import ReplayKit
import CoreImage
import QuartzCore

/// Extensão de transmissão: recebe a tela do iPhone e manda para o app, que desenha no CarPlay.
final class SampleHandler: RPBroadcastSampleHandler {
    private let sender = FrameSender()
    private let ciContext = CIContext(options: [.useSoftwareRenderer: false])
    private let colorSpace = CGColorSpaceCreateDeviceRGB()
    private let maxFPS = 24.0
    private let maxLongSide: CGFloat = 1280
    private let jpegQuality = 0.6
    private var lastFrameTime = 0.0

    override func broadcastStarted(withSetupInfo setupInfo: [String: NSObject]?) {
        sender.start()
    }

    override func broadcastFinished() {
        sender.stop()
    }

    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        guard sampleBufferType == .video else { return }

        let now = CACurrentMediaTime()
        guard now - lastFrameTime >= 1.0 / maxFPS else { return }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        lastFrameTime = now

        autoreleasepool {
            var image = CIImage(cvPixelBuffer: pixelBuffer)

            // Respeita a rotação do iPhone (retrato/paisagem).
            if let raw = CMGetAttachment(sampleBuffer, key: RPVideoSampleOrientationKey as CFString, attachmentModeOut: nil) as? NSNumber,
               let orientation = CGImagePropertyOrientation(rawValue: raw.uint32Value) {
                image = image.oriented(orientation)
            }

            let longSide = max(image.extent.width, image.extent.height)
            if longSide > maxLongSide {
                let scale = maxLongSide / longSide
                image = image.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
            }

            let options: [CIImageRepresentationOption: Any] = [
                CIImageRepresentationOption(rawValue: kCGImageDestinationLossyCompressionQuality as String): jpegQuality
            ]
            if let jpeg = ciContext.jpegRepresentation(of: image, colorSpace: colorSpace, options: options) {
                sender.send(jpeg)
            }
        }
    }
}
