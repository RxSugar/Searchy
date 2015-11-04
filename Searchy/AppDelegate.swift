import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

	var window: UIWindow?

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		let navigationController = UINavigationController(rootViewController: SearchyController())
		navigationController.navigationBar.translucent = false

		self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
		self.window!.rootViewController = navigationController
		self.window!.makeKeyAndVisible()
		return true
	}
}
