import UIKit
import CarPlay

/// Cena do CarPlay. O app se declara de navegação (entitlement carplay-maps), o que dá
/// uma janela (CPWindow) onde podemos colocar qualquer UIViewController.
final class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    private var interfaceController: CPInterfaceController?

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didConnect interfaceController: CPInterfaceController,
                                  to window: CPWindow) {
        self.interfaceController = interfaceController
        MirrorModel.shared.start()
        MirrorModel.shared.setCarPlayConnected(true)

        window.rootViewController = MirrorViewController()

        let template = CPMapTemplate()
        template.automaticallyHidesNavigationBar = true
        template.hidesButtonsWithNavigationBar = true
        interfaceController.setRootTemplate(template, animated: false, completion: nil)
    }

    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
                                  didDisconnect interfaceController: CPInterfaceController,
                                  from window: CPWindow) {
        self.interfaceController = nil
        MirrorModel.shared.frameSink = nil
        MirrorModel.shared.setCarPlayConnected(false)
    }
}
