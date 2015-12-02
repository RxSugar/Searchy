import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
	private let appWindow = UIWindow(frame: UIScreen.mainScreen().bounds)

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		let navigationController = UINavigationController(rootViewController: SearchyController(context: ApplicationContext()))
        navigationController.navigationBar.translucent = false
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor(hue:0.56, saturation:1, brightness:1, alpha:1)]

		appWindow.rootViewController = navigationController
        appWindow.makeKeyAndVisible()
		return true
	}
}
