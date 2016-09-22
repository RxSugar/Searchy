import UIKit

private func delegateClassName() -> String? {
    guard NSClassFromString("XCTestCase") == nil else { return nil }
    return NSStringFromClass(AppDelegate.self)
}

let argv = UnsafeMutableRawPointer(CommandLine.unsafeArgv).bindMemory(
    to: UnsafeMutablePointer<Int8>.self,
    capacity: Int(CommandLine.argc))
UIApplicationMain(CommandLine.argc, argv, nil, delegateClassName())
