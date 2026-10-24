import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // O receptor precisa estar de pé sempre que o app existir (celular ou CarPlay).
        MirrorModel.shared.start()
        return true
    }
}
