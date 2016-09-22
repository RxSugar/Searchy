import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
	fileprivate let appWindow = UIWindow(frame: UIScreen.main.bounds)

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		let navigationController = UINavigationController(rootViewController: SearchyController(context: ApplicationContext()))
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor(hue:0.56, saturation:1, brightness:1, alpha:1)]

		appWindow.rootViewController = navigationController
        appWindow.makeKeyAndVisible()
		return true
	}
}
