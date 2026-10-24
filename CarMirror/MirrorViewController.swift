import UIKit

/// Tela que aparece no CarPlay: mostra os quadros recebidos, preenchendo o máximo possível.
final class MirrorViewController: UIViewController {
    private let imageView = UIImageView()
    private let label = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        imageView.contentMode = .scaleAspectFit
        imageView.frame = view.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(imageView)

        label.text = "Aguardando a tela do iPhone…\nAbra o CarMirror no celular e toque em “Iniciar espelhamento”."
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 22, weight: .medium)
        label.frame = view.bounds.insetBy(dx: 40, dy: 40)
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(label)

        MirrorModel.shared.frameSink = { [weak self] image in
            guard let self = self else { return }
            self.label.isHidden = true
            self.imageView.image = image
        }
    }
}
