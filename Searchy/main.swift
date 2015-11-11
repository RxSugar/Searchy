import UIKit

private func delegateClassName() -> String? {
    guard NSClassFromString("XCTestCase") == nil else { return nil }
    return NSStringFromClass(AppDelegate)
}

UIApplicationMain(Process.argc, Process.unsafeArgv, nil, delegateClassName())